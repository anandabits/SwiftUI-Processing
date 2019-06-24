//
//  SwiftUIExtensions.swift
//  Processing
//
//  Created by Matthew Johnson on 6/23/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import SwiftUI

extension Angle {
    static var tau: Angle { .radians(.pi * 2)}
}

extension GeometryProxy {
    var localCenter: CGPoint {
        let localFrame = frame(in: .local)
        return CGPoint(x: localFrame.midX, y: localFrame.midY)
    }
    var localSize: CGSize {
        frame(in: .local).size
    }
}

extension UnitPoint {
    func point(in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.origin.x + x * rect.size.width,
            y: rect.origin.y + y * rect.size.height
        )
    }
}

extension Path {
    mutating func addEquilateralTriangle(center: CGPoint, radius: CGFloat, angle: Angle) {
        func makePoint(_ a: CGFloat) -> CGPoint {
            let a = a + CGFloat(angle.radians)
            return CGPoint(x: center.x + cos(a) * radius, y: center.y + sin(a) * radius)
        }
        move(to: makePoint(0))
        addLine(to: makePoint(.tau / 3))
        addLine(to: makePoint(2 * .tau / 3))
        closeSubpath()
    }
}
