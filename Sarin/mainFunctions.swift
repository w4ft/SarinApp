//
//  mainFunctions.swift
//  Sarin
//
//  Created by Josh Zhe on 5/18/19.
//  Copyright © 2019 w4ftDev. All rights reserved.
//

import Foundation
import KeychainAccess

func killall(){
    let keychain = Keychain(service: "Sarin")
    let location:String = defaults.string(forKey: "installLocation") ?? ""
    let hasBeenSetup:Bool = defaults.bool(forKey: "isInstalled")
    if hasBeenSetup{
        let task = Process.init()
        task.launchPath = "/bin/bash"
        task.arguments = ([location+"/Sarin/sarin_scripts/killall.sh", keychain[NSUserName()]] as! [String])
        task.launch()
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.global().async {
            task.waitUntilExit()
            group.leave()
        }
        group.notify(queue: .main) {
            
        }
    }
}
