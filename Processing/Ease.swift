//
//  Ease.swift
//  Processing
//
//  Created by Matthew Johnson on 6/23/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import CoreGraphics

enum Ease {
    static func overSin(_ t: CGFloat, split1: CGFloat = 0.55, split1Amp: CGFloat = 1.15, split2: CGFloat = 0.85, split2Amp: CGFloat = 0.96) -> CGFloat {

        let start = t.position(in: 0...split1).clamped(to: 0...1)
        let middle = t.position(in: split1...split2).clamped(to: 0...1)
        let end = t.position(in: split2...1).clamped(to: 0...1)

        return inOutSin(start) * split1Amp +
            inOutSin(middle) * (split2Amp - split1Amp) +
            inOutSin(end) * (1 - split2Amp)
    }
    static func inOutSin(_ t: CGFloat) -> CGFloat {
        0.5 - cos(.pi * t) / 2
    }
    static func inOutQuint(_ t: CGFloat) -> CGFloat {
        t < 0.5
            ? 16 * t * t * t * t * t
            : 1 + 16 * (t - 1) * t * t * t * t
    }
    static func hermite5(_ t: CGFloat) -> CGFloat {
        t * t * t * (t * (t * 6 - 15) + 10)
    }
    static func hermite5(_ t: CGFloat, iterations: Int) -> CGFloat {
        var t = t
        for _ in 1...iterations {
            t = hermite5(t)
        }
        return t
    }
    static func triangle(_ t: CGFloat) -> CGFloat {
        t < 0.5
            ? t * 2
            : 2 - (t * 2)
    }
    static func inExp(_ t: CGFloat, power: CGFloat = 2) -> CGFloat {
        pow(t, power)
    }
    static func perlinFade(_ t: CGFloat) -> CGFloat {
        t * t * t * (t * (t * 6 - 15) + 10)
    }
}
