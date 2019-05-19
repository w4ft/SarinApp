//
//  mainFunctions.swift
//  Sarin
//
//  Created by Josh Zhe on 5/18/19.
//  Copyright © 2019 w4ftDev. All rights reserved.
//

import Foundation
import KeychainAccess

let keychain = Keychain(service: "Sarin")

let location:String = defaults.string(forKey: "installLocation") ?? ""

func killall(){
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

func setPackets(state:String){
    let task = Process.init()
    let pipe = Pipe.init()
    task.launchPath = "/bin/bash"
    task.arguments = ["--login",location+"/Sarin/sarin_scripts/enablePackets.sh",state, keychain[NSUserName()]] as? [String]
    task.standardOutput = pipe
    task.launch()
    let group = DispatchGroup()
    group.enter()
    DispatchQueue.global().async {
        task.waitUntilExit()
        group.leave()
    }
}


