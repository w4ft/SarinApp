//
//  PreferencesViewController.swift
//  Sarin
//
//  Created by Josh Zhe on 5/18/19.
//  Copyright © 2019 w4ftDev. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    let location:String = defaults.string(forKey: "installLocation") ?? ""
    
    @IBAction func updateScriptsPressed(_ sender: Any) {
        
        let task = Process.init()
        task.launchPath = "/usr/bin/git"
        task.arguments = ["-C",location+"/Sarin", "pull"]
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
