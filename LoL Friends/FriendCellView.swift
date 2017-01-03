//
//  FriendCellView.swift
//  LoL Friends
//
//  Created by Arielle Vaniderstine on 2017-01-03.
//  Copyright © 2017 Citron Digital. All rights reserved.
//

import Cocoa

class FriendCellView: NSTableCellView {
    
    @IBOutlet weak var button: NSButton!
    @IBOutlet weak var statusBox: NSBox!
    @IBOutlet weak var regionTextField: NSTextField!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
