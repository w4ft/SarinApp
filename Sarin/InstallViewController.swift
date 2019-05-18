//
//  InstallViewController.swift
//  Sarin
//
//  Created by Josh Zhe on 5/12/19.
//  Copyright © 2019 w4ftDev. All rights reserved.
//

import Cocoa
import KeychainAccess

class InstallViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        installDependenciesLabel.isHidden = true
        cloneDsniffLabel.isHidden = true
        installDsniffLabel.isHidden = true
        finishButton.isEnabled = false

    }
    
    override func viewDidAppear() {
        gitCloneSarin() //calls catalyric function
    }
    
    
    let location:String = defaults.string(forKey: "installLocation")!
    
    let keychain = Keychain(service: "Sarin")
    
    //Start of catalytic function to install Dsniff
    func gitCloneSarin(){
        let task = Process.init()
        task.launchPath = "/usr/bin/git"
        task.arguments = ["clone", "https://github.com/w4ft/Sarin.git",location+"/Sarin"]
        task.launch()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            task.waitUntilExit()
            group.leave()
        }
        group.notify(queue: .main) {
            self.statusOfSarinScripts.image = NSImage(named: "Completed Status")
            self.installDependenciesLabel.isHidden = false
            self.cloneSarinLabel.stringValue = "Successfully installed Sarin scripts."
            self.installDependencies()
            
        }
    }
    func installDependencies(){
        let task = Process.init()
        task.launchPath = "/bin/bash"
        task.arguments = ["--login",location+"/Sarin/sarin_scripts/installDependencies.sh"]
        task.launch()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            task.waitUntilExit()
            group.leave()
        }
        group.notify(queue: .main) {
            self.statusOfDependencies.image = NSImage(named: "Completed Status")
            self.installDependenciesLabel.stringValue = "Successfully installed dependencies."
            self.cloneDsniffLabel.isHidden = false
            self.gitCloneDsniff()
        }
    }
    func gitCloneDsniff(){
        let task = Process.init()
        task.launchPath = "/usr/bin/git"
        task.arguments = ["clone", "https://github.com/ggreer/dsniff.git",location+"/dsniff"]
        task.launch()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            task.waitUntilExit()
            group.leave()
        }
        group.notify(queue: .main) {
            self.statusOfDownloadDsniff.image = NSImage(named: "Completed Status")
            self.cloneDsniffLabel.stringValue = "Successfully downloaded Dsniff."
            self.installDsniffLabel.isHidden = false
            self.compileDsniff()
        }
    }
    func compileDsniff(){
        let task = Process.init()
        task.launchPath = "/bin/bash"
        task.arguments = ["--login",location+"/Sarin/sarin_scripts/compile.sh",location+"/dsniff"]
        task.launch()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            task.waitUntilExit()
            group.leave()
        }
        group.notify(queue: .main) {
            self.installDsniffLabel.stringValue = "Running makefile..."
            self.makeDsniff()
        }
    }
    func makeDsniff(){
        let task = Process.init()
        task.launchPath = "/bin/bash"
        task.arguments = ["--login",location+"/Sarin/sarin_scripts/make.sh",location+"/dsniff"]
        task.launch()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            task.waitUntilExit()
            group.leave()
        }
        group.notify(queue: .main) {
            self.installDsniffLabel.stringValue = "Installing..."
            self.installDsniff()
        }
    }
    func installDsniff(){
        let task = Process.init()
        task.launchPath = "/bin/bash"
        task.arguments = ["--login",location+"/Sarin/sarin_scripts/install.sh",location+"/dsniff",keychain[NSUserName()]!]
        task.launch()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            task.waitUntilExit()
            group.leave()
        }
        group.notify(queue: .main) {
            self.statusOfInstallDsniff.image = NSImage(named: "Completed Status")
            self.titleLabel.stringValue = "Installed."
            self.installDsniffLabel.stringValue = "Installed"
            self.finishButton.isEnabled = true

        }
    }
    //End of catalytic function
 
    //Outlets
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var statusOfSarinScripts: NSImageView!
    @IBOutlet weak var statusOfDependencies: NSImageView!
    @IBOutlet weak var statusOfDownloadDsniff: NSImageView!
    @IBOutlet weak var statusOfInstallDsniff: NSImageView!
    @IBOutlet weak var finishButton: NSButton!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var cloneSarinLabel: NSTextField!
    @IBOutlet weak var installDependenciesLabel: NSTextField!
    @IBOutlet weak var cloneDsniffLabel: NSTextField!
    @IBOutlet weak var installDsniffLabel: NSTextField!
    
    @IBAction func finishPressed(_ sender: Any) {
        
        finishButton.title = "Finishing..."
        progressIndicator.startAnimation(self)
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "isInstalled")
        
        //Check if correct paths are written, if not, writes them
        print(executeBashWithOutput(scriptLocation: location+"/Sarin/sarin_scripts/checkPaths.sh", param1: ""))
        if !(executeBashWithOutput(scriptLocation: location+"/Sarin/sarin_scripts/checkPaths.sh", param1: "").contains("azazaz")){
            _ = executeSudoBashWithOutput(scriptLocation: location+"/Sarin/sarin_scripts/addPaths.sh", param1: "", param2: "", param3: "", username: NSUserName(), password: keychain[NSUserName()]!)
        }
        progressIndicator.stopAnimation(self)
        
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
