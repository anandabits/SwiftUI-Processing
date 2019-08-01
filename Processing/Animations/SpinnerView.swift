//
//  SpinnerView.swift
//  Processing
//
//  Created by Matthew Johnson on 6/21/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

// A port of a Processing experiment by Marc Edwards
// https://gist.github.com/marcedwards/b163243e807fd40e1cba1094ea6f7d44
// https://twitter.com/marcedwards/status/1019551062406021126

import SwiftUI

struct SpinnerView: ProcessingView {
    @ObservedObject var renderClock = RenderClock(framesPerSecond: 30)

    var body: some View {
        ZStack {
            ForEach(0..<16) { i in
                self.arcs(atIndex: i)
            }
            Color(.sRGB, red: 25/255, green: 16/255, blue: 48/255, opacity: 1)
        }
        .blendMode(.screen)
        .drawingGroup()
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }

    func arcs(atIndex i: Int) -> some View {
        Group {
            self.arc(
                radius: i * 24,
                startOffet: i,
                endOffset: i + 12,
                totalFrames: 40,
                strokeColor: Color(.sRGB, red: 0, green: 0, blue: 1, opacity: 1)
            )
            self.arc(
                radius: i * 24,
                startOffet: i + 8,
                endOffset: i + 20,
                totalFrames: 40,
                strokeColor: Color(.sRGB, red: 0, green: 1, blue: 0, opacity: 1)
            )
            self.arc(
                radius: i * 24,
                startOffet: i + 16,
                endOffset: i + 28,
                totalFrames: 40,
                strokeColor: Color(.sRGB, red: 1, green: 0, blue: 0, opacity: 1)
            )
        }
    }

    func arc(radius: Int, startOffet: Int, endOffset: Int, totalFrames: Int, strokeColor: Color) -> some View {
        let radius = CGFloat(radius)
        var a = Ease.inOutN(timeCycle(totalFrames: totalFrames, offset: startOffet), power: 4)
        var b = Ease.inOutN(timeCycle(totalFrames: totalFrames, offset: endOffset), power: 5)
        let r = timeCycle(totalFrames: totalFrames, offset: 0)

        if (a > b) {
            b += 1
        }

        if frameCount % totalFrames > (frameCount + startOffet) % totalFrames {
            a += 1
            b += 1
        }

        let from = (a * .tau * 0.7 + r * .tau * 0.3 - 0.2)
        let to = (b * .tau * 0.7 + r * .tau * 0.3 + 0.2)
        let length = (to - from) / .tau

        return Circle()
            .trim(
                from: 0,
                to: length
            )
            .stroke(strokeColor, style: StrokeStyle(
                lineWidth: 10,
                lineCap: .round
            ))
            .frame(width: radius, height: radius)
            .rotationEffect(Angle(radians: Double(from)) + .tau * 0.75)

    }
}

#if DEBUG
struct SpinnerView_Previews: PreviewProvider {
    static var previews: some View {
        SpinnerView()
    }
}
#endif
