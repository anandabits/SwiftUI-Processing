//
//  CoreGraphics+Extensions.swift
//  ImagePaintPicker
//
//  Created by Matthew Johnson on 7/17/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    init(size: CGSize) {
        self.init(x: size.width, y: size.height)
    }

    static prefix func - (point: CGPoint) -> CGPoint {
        CGPoint(x: -point.x, y: -point.y)
    }
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
    static func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    static func *= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x *= rhs.x
        lhs.y *= rhs.y
    }
    static func / (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    static func /= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x /= rhs.x
        lhs.y /= rhs.y
    }

    static func / (point: CGPoint, scale: CGFloat) -> CGPoint {
        CGPoint(x: point.x / scale, y: point.y / scale)
    }
    static func /= (point: inout CGPoint, scale: CGFloat) {
        point.x /= scale
        point.y /= scale
    }
    static func * (point: CGPoint, scale: CGFloat) -> CGPoint {
        CGPoint(x: point.x * scale, y: point.y * scale)
    }
    static func *= (point: inout CGPoint, scale: CGFloat) {
        point.x *= scale
        point.y *= scale
    }
}

extension CGSize {
    init(point: CGPoint) { self.init(width: point.x, height: point.y) }

    var aspectRatio: CGFloat { width / height }

    static var unit: CGSize { CGSize(width: 1, height: 1) }

    static prefix func - (size: CGSize) -> CGSize {
        CGSize(width: -size.width, height: -size.height)
    }
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func += (lhs: inout CGSize, rhs: CGSize) {
        lhs.width += rhs.width
        lhs.height += rhs.height
    }
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    static func -= (lhs: inout CGSize, rhs: CGSize) {
        lhs.width -= rhs.width
        lhs.height -= rhs.height
    }
    static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
    static func *= (lhs: inout CGSize, rhs: CGSize) {
        lhs.width *= rhs.width
        lhs.height *= rhs.height
    }
    static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
    static func /= (lhs: inout CGSize, rhs: CGSize) {
        lhs.width /= rhs.width
        lhs.height /= rhs.height
    }

    static func / (size: CGSize, scale: CGFloat) -> CGSize {
        CGSize(width: size.width / scale, height: size.height / scale)
    }
    static func /= (size: inout CGSize, scale: CGFloat) {
        size.width /= scale
        size.height /= scale
    }
    static func * (size: CGSize, scale: CGFloat) -> CGSize {
        CGSize(width: size.width * scale, height: size.height * scale)
    }
    static func *= (size: inout CGSize, scale: CGFloat) {
        size.width *= scale
        size.height *= scale
    }
}

extension CGRect {
    static var unit: CGRect {
        CGRect(x: 0, y: 0, width: 1, height: 1)
    }

    var aspectRatio: CGFloat {
        width / height
    }
}
