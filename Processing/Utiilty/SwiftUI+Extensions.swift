//
//  SwiftUIExtensions.swift
//  Processing
//
//  Created by Matthew Johnson on 6/23/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import SwiftUI

extension Angle {
    static var tau: Angle { .radians(.pi * 2)}
}

extension GeometryProxy {
    var localCenter: CGPoint {
        let localFrame = frame(in: .local)
        return CGPoint(x: localFrame.midX, y: localFrame.midY)
    }
    var localSize: CGSize {
        frame(in: .local).size
    }
}

extension UnitPoint {
    func point(in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.origin.x + x * rect.size.width,
            y: rect.origin.y + y * rect.size.height
        )
    }
}

extension Path {
    mutating func addEquilateralTriangle(center: CGPoint, radius: CGFloat, angle: Angle) {
        func makePoint(_ a: CGFloat) -> CGPoint {
            let a = a + CGFloat(angle.radians)
            return CGPoint(x: center.x + cos(a) * radius, y: center.y + sin(a) * radius)
        }
        move(to: makePoint(0))
        addLine(to: makePoint(.tau / 3))
        addLine(to: makePoint(2 * .tau / 3))
        closeSubpath()
    }
}

extension View {
    func frame(_ size: CGSize, alignment: Alignment = .center) -> some View {
        frame(width: size.width, height: size.height, alignment: alignment)
    }

    /// Creates a drawing group and hides all system UI
    func fullScreenDrawingGroup() -> some View {
        drawingGroup()
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            // this breaks edge swipe so there is no way to go back :(
            // .navigationBarBackButtonHidden(true)
            // this does not actually work
            .statusBar(hidden: true)
    }
}

// MARK: - ViewBuilder Helpers

extension ViewBuilder {
    /// Used to enter a ViewBuilder context in an ad-hoc fashion to build a view.
    ///
    /// - note: This is especially useful when you want to choose a view based on a condition.
    static func of<V: View>(@ViewBuilder _ factory: () -> V) -> V {
        factory()
    }
}

extension View {
    /// Transforms the view if the condition is met, otherwise returns it directly.
    func transformed<V: View>(if condition: Bool, @ViewBuilder _ transform: (Self) -> V) -> some View {
        ViewBuilder.of {
            if condition {
                transform(self)
            } else {
                self
            }
        }
    }
}

// MARK: accumulatingPreference

extension View {
    /// Accumulates the specified preference value with descendent preference values, returning a view with the accumulated preference value.
    func accumulatingPreference<Key>(
        key: Key.Type = Key.self,
        value: Key.Value
        ) -> some View
        where Key: PreferenceKey,
        Key.Value: Equatable {
            modifier(PreferenceAccumulator<Key>(value: value))
    }
}

/// Captures descendent preferences and combines them with the stored preference value.
struct PreferenceAccumulator<Key>: ViewModifier where Key: PreferenceKey, Key.Value: Equatable {
    let value: Key.Value

    func body(content: Content) -> some View {
        content.transformPreference(Key.self) {
            Key.reduce(value: &$0, nextValue: { self.value })
        }
    }
}

// MARK: - PreferenceTransform
/*
extension View {
    /// Reads the specified preference key and transforms the `self` using the preference value.
    func transformed<Key, Body>(
        with key: Key.Type = Key.self,
        @ViewBuilder _ transform: @escaping (Modified<_PreferenceActionModifier<Key>>, Key.Value) -> Body
        ) -> some View
        where Key: PreferenceKey,
        Key.Value: Equatable,
        Body: View
    {
        PreferenceTransform<Key, Self, Body>(base: self, transform: transform)
    }
}

struct PreferenceTransform<Key, Base, Body>: View
    where Key: PreferenceKey,
    Key.Value: Equatable,
    Base: View,
Body: View {

    typealias Content = Base.Modified<_PreferenceActionModifier<Key>>

    var base: Base
    var transform: (Content, Key.Value) -> Body
    @State var preferenceValue = Key.defaultValue

    var body: Body {
        // TODO: SwiftUI adopted an opaque result type for onPreferenceChange
        fatalError()
        /*transform(
            base.onPreferenceChange(Key.self) { self.preferenceValue = $0 },
            preferenceValue
        )*/
    }
}
*/
