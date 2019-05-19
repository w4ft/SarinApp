//
//  ViewController.swift
//  Sarin
//
//  Created by Josh Zhe on 5/12/19.
//  Copyright © 2019 w4ftDev. All rights reserved.
//

import Cocoa
import KeychainAccess

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        attackButton.isEnabled = false
        stopAttacksButton.isEnabled = false
        setRouterButton.isEnabled = false
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
    @IBOutlet weak var attackButton: NSButton!
    @IBOutlet weak var setRouterButton: NSButton!
    @IBOutlet weak var stopAttacksButton: NSButton!
    
    //MARK: Variables
    var hasBeenSetup:Bool = defaults.bool(forKey: "isInstalled")
    var data:[String] = []
//    let location:String = defaults.string(forKey: "installLocation") ?? ""
    
//    let keychain = Keychain(service: "Sarin")
    
    var scanDict = ["ip1": "mac1","ip2": "mac2","ip3": "mac3"]
    var ipList:[String] = []
    var macList:[String] = []
    var infoList:[String] = []
    var unparsedScan:String = ""
    @IBOutlet weak var wifiKillerModeSwitch: NSButton!
    
    var rowIndexes:[Int] = []
    
    var routerIP:String = ""
    
    var currentDevices:[String] = []
    
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
    
    //Mark: Function to get a list of IPs from the selected rows
    func getIPsFromRowIndexes() -> [String]{
        var ipsFromRowIndexes: [String] = []
        
        for (_,rowIndex) in rowIndexes.enumerated(){
            ipsFromRowIndexes.append(ipList[rowIndex])
        }
        return ipsFromRowIndexes
    }

    func attackUsers(){
        for (_,user) in currentDevices.enumerated(){
            let task = Process.init()
            task.launchPath = "/bin/bash"
            task.arguments = (["--login",location+"/Sarin/sarin_scripts/arpspoof.sh", user,routerIP,keychain[NSUserName()]] as! [String])
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
    @IBAction func setRouterIP(_ sender: Any) {
        routerIP = ipList[tableView.selectedRowIndexes.map { Int($0) }[0]]
        setRouterButton.isEnabled = false
        tableView.reloadData()
    }
    
    @IBAction func attackButtonPressed(_ sender: NSButton) {
        currentDevices = getIPsFromRowIndexes()
//        print(currentDevices)
        tableView.reloadData()
        attackUsers()
        stopAttacksButton.isEnabled = true
        attackButton.isEnabled = false
        setRouterButton.isEnabled = false
        wifiKillerModeSwitch.isEnabled = false
    }
    
    @IBAction func stopAttackButtonPressed(_ sender: Any) {
        currentDevices = []
        tableView.reloadData()
        killall()
        attackButton.isEnabled = true
        stopAttacksButton.isEnabled = false
        wifiKillerModeSwitch.isEnabled = true
    }
    
    @IBAction func wifiKillModeSwitchPressed(_ sender: NSButton) {
        switch sender.state{
        case .on:
            setPackets(state: "0")
        case .off:
            setPackets(state: "1")
        default:
            setPackets(state: "1")
        }
    }
    
    

}
extension ViewController:NSTableViewDataSource,NSTableViewDelegate{
    
    fileprivate enum CellIdentifiers {
        static let ipCell = "ipCellID"
        static let macCell = "macCellID"
    }

    
    func updateSelectionStatus(){
        let itemsSelected:Int = tableView.selectedRowIndexes.count
        
//        print(tableView.selectedRowIndexes.map { Int($0) })
        
        attackButton.title = "Attack Selected Devices " + "(" + String(itemsSelected) + ")"
        
        if (itemsSelected != 0){
            setRouterButton.isEnabled = true
            if routerIP != ""{
                attackButton.isEnabled = true
            }
        }else{
            attackButton.isEnabled = false
            setRouterButton.isEnabled = false
        }
        
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        rowIndexes = tableView.selectedRowIndexes.map { Int($0) }
        updateSelectionStatus()
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
            
            if currentDevices.contains(ipList[row]){
//                print(currentDevices)
                
                cell.textField?.textColor = NSColor.red
                cell.textField?.stringValue = self.data[row]
//                print(ipList[row])
                
                return cell
            }
            if routerIP==ipList[row]{
//                print(currentDevices)
                
                cell.textField?.textColor = NSColor.systemBlue
                cell.textField?.stringValue = self.data[row]
//                print(ipList[row])
                
                return cell
            }
            cell.textField?.textColor = NSColor.controlTextColor
            cell.textField?.stringValue = self.data[row]
            return cell
        }
        return nil
    }
}


