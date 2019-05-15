//
//  bashFunctions.swift
//  Sarin
//
//  Created by Josh Zhe on 5/14/19.
//  Copyright © 2019 w4ftDev. All rights reserved.
//

import Foundation
let defaults = UserDefaults.standard
func gitClone(gitLink:String,installDestination:String){
    let task = Process.init()
    task.launchPath = "/usr/bin/git"
    task.arguments = ["clone", gitLink,installDestination]
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

func executeBashWithOutput(scriptLocation: String, param1:String) -> String{
    let task = Process()
    let pipe = Pipe()
    let script = """
do shell script "bash
""" + " " + scriptLocation + " " + "param1" + """
    "
    """
    task.launchPath = "/usr/bin/osascript"
    task.arguments = ["-e",script]
    task.standardOutput = pipe
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    
    return output! as String
    
    
}

func executeSudoBashWithOutput(scriptLocation: String, param1: String, param2: String, param3: String, username: String, password:String) -> String{
    let proc1 = Process()
    let pipe = Pipe()
    let script = """
do shell script "sudo bash
""" + " " + scriptLocation + " " + param1 + " " + param2 + " " + param3 + """
"
""" + " user name " + """
"
""" + username + """
"
""" + " password " + """
"
""" + password + """
"
""" + " with administrator privileges"
    proc1.launchPath = "/usr/bin/osascript"
    proc1.arguments = ["-e",script]
    proc1.standardOutput = pipe
    proc1.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    
    return output! as String
}

func executeSudoTestWithOutput(scriptLocation: String, param1: String, param2: String, param3: String, username: String, password:String) -> String{
    let proc1 = Process()
    let pipe = Pipe()
    let script = """
do shell script "sudo echo working
""" + " " + scriptLocation + " " + param1 + " " + param2 + " " + param3 + """
"
""" + " user name " + """
"
""" + username + """
"
""" + " password " + """
"
""" + password + """
"
""" + " with administrator privileges"
    proc1.launchPath = "/usr/bin/osascript"
    proc1.arguments = ["-e",script]
    proc1.standardOutput = pipe
    proc1.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    
    return output! as String
}
