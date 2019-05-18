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
        tableView.delegate = self
        tableView.dataSource = self
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
    
    //MARK: Outlets
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    //MARK: Variables
    var hasBeenSetup:Bool = defaults.bool(forKey: "isInstalled")
    var data:[String] = []
    let location:String = defaults.string(forKey: "installLocation") ?? ""
    var scanDict = ["ip1": "mac1","ip2": "mac2","ip3": "mac3"]
    var ipList:[String] = []
    var macList:[String] = []
    var infoList:[String] = []
    var unparsedScan:String = ""
    
    //MARK: Parse Output Function
    func parseOutput(input: String){
        let characters = Array(input)
        
        var createdString: String = ""
        var listOfDeviceInfo: [String] = []

//        print(characters)
        for (_,character) in characters.enumerated(){
            if (character != "\t" && character != "\n"){
                createdString.append(character)
            }
            if (character == "\t" || character == "\n"){
//                print(createdString)
                listOfDeviceInfo.append(createdString)
                createdString = ""
            }
        }
//        print(listOfDeviceInfo)
//        print("listOfDevice Count: " + listOfDeviceInfo.count)
        
        for (index, string) in listOfDeviceInfo.enumerated(){
            if (index%3 == 0){
                ipList.append(string)
            }
            if (index%3 == 1){
                macList.append(string)
            }
            if (index%3 == 2){
                infoList.append(string)
            }
        }
    }
    
    //MARK: Scan Lan Function
    func scanLAN(){
        let task = Process.init()
        let pipe = Pipe.init()
        task.launchPath = "/bin/bash"
        task.arguments = ["--login",location+"/Sarin/sarin_scripts/arp-scan.sh"]
        task.standardOutput = pipe
        task.launch()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            task.waitUntilExit()
            group.leave()
        }
        group.notify(queue: .main) {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
//            print(output)
            self.unparsedScan = output! as String
            self.parseOutput(input: self.unparsedScan)
            self.progressSpinner.stopAnimation(self)
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func scanLanPressed(_ sender: NSButton) {
        progressSpinner.startAnimation(self)
        ipList = []
        macList = []
        infoList = []
        scanLAN()
        
    }
    lazy var SetupViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("WelcomeViewController"))
            as! NSViewController
    }()
    
    @objc func presentSheet(){
        SetupViewController.preferredContentSize = CGSize(width: 708, height: 447)
        self.presentAsSheet(SetupViewController)
    }

    

}
extension ViewController:NSTableViewDataSource,NSTableViewDelegate{
    
    fileprivate enum CellIdentifiers {
        static let ipCell = "ipCellID"
        static let macCell = "macCellID"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ipList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn == tableView.tableColumns[0]{
            data = ipList
        }
        if tableColumn == tableView.tableColumns[1]{
            data = macList
        }
        if tableColumn == tableView.tableColumns[2]{
            data = infoList
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ipCellID"), owner: self) as? NSTableCellView {
            cell.textField?.stringValue = self.data[row]
            return cell
        }
        return nil
    }
}


