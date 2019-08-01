//
//  Inspectable.swift
//  Processing
//
//  Created by Matthew Johnson on 7/2/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import Combine
import SwiftUI

/// A property wrapper that is able to participate in the inspectable preference value
/// and be edited at runtime using the inspector hud.
@propertyWrapper
final class Inspectable<Value>: AnyInspectable where Value: _FormatSpecifiable {
    let _makeControl: (Binding<Value>) -> AnyView
    var wrappedValue: Value { willSet { objectWillChange.send() } }
    var projectedValue: Inspectable<Value> { self }
    init<V: View>(initialValue: Value, label: Text, @ViewBuilder control: @escaping (Binding<Value>) -> V) {
        self._makeControl = { binding in
            AnyView(HStack {
                control(binding)
                Text("\(binding.value)")
            }
        )}
        self.wrappedValue = initialValue
        super.init()
        self.label = label
    }
    override func makeControl() -> AnyView {
        let binding = Binding(get: { self.wrappedValue }, set: { self.wrappedValue = $0 })
        return _makeControl(binding)
    }
}

class AnyInspectable: ObservableObject {
    var label = Text("no label")
    func makeControl() -> AnyView { AnyView(Text("not implemented")) }
}

extension View {
    /// Injects the specified inspectables into the inspectable preference value.
    func inspectables(_ inspectables: AnyInspectable...) -> some View {
        accumulatingPreference(
            key: InspectableKey.self,
            value: inspectables.map(InspectableControl.init)
        )
    }
}

enum InspectableKey: PreferenceKey {
    static let defaultValue: [InspectableControl] = []
    static func reduce(value: inout [InspectableControl], nextValue: () -> [InspectableControl]) {
        value.append(contentsOf: nextValue())
    }
}

struct InspectableControl: View, Equatable, Identifiable {
    @ObservedObject var base: AnyInspectable
    var body: some View { base.makeControl() }
    var label: Text { base.label }
    var id: ObjectIdentifier { ObjectIdentifier(base) }
    static func == (lhs: InspectableControl, rhs: InspectableControl) -> Bool {
        lhs.base === lhs.base
    }
}

// MARK: - inspectorHUD

extension View {
    /// Wraps `self` in a view that dispalys an inspector HUD when tapped.
    /// All controls injected by descendents using `inspectables` will be presentedx in the hud.
    func inspectorHUD() -> some View { modifier(InspectorHUDModifier()) }
}
struct InspectorHUDModifier: ViewModifier {
    @State var isShowingInspector = false
    func body(content: Content) -> some View {
        content.transformed(if: self.isShowingInspector) { content in
            content.overlayPreferenceValue(InspectableKey.self) { inspectables in
                VStack {
                    ForEach(inspectables) { inspectable in
                        // TODO: why doesn't the custom alignment guide work?
                        HStack {
                            inspectable.label
                                .font(.system(.caption))
                                .foregroundColor(Color(.sRGB, white: 1, opacity: 0.95))
                                .alignmentGuide(.hudGutter) { d in d[.trailing] }
                            inspectable
                                .font(.system(.caption))
                                .foregroundColor(Color(.sRGB, white: 1, opacity: 0.95))
                                .saturation(0)
                                .opacity(0.6)
                                .alignmentGuide(.hudGutter) { d in d[.leading] }
                        }
                    }
                }
                .padding(.all, 8)
                .background(Color(.sRGB, white: 0, opacity: 0.4))
                // if this cornerRadius is included then only the last inspector in the stack works
                //.cornerRadius(8)
                .shadow(color: Color(.sRGB, white: 0, opacity: 0.45), radius: 1, x: 0, y: 0)
                .padding(.all, 8)
                .offset(CGSize(width: 0, height: 200))
            }
        }
        .onTapGesture {
            self.isShowingInspector.toggle()
        }
    }
}

extension HorizontalAlignment {
    private enum HUDGutter: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            return d[.leading]
        }
    }
    fileprivate static let hudGutter = HorizontalAlignment(HUDGutter.self)
}
