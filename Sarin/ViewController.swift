//
//  ViewController.swift
//  Sarin
//
//  Created by Josh Zhe on 5/12/19.
//  Copyright © 2019 w4ftDev. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        hasBeenSetup = false
        //Show Setup Page on Start if hasBeenSetup == false
        if !hasBeenSetup{
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(presentSheet), userInfo: nil, repeats: false)
        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //Variables
    var hasBeenSetup:Bool = defaults.bool(forKey: "isInstalled")
    

    
    
    lazy var SetupViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("WelcomeViewController"))
            as! NSViewController
    }()
    
    @objc func presentSheet(){
        SetupViewController.preferredContentSize = CGSize(width: 708, height: 447)
        self.presentAsSheet(SetupViewController)
    }

    

}

