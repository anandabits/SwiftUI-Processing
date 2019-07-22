//
//  CompensatingImagePaint.swift
//  ImagePaintPicker
//
//  Created by Matthew Johnson on 7/18/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import SwiftUI

struct CompensatingImagePaint {
    var image: SizedImage
    var sourceRect: CGRect = .unit
    var scale: CGFloat = 1
}

extension CompensatingImagePaint {
    var verticallyCompensatedSourceRect: CGRect {
        var result = sourceRect
        result.origin.y = 1 - sourceRect.maxY
        return result
    }

    var horizontallyCompensatedScale: CGFloat {
        sourceRect.width * scale
    }

    var verticallyCompensatedScale: CGFloat {
        sourceRect.height * scale
    }

    enum ScaleCompensation: Hashable { case horizontal, vertical }
    func paint(
        flipCompensation: Bool = true,
        sourceRectCompensation: Bool = true,
        scaleCompensation: ScaleCompensation? = .horizontal,
        additionalScale: CGFloat = 1
    ) -> ImagePaint {
        ImagePaint(
            image: flipCompensation ? image.flipped : image.original,
            sourceRect: sourceRectCompensation ? verticallyCompensatedSourceRect : sourceRect,
            scale: additionalScale * {
                switch scaleCompensation {
                case nil:         return scale
                case .horizontal: return horizontallyCompensatedScale
                case .vertical:   return verticallyCompensatedScale
                }
            }()
        )
    }
}
