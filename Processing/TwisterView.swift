//
//  TwisterView.swift
//  Processing
//
//  Created by Matthew Johnson on 6/19/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

// A port of a Processing experiment by Marc Edwards
// https://dribbble.com/shots/5843126-Twisty-3D-effect-using-a-2D-image
// https://gist.github.com/marcedwards/de04f87355a86875bfcd0e857cb9598f
// https://twitter.com/marcedwards/status/1085132586278502400?s=20

import SwiftUI

struct TwisterView: ProcessingView {
    @ObjectBinding var renderClock = RenderClock(framesPerSecond: 30)

    let color = Color(.sRGB, red: 25/255, green: 16/255, blue: 48/255, opacity: 1)
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle().fill(color)
            ForEach(0..<30) { i in
                self.slice(yOffset: self.yOffset(i))
                    .offset(x: self.xWobble(i), y: CGFloat(i) * 20)
            }
            .scaleEffect(x: 0.5, y: 1)
            .offset(x: 0, y: 90)
        }
        .edgesIgnoringSafeArea(.all)
        .drawingGroup()
        .navigationBarHidden(true)
    }

    let twist = Image("twist")
    let sliceHeight: CGFloat = 19
    let imageWidth: CGFloat = 800
    let imageHeight: CGFloat = 1140
    func slice(yOffset: CGFloat) -> some View {
        twist.slice(
            sourceRect: CGRect(x: 0, y: yOffset / imageHeight, width: 1, height: sliceHeight / imageHeight),
            imageSize: CGSize(width: imageWidth, height: imageHeight)
        )
    }

    var animatedOffset: CGFloat {
        0.25 + (easeInOutSin(easeTriangle(timeCycle(totalFrames: 120))) * 2.5)
    }

    func yOffset(_ i: Int) -> CGFloat {
        var offset = easeInOutSin(timeCycle(totalFrames: 60, offset: CGFloat(i) * animatedOffset)) * 0.4
        offset += timeCycle(totalFrames: 60, offset: CGFloat(i) * animatedOffset) * 0.6
        return offset * (imageHeight / 2)
    }

    func xWobble(_ i: Int) -> CGFloat {
        sin(timeCycle(totalFrames: 120, offset: CGFloat(i) * 4) * .tau) *
        (easeInOutN(easeTriangle(timeCycle(totalFrames: 120)), power: 4) * 100)
    }
}

#if DEBUG
struct TwisterView_Previews: PreviewProvider {
    static var previews: some View {
        TwisterView()
    }
}
#endif

// TODO: Move these to a standalone extensions file when that doesn't crash the compiler

extension Image {
    /// Creates a slice of the image specified using a rect inside the unit rect and an image size.
    /// The resulting view has a fixed size that corresponds to the size of the specified
    /// slice of the image.
    func slice(sourceRect: CGRect, imageSize: CGSize) -> some View {
        Rectangle().fill(paint(sourceRect: sourceRect))
            .frame(width: sourceRect.size.width * imageSize.width, height: sourceRect.size.height * imageSize.height)
    }
    /// Creates paint from the image that samples from the specified rect inside the unit rect.
    func paint(sourceRect: CGRect) -> ImagePaint {
        ImagePaint(image: self, sourceRect: sourceRect)
    }
}

