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

func getRouterIP () -> String{
    let go = Process()
    let pipe = Pipe()
    go.launchPath = "/usr/sbin/netstat"
    go.arguments = ["-nr", "|", "grep","default"]
    
    var ip = " "
    go.standardOutput = pipe
    go.launch()
    print("hi")
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    let string : String = output! as String
    let characters = Array(string)
    var counter = 0
    for (index,character) in characters.enumerated(){
        let num = Int(String(character))
        if num != nil {
            counter = index
            break
        }
    }
    while true{
        if characters[counter] == " "{
            break
        }
        
        ip.append(characters[counter])
        counter = counter+1
        
    }
    ip.remove(at: String.Index(encodedOffset: 0))
    return ip
}

