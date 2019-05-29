//
//  AppDelegate.swift
//  Sarin
//
//  Created by Josh Zhe on 5/12/19.
//  Copyright © 2019 w4ftDev. All rights reserved.
//

import Cocoa
import KeychainAccess

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        killall(process: "arpspoof")
        killall(process: "tcpdump")
        toggleApache(state: "stop")
    
    }
}



