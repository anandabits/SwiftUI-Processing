//
//  CircleOfDots.swift
//  Processing
//
//  Created by Matthew Johnson on 6/30/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

// Inspired by a Processing experiment of Marc Edwards
// https://gist.github.com/marcedwards/dd6b9bdc45bf8c1750060320d14dc098
// https://twitter.com/marcedwards/status/1144236924095234053

import SwiftUI

struct CircleOfDots: ProcessingView {
    @ObjectBinding var renderClock = RenderClock(framesPerSecond: 24)

    // In a `ProcessingView`, `Inspectable` properties *should not* use `@ObjectBinding`
    // even though `Inspectable: BindableObject` because view invalidation needs to be driven
    // excusively by the render clock

    // The ability to manipulate design constants at runtime where you can see and
    // feel the change immediately on a real device can be extremely useful.
    // Inspectable allows a runtime editor control to be configured for a property.
    // The control is displayed as part of a hud when requested by the user.

    // TODO: The compiler crashes when using @Inspectable as a property wrapper
    var innerRadius = Inspectable<CGFloat>(
        initialValue: 1,
        label: Text("inner radius"),
        control: { Slider(
            value: $0,
            from: 0,
            through: 2,
            by: 0.01
        )}
    )
    var numberOfDots = Inspectable<CGFloat>(
        initialValue: 72,
        label: Text("number of dots"),
        control: { Slider(
            value: $0,
            from: 0,
            through: 400,
            by: 1
        )}
    )
    var dotRadius = Inspectable<CGFloat>(
        initialValue: 1,
        label: Text("dot radius"),
        control: { Slider(
            value: $0,
            from: 0.2,
            through: 4,
            by: 0.1
        )}
    )
    var bounceFrames = Inspectable<CGFloat>(
        initialValue: 60,
        label: Text("pulse rate"),
        control: { Slider(
            value: $0,
            from: 120,
            through: 15,
            by: -1
        )}
    )

    let width: CGFloat = 400
    let height: CGFloat = 400
    let color1 = Color(.sRGB, red: 1, green: 51/255, blue: 81/255, opacity: 1)
    let color2 = Color(.sRGB, red: 51/255, green: 226/255, blue: 1, opacity: 1)
    let color3 = Color(.sRGB, red: 94/255, green: 51/255, blue: 1, opacity: 1)

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.init(.sRGB, red: 25/255, green: 16/255, blue: 48/255, opacity: 1).scaleEffect(2)
                ForEach(0..<Int(self.numberOfDots.value)) { i in
                    self.makeCircles(
                        i: CGFloat(i),
                        from: Ease.hermite5(1 - self.timeBounce(totalFrames: 120, offset: CGFloat(i) / .tau * 120), iterations: 2) * 10 + 80 * self.innerRadius.value,
                        to: Ease.hermite5(1 - self.timeBounce(totalFrames: 120, offset: CGFloat(i) / .tau * 120 + 60), iterations: 1) * 70 + 90
                    )
                }.offset(x: proxy.localSize.width / 2, y: proxy.localSize.height / 2)
            }
        }
        .scaleEffect(Ease.hermite5(1 - timeBounce(totalFrames: self.bounceFrames.value, offset: 0.5)) * 0.4 + 0.8)
        .blendMode(.screen)
        .fullScreenDrawingGroup()
        // Ideally @Inspectable would be detected automatically,
        // but for now we can inject them manually anywhere in the view hierarchy.
        // They use a custom PreferenceKey internally to flow inspectables up to
        // the hud.
        .inspectables(innerRadius, numberOfDots, dotRadius, bounceFrames)
        // Wraps the view in a hud container that displays a hud on demand by the user.
        // The hud has controls for all inspectables that have been injected in the descendent hierarchy.
        // In a more realistic example, inspectables would be injected at lower levels, not immediately
        // before caling `inspectorHUD`.
        .inspectorHUD()
    }

    func makeCircles(i: CGFloat, from: CGFloat, to: CGFloat) -> some View {
        // The commented out code uses SwiftUI's shapes.
        // That approach performs significantly worse than a small number of paths.
        ZStack {
            Path { path in
                appendCircles(
                    to: &path,
                    start: CGPoint(x: cos(i) * from, y: sin(i) * from),
                    end: CGPoint(x: cos(i) * to, y: sin(i) * to)
                )
            }
            .fill(color1)
            /*makeCircles(
                start: CGPoint(x: cos(i) * from, y: sin(i) * from),
                end: CGPoint(x: cos(i) * to, y: sin(i) * to)
            )
            .foregroundColor(color1)*/

            Path { path in
                appendCircles(
                    to: &path,
                    start: CGPoint(x: cos(i + .tau * 0.333) * from, y: sin(i + .tau * 0.333) * from),
                    end: CGPoint(x: cos(i + .tau * 0.333) * to, y: sin(i + .tau * 0.333) * to)
                )
            }
            .fill(color2)
            /*makeCircles(
                start: CGPoint(x: cos(i + .tau * 0.333) * from, y: sin(i + .tau * 0.333) * from),
                end: CGPoint(x: cos(i + .tau * 0.333) * to, y: sin(i + .tau * 0.333) * to)
            )
            .foregroundColor(color2)*/

            Path { path in
                appendCircles(
                    to: &path,
                    start: CGPoint(x: cos(i + .tau * 0.666) * from, y: sin(i + .tau * 0.666) * from),
                    end: CGPoint(x: cos(i + .tau * 0.666) * to, y: sin(i + .tau * 0.666) * to)
                )
            }
            .fill(color3)
            /*makeCircles(
                start: CGPoint(x: cos(i + .tau * 0.666) * from, y: sin(i + .tau * 0.666) * from),
                end: CGPoint(x: cos(i + .tau * 0.666) * to, y: sin(i + .tau * 0.666) * to)
            )
            .foregroundColor(color3)*/
        }
    }

    /*func makeCircles(start: CGPoint, end: CGPoint) -> some View {
        ZStack {
            ForEach(0..<5) { i in
                self.makeCircle(
                    x: lerp(start: start.x, end: end.x, position: CGFloat(i)),
                    y: lerp(start: start.y, end: end.y, position: CGFloat(i))
                )
            }
        }
    }*/

    func appendCircles(to path: inout Path, start: CGPoint, end: CGPoint) {
        for i in 0..<5 {
            appendCircle(to: &path, at: CGPoint(
                x: lerp(start: start.x, end: end.x, position: CGFloat(i)),
                y: lerp(start: start.y, end: end.y, position: CGFloat(i))
            ))
        }
    }

    /*func makeCircle(x: CGFloat, y: CGFloat) -> some View {
        let radius = Ease.hermite5(Ease.triangle(gradientSpiral(
            x: x + width / 2,
            y: y + height / 2,
            offset: timeLoop(totalFrames: 120),
            frequency: 1
        )), iterations: 2) * 8 + 2
        return Circle()
            .offset(x: x, y: y)
            .frame(width: radius, height: radius)
    }*/

    func appendCircle(to path: inout Path, at point: CGPoint) {
        let radius = Ease.hermite5(Ease.triangle(gradientSpiral(
            x: point.x + width / 2,
            y: point.y + height / 2,
            offset: timeLoop(totalFrames: 120),
            frequency: 1
        )), iterations: 2) * 8 + 2
        path.addEllipse(in: CGRect(
            x: point.x - radius / 2,
            y: point.y - radius / 2,
            width: radius * dotRadius.value,
            height: radius * dotRadius.value
        ))
    }

    func gradientSpiral(x: CGFloat, y: CGFloat, offset: CGFloat, frequency: CGFloat) -> CGFloat {
        func length(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
            sqrt(x * x + y * y)
        }
        func moduloTauNormalized(_ radians: CGFloat) -> CGFloat {
            let wrapped = radians.truncatingRemainder(dividingBy: .tau)
            return wrapped < 0 ? wrapped + .tau : wrapped
        }
        func moduloUnitNormalized(_ value: CGFloat, offset: CGFloat = 0) -> CGFloat {
            (value + offset).truncatingRemainder(dividingBy: 1)
        }
        let xc = width / 2
        let yc = height / 2
        let normalisedRadius = length(x - xc, y - yc) / max(xc, yc)
        let plotAngle = atan2(y - yc, x - xc)
        let waveAngle = normalisedRadius * .tau * frequency
        return moduloUnitNormalized(moduloTauNormalized(plotAngle + waveAngle) / .tau, offset: 1 - offset)
    }
}

#if DEBUG
struct CircleOfDots_Previews : PreviewProvider {
    static var previews: some View {
        CircleOfDots()
    }
}
#endif

// TODO: Move these helpers to the right file when that doesn't cause a compiler crash

// MARK: - Inspectable

/// A property wrapper that is able to participate in the inspectable preference value
/// and be edited at runtime using the inspector hud.
@propertyDelegate
final class Inspectable<Value>: AnyInspectable {
    let _makeControl: (Binding<Value>) -> AnyView
    var value: Value { didSet { didChange.send() } }
    var delegateValue: Inspectable<Value> { self }
    init<V: View>(initialValue: Value, label: Text, @ViewBuilder control: @escaping (Binding<Value>) -> V) {
        self._makeControl = { AnyView(control($0)) }
        self.value = initialValue
        super.init()
        self.label = label
    }
    override func makeControl() -> AnyView {
        let binding = Binding(getValue: { self.value }, setValue: { self.value = $0 })
        return _makeControl(binding)
    }
}

import Combine
class AnyInspectable: BindableObject {
    let didChange = PassthroughSubject<Void, Never>()
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
    @ObjectBinding var base: AnyInspectable
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
            content.transformed(with: InspectableKey.self) { content, inspectables in
                content.overlay(
                    VStack {
                        ForEach(inspectables) { inspectable in
                            // TODO: why doesn't the custom alignment guide work?
                            HStack {
                                inspectable.label
                                    .font(.system(.caption))
                                    .color(Color(.sRGB, white: 1, opacity: 0.95))
                                    .alignmentGuide(.hudGutter) { d in d[.trailing] }
                                inspectable
                                    .saturation(0)
                                    .opacity(0.6)
                                    .alignmentGuide(.hudGutter) { d in d[.leading] }
                            }
                        }
                    }
                    .padding(.all, 8)
                    .background(Color(.sRGB, white: 0, opacity: 0.4))
                    // if this cornerRadius is included then only the last inspector in the stack works
                    // .cornerRadius(8)
                    .shadow(color: Color(.sRGB, white: 0, opacity: 0.45), radius: 1, x: 0, y: 0)
                    .padding(.all, 8)
                , alignment: .bottom)
            }
        }
        .tapAction {
            self.isShowingInspector.toggle()
        }
    }
}

extension HorizontalAlignment {
    private enum HUDGutter: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> Length {
            return d[.leading]
        }
    }
    fileprivate static let hudGutter = HorizontalAlignment(HUDGutter.self)
}

// MARK: - wrapperPreferenceValue

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
        transform(
            base.onPreferenceChange(Key.self) { self.preferenceValue = $0 },
            preferenceValue
        )
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


// MARK: - ViewBuilder Helpers

extension ViewBuilder {
    /// Used to enter a ViewBuilder context in an ad-hoc fashion to build a view.
    ///
    /// - note: This is especially useful when you want to choose a view based on a condition.
    static func of<V: View>(@ViewBuilder _ factory: () -> V) -> V {
        factory()
    }
}
// TODO: rename these transformed and abvove transformed(by preferenceKey)
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

extension View {
    // TODO: It would be nice to use this from other files but that crashes the compiler.
    /// Creates a drawing group and hides all system UI
    func fullScreenDrawingGroup() -> some View {
        drawingGroup()
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            // this breaks edge swipe so there is no way to go back :(
            .navigationBarBackButtonHidden(true)
            // this does not actually work
            .statusBar(hidden: true)
    }
}
