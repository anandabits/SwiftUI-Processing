//
//  TrianglesView.swift
//  Processing
//
//  Created by Matthew Johnson on 6/22/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

// A port of a Processing experiment by Marc Edwards
// https://dribbble.com/shots/6539126-Triangles-in-triangles
// https://gist.github.com/marcedwards/32827371e4890a62ba69e57a1fe22f3d
// https://twitter.com/marcedwards/status/1132852549839720449?s=20

import SwiftUI

struct TrianglesView: ProcessingView {
    @ObjectBinding var renderClock = RenderClock(framesPerSecond: 30)

    let backgroundColor = Color(.sRGB, red: 30/255, green: 16/255, blue: 51/255, opacity: 1)
    let color1 = Color(.sRGB, red: 1, green: 235/255, blue: 51/255, opacity: 1)
    let color2 = Color(.sRGB, red: 1, green: 51/255, blue: 81/255, opacity: 1)
    let color3 = Color(.sRGB, red: 51/255, green: 226/255, blue: 1, opacity: 1)

    var body: some View {
        var zoom: CGFloat = 1
        zoom += 9 * Ease.overSin(Ease.hermite5(Ease.inExp(timeRangeLoop(totalFrames: 180, start: 0, end: 60, offset: 0))))
        zoom += 90 * Ease.overSin(Ease.hermite5(Ease.inExp(timeRangeLoop(totalFrames: 180, start: 60, end: 120, offset: 0))))
        zoom += 900 * Ease.overSin(Ease.hermite5(Ease.inExp(timeRangeLoop(totalFrames: 180, start: 120, end: 180, offset: 0))))
        zoom *= 1.2

        return ZStack {
            makeTriangles(fillColor: color1, scale: 10)
            makeTriangles(fillColor: color2, scale: 1)
            makeTriangles(fillColor: color3, scale: 0.1)
            makeTriangles(fillColor: color1, scale: 0.01)
            makeTriangles(fillColor: color2, scale: 0.001)
            makeTriangles(fillColor: color3, scale: 0.0001)
        }
        .edgesIgnoringSafeArea(.all)
        .scaleEffect(zoom)
        .rotationEffect(Angle(radians: Double(timeLoop(totalFrames: 180) * .tau / 3.0 + .tau * 0.75)))
        .drawingGroup()
        .navigationBarHidden(true)
    }

    func makeTriangles(fillColor: Color, scale: CGFloat) -> some View {
        GeometryReader { proxy in
            ZStack {
                Path { $0.addEquilateralTriangle(
                        center: proxy.localCenter,
                        radius: 20 * 10,
                        angle: Angle(radians: 0)
                )}.fill(self.backgroundColor)
                self.makeTriangleGrid(
                    center: proxy.localCenter,
                    iterations: 4,
                    radius: 20,
                    angle: Angle(radians: 0),
                    fillColor: fillColor
                )
            }.scaleEffect(scale)
        }
    }

    func makeTriangleGrid(center: CGPoint, iterations: Int, radius: CGFloat, angle: Angle, fillColor: Color) -> some View {
        Path { path in
            for i in (1..<iterations) {
                let i = i * 3
                let r = radius * CGFloat(i)
                for j in 0...2 {
                    let a = CGFloat(j) * .tau / 3
                    let start = CGFloat(angle.radians) + a
                    let end = CGFloat(angle.radians) + a + .tau / 3
                    for k in (0..<i) {
                        path.addEquilateralTriangle(
                            center: CGPoint(
                                x: center.x + lerp(start: cos(start) * r, end: cos(end) * r, position: CGFloat(k) / CGFloat(i)),
                                y: center.y + lerp(start: sin(start) * r, end: sin(end) * r, position: CGFloat(k) / CGFloat(i))
                            ),
                            radius: radius,
                            angle: Angle(radians: 0)
                        )
                    }
                }
            }
        }.fill(fillColor)
    }
}

#if DEBUG
struct TrianglesView_Previews: PreviewProvider {
    static var previews: some View {
        TrianglesView()
    }
}
#endif
