//
//  AppDelegate.swift
//  Meetings
//
//  Created by Ryan Cavanagh on 3/27/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
//    private lazy var preferenceWindow = NSStoryboard(name: "Preferences", bundle: nil)
//    private lazy var preferenceWindowController = preferenceWindow.instantiateController(withIdentifier: "Preferences") as? NSWindowController
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
//    @IBAction func openPreferences(_ sender: Any) {
//        if preferenceWindow == nil {
//            preferenceWindow = NSStoryboard(name: "Preferences", bundle: nil)
//            preferenceWindowController = preferenceWindow.instantiateController(withIdentifier: "Preferences") as? NSWindowController ?? NSWindowController()
//        }
//        if !(preferenceWindowController?.isWindowLoaded ?? false) {
//            preferenceWindowController?.showWindow(self)
//        }
//    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

    }

    
}

