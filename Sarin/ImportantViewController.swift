//
//  ImportantViewController.swift
//  Sarin
//
//  Created by Josh Zhe on 5/16/19.
//  Copyright © 2019 w4ftDev. All rights reserved.
//

import Cocoa

class ImportantViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        notInstalledText.isHidden = true

        // Do view setup here.
    }
    
    @IBOutlet weak var notInstalledText: NSTextField!
    @IBOutlet weak var homebrewText: NSTextField!
    @IBOutlet weak var xcodeText: NSTextField!
    
    lazy var SetupViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SetupViewController"))
            as! NSViewController
    }()
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        
        let xcodeStatus: String = executeCommandWithOutput(command: "xcode-select -p 1>/dev/null;echo $? #return 0 if installed, 2 otherwise")
        let brewStatus:String = executeCommandWithOutput(command: """
command -v brew >/dev/null 2>&1 || { echo >&2 "b";}
""")
        
        if (xcodeStatus == "2") || (brewStatus == "b"){
            notInstalledText.isHidden = false
        } else{
            SetupViewController.preferredContentSize = CGSize(width: 708, height: 447)
            self.presentAsSheet(SetupViewController)
        }
        
    }
    
}
