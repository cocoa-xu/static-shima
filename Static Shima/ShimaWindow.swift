//
//  ShimaWindow.swift
//  static shima
//
//  Created by Cocoa on 08/09/2022.
//

import Foundation
import Cocoa

class ShimaWindow: NSWindow {
    let width = 420.0
    var maxY = 0.0

    func makeShimaRect() -> NSRect {
        let withNotch = NSScreen.screens.filter({ screen in
            screen.safeAreaInsets.top != 0
        }).first

        var rect: NSRect = NSMakeRect(0, 0, 0, 0)
        if withNotch != nil {
            let screenRect = withNotch!.visibleFrame
            let newOriginX = (screenRect.maxX - width) / 2
            self.maxY = screenRect.maxY
            rect = NSMakeRect(newOriginX, self.maxY, width, withNotch!.safeAreaInsets.top)
        }
        return rect
    }

    func makeShima() {
        let rect = makeShimaRect()
        self.setFrame(rect, display: true)
    }

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        let withNotch = NSScreen.screens.filter({ screen in
            screen.safeAreaInsets.top != 0
        }).first

        var rect: NSRect = NSMakeRect(0, 0, 0, 0)
        if withNotch != nil {
            let screenRect = withNotch!.visibleFrame
            let newOriginX = (screenRect.maxX - width) / 2
            self.maxY = screenRect.maxY
            rect = NSMakeRect(newOriginX, self.maxY, width, withNotch!.safeAreaInsets.top)
        }

        super.init(contentRect: rect, styleMask: style, backing: backingStoreType, defer: flag)
        setupWindow()
    }

    override func setFrame(_ frameRect: NSRect, display flag: Bool) {
        if frameRect.origin.y != self.maxY {
            return
        }
        super.setFrame(frameRect, display: flag)
    }

    func setupWindow() {
        isOpaque = false
        backgroundColor = NSColor.clear
        isMovableByWindowBackground = true
        styleMask = .borderless
    }
}
