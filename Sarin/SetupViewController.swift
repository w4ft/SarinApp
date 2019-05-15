//
//  SetupViewController.swift
//  Sarin
//
//  Created by Josh Zhe on 5/14/19.
//  Copyright © 2019 w4ftDev. All rights reserved.
//

import Cocoa
import KeychainAccess


class SetupViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        filePathTextField.stringValue = "/Users/" + NSUserName()
        usernameTextField.stringValue = NSUserName()
        incorrectAlert.isHidden = true
        
        // Do view setup here.
    }
    
    
    lazy var InstallViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("InstallViewController"))
            as! NSViewController
    }()
    
    @IBOutlet weak var filePathTextField: NSTextField!
    @IBOutlet weak var incorrectAlert: NSTextField!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    
    @IBAction func browseFile(sender: AnyObject) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose install location";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                filePathTextField.stringValue = path
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        
    
            
       
        
        let userID = usernameTextField.stringValue
        let passID = passwordTextField.stringValue
        let go = Process()
        let pipe = Pipe()
        let script = "do shell script \"sudo echo ajklz\"" + " user name " + """
"
""" + userID + """
"
""" + " password " + """
"
""" + passID + """
"
""" + " with administrator privileges"
        go.launchPath = "/usr/bin/osascript"
        go.arguments = ["-e",script]
        
        
        go.standardOutput = pipe
        go.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let string : String = output! as String
        if string.contains("ajklz"){
            let keychain = Keychain(service: "Sarin")
            keychain[NSUserName()] = passwordTextField.stringValue
            let defaults = UserDefaults.standard
            defaults.set(filePathTextField.stringValue, forKey: "installLocation")
            
            self.presentAsSheet(InstallViewController)
        }
        else{
            incorrectAlert.isHidden = false
        }
            

        
        

        
    }

        
    
    
}
