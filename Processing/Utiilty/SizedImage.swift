//
//  SizedImage.swift
//  Processing
//
//  Created by Matthew Johnson on 7/21/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import SwiftUI

struct SizedImage {
    let image: Image
    let size: CGSize
}

struct SliceCoordinate: Hashable, Identifiable {
    let x, y: Int
    var id: Self { self }
}

extension SizedImage {
    /// - precondition: `targetSize` has the same aspect ratio as `self`
    func slice(
        coordinate: SliceCoordinate,
        horizontalSlices: Int,
        verticalSlices: Int,
        targetSize: CGSize,
        rounding: CGFloat = 0,
        scale: CGFloat = 1
    ) -> some View {
        let numberOfSlices = CGSize(width: CGFloat(horizontalSlices), height: CGFloat(verticalSlices))
        var sliceSize = CGSize(
            width: floor(targetSize.width / numberOfSlices.width),
            height: floor(targetSize.height / numberOfSlices.height)
        )

        let extraPixels = targetSize - sliceSize * numberOfSlices
        var extraOrigin = CGSize.zero
        if CGFloat(coordinate.x) < extraPixels.width {
            sliceSize.width += 1
        } else {
            extraOrigin.width = extraPixels.width
        }
        if CGFloat(coordinate.y) < extraPixels.height {
            sliceSize.height += 1
        } else {
            extraOrigin.height = extraPixels.height
        }

        let sliceOrigin = CGSize(
            width: sliceSize.width * CGFloat(coordinate.x) + extraOrigin.width,
            height: sliceSize.height * CGFloat(coordinate.y) + extraOrigin.height
        )

        let sourceRect = CGRect(
            x: sliceOrigin.width / targetSize.width,
            y: sliceOrigin.height / targetSize.height,
            width: sliceSize.width / targetSize.width,
            height: sliceSize.height / targetSize.height
        )

        let paint = ImagePaint(
            image: image,
            sourceRect: sourceRect,
            scale: scale * targetSize.width / size.width
        )
        
        let radius = min(sliceSize.width, sliceSize.height) / 2
        return RoundedRectangle(cornerRadius: radius * rounding)
            .size(sliceSize)
            .fill(paint)
            .offset(sliceOrigin)
    }
}
