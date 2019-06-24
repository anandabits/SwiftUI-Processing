//
//  LinesView.swift
//  Processing
//
//  Created by Matthew Johnson on 6/23/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

// A port of a Processing experiment by Marc Edwards
// Some of the details are not quite identical but the
// general effect is similar
// https://gist.github.com/marcedwards/efe887ac6b1b561957eb52633840d2ae
// https://twitter.com/marcedwards/status/1045272978827620355?s=20

import SwiftUI

struct LinesView: ProcessingView {
    @ObjectBinding var renderClock = RenderClock(framesPerSecond: 30)

    let backgroundColor = Color(.sRGB, red: 204/255, green: 66/255, blue: 61/255, opacity: 1)

    var body: some View {
        let ease = Ease.inOutQuint(Ease.triangle(timeCycle(totalFrames: 400)))

        return ZStack {
            backgroundColor
            lines
                .position(x: 200 - ease * 100, y: 500 - ease)
                .scaleEffect(x: 1.6 + ease, y: 1.6 + ease)
        }
        .drawingGroup()
        .navigationBarHidden(true)
    }

    var lines: some View {
        GeometryReader { self.makeLines(in: $0.localSize) }
    }
    func makeLines(in size: CGSize) -> some View {
        let n1: CGFloat = 0.003 * CGFloat(frameCount)
        let n2: CGFloat = 0.0035 * CGFloat(frameCount)
        var path1 = Path()
        var path2 = Path()

        for i in 0...20 {
            let i = CGFloat(i * 41 + 16)
            for j in 0...7 {
                let j = CGFloat(j)
                path1.move(to: CGPoint(
                    x: perlin(5 + i + j + n1, octaves: 4) * size.width - size.width * 0.25,
                    y: i
                ))
                path1.addLine(to: CGPoint(
                    x: perlin(5 + i + j + n1 + 0.03, octaves: 4) * size.width - size.width * 0.25,
                    y: i
                ))

                path2.move(to: CGPoint(
                    x: perlin(i + j + n2, octaves: 4) * size.width * 0.8 - size.width * 0.05,
                    y: i
                ))
                path2.addLine(to: CGPoint(
                    x: perlin(i + j + n2 + 0.04, octaves: 4) * size.width * 0.8 - size.width * 0.05,
                    y: i
                ))
            }
        }

        return ZStack {
            path1
                .transform(.init(translationX: size.width / 3.5, y: 0))
                .stroke(
                    Color(.sRGB, white: 1, opacity: 80/255),
                    style: StrokeStyle(
                        lineWidth: 1,
                        lineCap: .round
                    )
                )
            path2
                .transform(.init(translationX: size.width / 7, y: 0))
                .stroke(
                    Color(.sRGB, white: 1, opacity: 200/255),
                    style: StrokeStyle(
                        lineWidth: 1,
                        lineCap: .round
                    )
                )
            path1
                .transform(.init(translationX: size.width / 5, y: 0))
                .stroke(
                    Color(.sRGB, white: 1, opacity: 80/255),
                    style: StrokeStyle(
                        lineWidth: 1,
                        lineCap: .round
                    )
                )
        }.scaleEffect(x: 4, y: 1)
    }
}

#if DEBUG
struct LinesView_Previews: PreviewProvider {
    static var previews: some View {
        LinesView()
    }
}
#endif
