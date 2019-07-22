//
//  Ease.swift
//  Processing
//
//  Created by Matthew Johnson on 6/23/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import CoreGraphics

// TODO: make this generic over the new Math protocols
/// Models functions that produce a value of `0` with the input `0`, a value of `1` with the input `1`,
/// having no or only small extensions in range beyond `0...1`.
protocol EasingFunction {
    /// - precondition:`t` must be in the range `0...1`
    func callAsFunction(_ t: CGFloat) -> CGFloat
}

/// Models functions that produce a value of `0` with the input `0`, a value of `0` with the input `1`,
/// reaching a value of `1` somewhere in between and having no or only small extensions in range beyond `0...1`.
protocol UnipolarLoopingFunction {
    /// - precondition:`t` must be in the range `0...1`
    func callAsFunction(_ t: CGFloat) -> CGFloat
}

/// Models functions that produce a value of `0` with the input `0`, proceeds with positive values eventually reaching `1`
/// before reversing, crossing through `0`, eventually reacing `-1` and finally returning to `0` with the input `1`
/// (having no or only small extensions in range beyond `-1...1`).
protocol BipolarLoopingFunction {
    /// - precondition:`t` must be in the range `0...1`
    func callAsFunction(_ t: CGFloat) -> CGFloat
}

struct EaseLoop<E: EasingFunction>: UnipolarLoopingFunction {
    var ease: E
    func callAsFunction(_ t: CGFloat) -> CGFloat {
        t < 0.5
            ? ease.callAsFunction(2 * t)
            : ease.callAsFunction(2 - 2 * t)
    }
}

extension EasingFunction {
    var loop: EaseLoop<Self> {
        EaseLoop(ease: self)
    }
}

struct EaseDelay<E: EasingFunction>: EasingFunction {
    var ease: E
    var delay: CGFloat // a percentage of the unit duration
    func callAsFunction(_ t: CGFloat) -> CGFloat {
        t < delay
            ? 0
            : ease.callAsFunction((t - delay) / (1 - delay))

    }
}

extension EasingFunction {
    func delayed(_ amount: CGFloat) -> EaseDelay<Self> {
        EaseDelay(ease: self, delay: amount)
    }
}

extension Ease {
    struct InOutSin: EasingFunction {
        func callAsFunction(_ t: CGFloat) -> CGFloat {
            0.5 - cos(.pi * t) / 2
        }
    }

    struct PerlinFade: EasingFunction {
        func callAsFunction(_ t: CGFloat) -> CGFloat {
            t * t * t * (t * (t * 6 - 15) + 10)
        }
    }
}

struct SymetricBipolarLoop<L: UnipolarLoopingFunction>: BipolarLoopingFunction {
    var loop: L
    func callAsFunction(_ t: CGFloat) -> CGFloat {
        t < 0.5
            ? loop.callAsFunction(2 * t)
            : -loop.callAsFunction(2 - 2 * t)
    }
}

extension UnipolarLoopingFunction {
    var bipolar: SymetricBipolarLoop<Self> {
        SymetricBipolarLoop(loop: self)
    }
}

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
    static func inOutSin2(_ t: CGFloat) -> CGFloat {
        0.5 + sin(.pi * t - .pi / 2) / 2
    }
    static func inOutQuint(_ t: CGFloat) -> CGFloat {
        t < 0.5
            ? 16 * t * t * t * t * t
            : 1 + 16 * (t - 1) * t * t * t * t
    }
    static func inOutN(_ t: CGFloat, power: CGFloat) -> CGFloat {
        t < 0.5
            ? 0.5 * pow( 2 * t, power)
            : 1 - 0.5 * pow(2 * (1-t), power)
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
    static func triange(_ t: CGFloat, iterations: Int) -> CGFloat {
        let value = (t * CGFloat(iterations) * 2).truncatingRemainder(dividingBy: 2)
        return value <= 1 ? value : 2 - value
    }
    static func inExp(_ t: CGFloat, power: CGFloat = 2) -> CGFloat {
        pow(t, power)
    }
    static func perlinFade(_ t: CGFloat) -> CGFloat {
        t * t * t * (t * (t * 6 - 15) + 10)
    }
}
