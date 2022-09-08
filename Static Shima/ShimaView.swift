//
//  ShimaView.swift
//  static shima
//
//  Created by Cocoa on 08/09/2022.
//

import Foundation
import Cocoa

class ShimaView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()
        let rectangleCornerRadius: CGFloat = 10
        let rectangleRect = dirtyRect
        let rectangleInnerRect = rectangleRect.insetBy(dx: rectangleCornerRadius, dy: rectangleCornerRadius)
        let rectanglePath = NSBezierPath()
        rectanglePath.appendArc(withCenter: NSPoint(x: rectangleInnerRect.minX, y: rectangleInnerRect.minY), radius: rectangleCornerRadius, startAngle: 180, endAngle: 270)
        rectanglePath.appendArc(withCenter: NSPoint(x: rectangleInnerRect.maxX, y: rectangleInnerRect.minY), radius: rectangleCornerRadius, startAngle: 270, endAngle: 360)
        rectanglePath.line(to: NSPoint(x: rectangleRect.maxX, y: rectangleRect.maxY))
        rectanglePath.line(to: NSPoint(x: rectangleRect.minX, y: rectangleRect.maxY))
        rectanglePath.close()
        NSColor(red: 0, green: 0, blue: 0, alpha: 1).setFill()
        rectanglePath.fill()
        NSGraphicsContext.restoreGraphicsState()
    }
}
