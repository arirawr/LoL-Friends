//
//  AppDelegate.swift
//  LoL Friends
//
//  Created by Arielle Vaniderstine on 2017-01-02.
//  Copyright © 2017 Citron Digital. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let popover = NSPopover()
    
    @IBOutlet weak var friendViewController: FriendViewController!
    
    var statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        popover.contentViewController = friendViewController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func setupStatusItem() {
        let icon = NSImage(named: "NSAdvanced")
        icon!.isTemplate = true // makes it black/white
        statusItem.image = icon
        statusItem.target = self
        statusItem.action = #selector(togglePopover)
    }
    
    func showWindow(sender: Any) {
        //show NSPopoverView at sender as sender.frame.origin
    }
    
    /* Popover stuff for listening for clicks outside the configure window */
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }


}

