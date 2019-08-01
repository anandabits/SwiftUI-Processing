//
//  ImagePulse.swift
//  Processing
//
//  Created by Matthew Johnson on 7/20/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import SwiftUI

struct ImagePulse: ProcessingView {
    @State var isPickingImage = true
    @State var image = SizedImage(image: Image("twist"), size: CGSize(width: 800, height: 1140))
    @ObservedObject var renderClock = RenderClock(framesPerSecond: 30)

    var loopDuration = Inspectable<CGFloat>(
        initialValue: 6,
        label: Text("duration"),
        control: { Slider(value: $0, in: 1...10, label: { Text("duration") }) }
    )

    var paintScale = Inspectable<CGFloat>(
        initialValue: 2.45,
        label: Text("paint scale"),
        control: { Slider(value: $0, in: 0...5, label: { Text("paint scale") }) }
    )

    var spread = Inspectable<CGFloat>(
        initialValue: 24,
        label: Text("spread"),
        control: { Slider(value: $0, in: 0...50, label: { Text("spread") }) }
    )


    var rounding = Inspectable<CGFloat>(
        initialValue: 1,
        label: Text("rounding"),
        control: { Slider(value: $0, in: 0...4, step: 0.00001, label: { Text("rounding") }) }
    )

    var diamondScale = Inspectable<CGFloat>(
        initialValue: 1,
        label: Text("diamond scale"),
        control: { Slider(value: $0, in: 0...4, label: { Text("diamond scale") }) }
    )

    var slices = Inspectable<CGFloat>(
        initialValue: 15,
        label: Text("slices"),
        control: { Slider(value: $0, in: 1...40, step: 1, label: { Text("slices") }) }
    )

    var numberOfSlicesPerAxis: Int {
        Int(slices.wrappedValue)
    }
    var sliceCoordinates: LazyMapCollection<(Range<Int>), SliceCoordinate> {
        (0..<(numberOfSlicesPerAxis * numberOfSlicesPerAxis))
            .lazy.map {
                SliceCoordinate(x: $0 % self.numberOfSlicesPerAxis, y: $0 / self.numberOfSlicesPerAxis)
            }
    }

    var spreadAmount: CGFloat {
        Ease.InOutSin().delayed(0.5).loop.callAsFunction(loopPosition(duration: loopDuration.wrappedValue))
    }

    var paintScaleAmount: CGFloat {
        Ease.PerlinFade().delayed(0.6).loop.callAsFunction(loopPosition(duration: loopDuration.wrappedValue, offset: loopDuration.wrappedValue / 2))
    }

    func offset(for coordinate: SliceCoordinate) -> CGSize {
        CGSize(
            width: spreadAmount * spread.wrappedValue * CGFloat(coordinate.x - numberOfSlicesPerAxis / 2),
            height: spreadAmount * spread.wrappedValue * CGFloat(coordinate.y - numberOfSlicesPerAxis / 2)
        )
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(self.sliceCoordinates) { coordinate in
                    self.image.slice(
                        coordinate: coordinate,
                        horizontalSlices: self.numberOfSlicesPerAxis,
                        verticalSlices: self.numberOfSlicesPerAxis,
                        targetSize: proxy.size,
                        rounding: self.rounding.wrappedValue * self.spreadAmount,
                        scale: 1 + self.paintScale.wrappedValue * self.paintScaleAmount * -0.6
                    )
                    .scaleEffect(1 + self.spreadAmount * self.diamondScale.wrappedValue)
                    .offset(self.offset(for: coordinate))
                }
            }
        }
        .aspectRatio(image.size, contentMode: .fit)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .fullScreenDrawingGroup()
        // Ideally @Inspectable would be detected automatically,
        // but for now we can inject them manually anywhere in the view hierarchy.
        // They use a custom PreferenceKey internally to flow inspectables up to
        // the hud.
        .inspectables(paintScale, slices, spread, rounding, diamondScale, loopDuration)
        // Wraps the view in a hud container that displays a hud on demand by the user.
        // The hud has controls for all inspectables that have been injected in the descendent hierarchy.
        // In a more realistic example, inspectables would be injected at lower levels, not immediately
        // before caling `inspectorHUD`.
        .inspectorHUD()
        .sheet(isPresented: $isPickingImage) {
            ImagePicker {
                self.isPickingImage = false
                if let image = $0 {
                    self.image = image
                }
            }
        }
    }
}

#if DEBUG
struct ImagePulse_Previews: PreviewProvider {
    static var previews: some View {
        ImagePulse()
    }
}
#endif
