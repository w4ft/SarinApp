//
//  dnsspoofConfigureViewController.swift
//  Sarin
//
//  Created by Josh Zhe on 5/25/19.
//  Copyright © 2019 w4ftDev. All rights reserved.
//

import Cocoa

class dnsspoofConfigureViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidAppear), name: NSNotification.Name(rawValue: "load"), object: nil)

        
        ownIP = String(getOwnIP().filter { !" \n".contains($0) })
        
        urlTextField.stringValue = UserDefaults.standard.string(forKey: "lastTextFieldEntry") ?? ""
//        toggleApache(state: "start")
        sucessCloneText.isHidden = true
        listOfSites = UserDefaults.standard.stringArray(forKey: "listOfSites") ?? [String]()
//        listOfClones = UserDefaults.standard.stringArray(forKey: "listOfClones") ?? [String]()
        segmentedControl.setEnabled(false, forSegment: 0)
        tableView.delegate = self
        tableView.dataSource = self
        // Do view setup here.
    }
    override func viewDidAppear() {
        segmentedControl.setEnabled(false, forSegment: 0)
        segmentedControl.setSelected(false, forSegment: 0)
        if helpIsEnabled{
            dnsHelpButton.isHidden = false
        }else{
            dnsHelpButton.isHidden = true
        }
    }
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var apacheCheckButton: NSButton!
    @IBOutlet weak var dnsHelpButton: NSButton!
    
    @IBOutlet weak var savedButton: NSButton!
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    @IBOutlet weak var imageView: NSImageView!
    
    @IBOutlet weak var sucessCloneText: NSTextField!
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    
    var rowIndexes:[Int] = []
    var ownIP: String = ""
    var hostStringList:[String] = []
    var listOfSites: [String] = []
    var siteLocation: String = ""
    var listOfClones: [String] = []
    
    
    @IBAction func stopClone(_ sender: Any) {
        killall(process: "httrack")
        killall(process: "pageres")
        progressSpinner.stopAnimation(self)
    }
    func removeTempPreview(){
        let task = Process.init()
        task.launchPath = "/bin/bash"
        let fileName = location+"/"+ownIP+"-1366x768-cropped.png"
        print(fileName)
        task.arguments = ["--login",location+"/Sarin/sarin_scripts/removePreview.sh",fileName]
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
    
    func showPreview(){
        
        let task = Process.init()
        task.launchPath = "/bin/bash"
        task.arguments = ["--login",location+"/Sarin/sarin_scripts/getPreview.sh",location,"http://"+ownIP]
        task.launch()
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.global().async {
            task.waitUntilExit()
            group.leave()
        }
        group.notify(queue: .main) {
            
            self.imageView.image = NSImage(contentsOfFile: location+"/"+self.ownIP+"-1366x768-cropped.png")
            self.progressSpinner.stopAnimation(self)
            sleep(UInt32(0.5))
            self.removeTempPreview()
            self.sucessCloneText.isHidden = false
            self.sucessCloneText.textColor = NSColor.systemGreen
            self.sucessCloneText.stringValue = "Cloned and Saved!"
            
        }
    }

    
    @IBAction func browseFile(sender: AnyObject) {
        
        let dialog = NSOpenPanel();
        
        let launcherLogPathWithTilde = (location+"/ClonedSites") as NSString
        let expandedLauncherLogPath = launcherLogPathWithTilde.expandingTildeInPath
        
        dialog.directoryURL = NSURL.fileURL(withPath: expandedLauncherLogPath, isDirectory: true)
        
        dialog.title                   = "Choose Website Folder";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            progressSpinner.startAnimation(self)
            if (result != nil) {
                let path = result!.path
                siteLocation = path
                let siteLocationShort = siteLocation.replacingOccurrences(of: location+"/ClonedSites/", with: "", options: .literal, range: nil)
                
                let task = Process.init()
                task.launchPath = "/bin/bash"
                task.arguments = ["--login",location+"/Sarin/sarin_scripts/setSites.sh",siteLocation,keychain[NSUserName()]] as? [String]
                task.launch()
                
                let group = DispatchGroup()
                group.enter()
                
                DispatchQueue.global().async {
                    task.waitUntilExit()
                    group.leave()
                }
                group.notify(queue: .main) {
                
                    self.sucessCloneText.isHidden = false
                    self.sucessCloneText.textColor = NSColor.systemGreen
                    self.sucessCloneText.stringValue = "Fake site set to: " + siteLocationShort
                    self.progressSpinner.stopAnimation(self)
                    self.showPreview()
                }
               
                
               
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    func removeExtraUrl(url:String) -> String{
        let aString = url
        let newString = aString.replacingOccurrences(of: "www.", with: "", options: .literal, range: nil)
        let newString2 = newString.replacingOccurrences(of: "https://", with: "", options: .literal, range: nil)
        return newString2
    }
    
    @IBAction func cloneButtonPressed(_ sender: Any) {
        
        let shortURL:String = removeExtraUrl(url: urlTextField.stringValue)
        
        if !(listOfClones.contains(shortURL)){
            progressSpinner.startAnimation(self)
            listOfClones.insert(shortURL, at: 0)
            UserDefaults.standard.set(listOfClones, forKey: "listOfClones")
            self.sucessCloneText.stringValue = ""
            let task = Process.init()
            task.launchPath = "/bin/bash"
            task.arguments = ["--login",location+"/Sarin/sarin_scripts/httrack.sh",shortURL,location+"/ClonedSites",keychain[NSUserName()]] as? [String]
            task.launch()
            
            let group = DispatchGroup()
            group.enter()
            
            DispatchQueue.global().async {
                task.waitUntilExit()
                group.leave()
            }
            group.notify(queue: .main) {
                self.showPreview()
                
                
            }
        }else{
            sucessCloneText.isHidden = false
            sucessCloneText.textColor = NSColor.systemRed
            sucessCloneText.stringValue = "Site Already Saved, Browse Below"
        }
       
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        clearFile()
        UserDefaults.standard.set(listOfSites, forKey: "listOfSites")
        UserDefaults.standard.set(urlTextField.stringValue, forKey: "lastTextFieldEntry")
        
        
        print(ownIP)
        parseListIntoText()
        print(hostStringList)
        addTextToFile()
        hostStringList = []
        sucessCloneText.isHidden = true
        dismiss(self)
    }
    
    func parseListIntoText(){
        for (_,site) in listOfSites.enumerated(){
            hostStringList.insert(ownIP + """
\t
""" + site, at: 0)
        }
    }
    
    func addTextToFile(){
        for (_,line) in hostStringList.enumerated(){
            addLine(text: line)
        }
    }
    
    func getOwnIP()-> String{
        let go = Process()
        let pipe = Pipe()
        go.launchPath = "/bin/bash"
        go.arguments = [location+"/Sarin/sarin_scripts/getOwnIP.sh",]
        go.standardOutput = pipe
        go.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        go.waitUntilExit()
        return output! as String

    }
    
    func addLine(text:String){
        let go = Process()
        go.launchPath = "/bin/bash"
        go.arguments = [location+"/Sarin/sarin_scripts/editHosts.sh",text,location+"/dnsspoof.txt"]
        go.launch()
    }
    
    func clearFile(){
        let go = Process()
        go.launchPath = "/bin/bash"
        go.arguments = [location+"/Sarin/sarin_scripts/clearText.sh",location+"/dnsspoof.txt"]
        go.launch()
    }
    
    
    @IBAction func segmentedControlPressed(_ sender: Any) {
        if (segmentedControl.selectedSegment == 0){
            segmentedControl.setEnabled(false, forSegment: 0)
            listOfSites.remove(at: rowIndexes[0])
            tableView.reloadData()
        }else{
            listOfSites.insert("New Filter", at: 0)
            tableView.reloadData()
        }
    }

    
   
}
extension dnsspoofConfigureViewController:NSTableViewDataSource,NSTableViewDelegate{

    func updateSelectionStatus(){
        let itemsSelected:Int = tableView.selectedRowIndexes.count
        if itemsSelected == 0{
            segmentedControl.setEnabled(false, forSegment: 0)
        }else{
           segmentedControl.setEnabled(true, forSegment: 0)
        }

    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        rowIndexes = tableView.selectedRowIndexes.map { Int($0) }
        updateSelectionStatus()

    }
    

    func numberOfRows(in tableView: NSTableView) -> Int {
        return listOfSites.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: self) as? NSTableCellView {
            
            cell.textField?.stringValue = self.listOfSites[row]
            return cell
        }
        return nil
    }
}
extension dnsspoofConfigureViewController: NSControlTextEditingDelegate {
    func controlTextDidChange(_ notification: Notification) {
        if let textField = notification.object as? NSTextField {
            listOfSites[rowIndexes[0]] = textField.stringValue
        }
    }
}
