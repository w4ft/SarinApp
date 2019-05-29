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

    }
    
    @IBOutlet weak var toggleHelpButton: NSButton!
    
    @IBAction func toggleHelpButtonPressed(_ sender: Any){
        
        print(helpIsEnabled)
        
        if helpIsEnabled{
            toggleHelpButton.title = "Show Help Buttons"
            helpIsEnabled = false
            
//        dnsspoofConfigureViewController().viewDidAppear()
        }else{
            toggleHelpButton.title = "Hide Help Buttons"
            helpIsEnabled = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
//        dnsspoofConfigureViewController().viewDidAppear()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
        
    }
    
    
    
    @IBAction func resetDeafultsPressed(_ sender: Any) {
        let task = Process.init()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["delete","w4ft.Sarin"]
        task.launch()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            task.waitUntilExit()
            group.leave()
        }
        group.notify(queue: .main) {
            let a = NSAlert()
            a.messageText = "Sarin needs to restart"
            a.informativeText = "Click restart to close Sarin"
            a.addButton(withTitle: "Restart Sain")
            a.addButton(withTitle: "Cancel")
            a.alertStyle = NSAlert.Style.warning
            
            a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
                if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                    exit(0)
                }
            })

        }

    }
    
    
}
