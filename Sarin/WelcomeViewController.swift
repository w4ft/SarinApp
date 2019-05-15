//
//  SetupViewController.swift
//  Sarin
//
//  Created by Josh Zhe on 5/12/19.
//  Copyright © 2019 w4ftDev. All rights reserved.
//

import Cocoa

class WelcomeViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    @IBOutlet weak var secondaryHeaderLabel: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var bodyLabel: NSTextField!
    @IBOutlet weak var blueButton: NSButton!
    @IBOutlet weak var disclaimerLabel: NSTextField!
    
    var buttoncount:Int = 0
    
    lazy var SetupViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SetupViewController"))
            as! NSViewController
    }()
    
    @IBAction func showSetupPage(_ sender: Any) {
        //Set Labels and Button to Setup Page
        if buttoncount == 0{
            
            SetupViewController.preferredContentSize = CGSize(width: 708, height: 447)
            self.presentAsSheet(SetupViewController)
            titleLabel.stringValue = "You are all set!"
            secondaryHeaderLabel.isHidden = true
            bodyLabel.isHidden = true
            blueButton.title = "Go"
            disclaimerLabel.isHidden = true
            buttoncount = 1
        }
        else if buttoncount == 1{
            dismiss(self)
        }

       
    }
}
