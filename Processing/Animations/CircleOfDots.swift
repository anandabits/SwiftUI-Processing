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
    @ObservedObject var renderClock = RenderClock(framesPerSecond: 24)

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
            in: 0...2,
            step: 0.01,
            label: { Text("inner radius") }
        )}
    )
    var numberOfDots = Inspectable<CGFloat>(
        initialValue: 72,
        label: Text("number of dots"),
        control: { Slider(
            value: $0,
            in: 0...400,
            step: 1,
            label: { Text("number of dots") }
        )}
    )
    var dotRadius = Inspectable<CGFloat>(
        initialValue: 1,
        label: Text("dot radius"),
        control: { Slider(
            value: $0,
            in: 0.2...4,
            step: 0.1,
            label: { Text("dot radius") }
        )}
    )
    var bounceFrames = Inspectable<CGFloat>(
        initialValue: 60,
        label: Text("pulse rate"),
        control: { Slider(
            value: $0,
            in: 15...120,
            step: 1,
            label: { Text("pulse rate") }
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
                ForEach(0..<Int(self.numberOfDots.wrappedValue)) { i in
                    self.makeCircles(
                        i: CGFloat(i),
                        from: Ease.hermite5(1 - self.timeBounce(totalFrames: 120, offset: CGFloat(i) / .tau * 120), iterations: 2) * 10 + 80 * self.innerRadius.wrappedValue,
                        to: Ease.hermite5(1 - self.timeBounce(totalFrames: 120, offset: CGFloat(i) / .tau * 120 + 60), iterations: 1) * 70 + 90
                    )
                }.offset(x: proxy.localSize.width / 2, y: proxy.localSize.height / 2)
            }
        }
        .scaleEffect(Ease.hermite5(1 - timeBounce(totalFrames: self.bounceFrames.wrappedValue, offset: 0.5)) * 0.4 + 0.8)
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
            width: radius * dotRadius.wrappedValue,
            height: radius * dotRadius.wrappedValue
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
