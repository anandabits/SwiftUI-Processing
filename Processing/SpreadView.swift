//
//  SpreadView.swift
//  Processing
//
//  Created by Matthew Johnson on 6/23/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

// A port of a Processing experiment by Marc Edwards
// https://gist.github.com/marcedwards/cbeb6472b4d9685721bb2b3794b6ed86
// https://twitter.com/marcedwards/status/1115591510701953024?s=20

import SwiftUI

struct SpreadView: ProcessingView {
    @ObjectBinding var renderClock = RenderClock(framesPerSecond: 30)

    static let text = Text("The stars don’t look bigger, but they do look brighter.")
        .font(.subheadline)
        .color(Color.white)
        .shadow(
            color: Color(.sRGB, white: 0.4, opacity: 1),
            radius: 0,
            x: 0,
            y: 1
        )
        .background(Color.black)

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black
                ForEach(0..<Int(proxy.localSize.width.rounded())) { i in
                    self.column(at: i, size: proxy.localSize)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .drawingGroup()
        .navigationBarHidden(true)
    }

    // In a real app you might want to use a snapshot image
    // but SwiftUI gives pretty impressive rendering performance
    // even without doing that.
    func column(at i: Int, size: CGSize) -> some View {
        SpreadView.text
            .frame(width: size.width)
            .mask(
                Rectangle()
                    .frame(width: 1, height: size.height)
                    .position(x: Length(i), y: 0)
            )
            .offset(
                x: 0,
                y: (timeNoise(totalFrames: 120, diameter: 0.1, zOffset: CGFloat(i) * 0.14) * size.width +
                   timeNoise(totalFrames: 120, diameter: 0.1, zOffset: CGFloat(i) * 0.60) * -size.width) *
                    Ease.hermite5(timeBounce(totalFrames: 120, offset: 120 - CGFloat(i) * 0.05), iterations: 4)
            )
    }
}

#if DEBUG
struct SpreadView_Previews: PreviewProvider {
    static var previews: some View {
        SpreadView()
    }
}
#endif
