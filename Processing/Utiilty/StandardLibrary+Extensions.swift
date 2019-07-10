//
//  StandardLibrary+Extensions.swift
//  Processing
//
//  Created by Matthew Johnson on 6/23/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

extension ClosedRange where Bound: FloatingPoint {
    func position(of value: Bound) -> Bound {
        (value - lowerBound) / size
    }
}
extension ClosedRange where Bound: AdditiveArithmetic {
    var size: Bound {
        upperBound - lowerBound
    }
}
extension FloatingPoint {
    static var tau: Self { .pi * 2 }
    func clamped(to: ClosedRange<Self>) -> Self {
        guard self > to.lowerBound else { return to.lowerBound }
        guard self < to.upperBound else { return to.upperBound }
        return self
    }
    func position(in range: ClosedRange<Self>) -> Self {
        range.position(of: self)
    }
    func remap(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
        to.lowerBound + to.size * from.position(of: self)
    }
}
