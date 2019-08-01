//
//  DesignableView.swift
//  Processing
//
//  Created by Matthew Johnson on 6/26/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import SwiftUI

protocol DesignableView: View {
    associatedtype DesignInspector: View

    var designInspector: DesignInspector { get }
}

struct Designable<Content: DesignableView>: View {
    var content: Content
    @Environment(\.isDesigning) var isDesigning: Bool

    var body: some View {
        ViewBuilder.of {
            if isDesigning {
                // something that overlays content.body with editing controls
                self.content.body.overlay(Color(.sRGB, white: 0, opacity: 0.4))
            } else {
                self.content.body
            }
        }
    }
}

struct EnvironmentValueCycler<Value>: ViewModifier {
    @State private var index = 0
    private let values: [Value]
    private let keyPath: WritableKeyPath<EnvironmentValues, Value>

    init(keyPath: WritableKeyPath<EnvironmentValues, Value>, values: [Value]) {
        assert(!values.isEmpty)
        self.values = values
        self.keyPath = keyPath
    }

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                self.index += 1
                if self.index == self.values.count { self.index = 0 }
            }
            .environment(keyPath, values[index])
    }
}

extension DesignableView {
    // This could use a modifier instead if we could see the DesignableView
    // below _ViewModifier_Content
    var designable: some View {
        Designable(content: self)
            .modifier(EnvironmentValueCycler(
                keyPath: \.designMode,
                values: [.inactive, .active]
            ))
        //modifier(DesignableModifier<Self>())
    }
}
/*struct DesignableModifier<Content: DesignableView>: ViewModifier {
    typealias Body = Designable<Content>

    func body(content: _ViewModifier_Content<DesignableModifier<Content>>) -> Designable<Content> {
        //Designable(content: content)
        fatalError()
    }
}*/


// MARK: - DesignMode

enum DesignMode: EnvironmentKey {
    case active, inactive
    static var defaultValue = DesignMode.inactive
}

extension EnvironmentValues {
    var isDesigning: Bool { designMode == .active }
    var designMode: DesignMode {
        get { self[DesignMode.self] }
        set { self[DesignMode.self] = newValue }
    }
}

extension View {
    func designMode(_ mode: DesignMode) -> some View {
        environment(\.designMode, mode)
    }
}

