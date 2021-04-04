//
//  AppDelegate.swift
//  Meetings
//
//  Created by Ryan Cavanagh on 3/27/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        // Insert code here to initialize your application
//    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let em = NSAppleEventManager.shared()
        em.setEventHandler(self, andSelector: #selector(self.getUrl(_:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    @objc func getUrl(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        // Get the URL
        let urlStr: String = event.paramDescriptor(forKeyword: keyDirectObject)!.stringValue!
        print(urlStr);

    }
    
}

