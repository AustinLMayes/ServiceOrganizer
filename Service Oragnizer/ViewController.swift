//
//  ViewController.swift
//  Test
//
//  Created by Austin Mayes on 10/18/14.
//  Copyright (c) 2014 Austin Mayes. All rights reserved.
//

import Cocoa
import Foundation

class ViewController: NSViewController {
    
    // Options
    @IBOutlet weak var serviceType: NSTextField!
    @IBOutlet weak var videoFormat: NSComboBox!
    
    // Directory
    @IBOutlet weak var recursive: NSButton!
    @IBOutlet weak var filePath: NSPathCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceType.becomeFirstResponder()
        videoFormat.selectItemAtIndex(0)
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func displayAlert(missing:NSString) {
        var oAlert:NSAlert = NSAlert()
        oAlert.messageText = "Oh No!";
        oAlert.informativeText = "You forgot to specify the " + missing + "!";
        oAlert.alertStyle = NSAlertStyle.WarningAlertStyle;
        oAlert.beginSheetModalForWindow(self.view.window!, completionHandler: nil)
    }
    
    func displaySuccess() {
        var oAlert:NSAlert = NSAlert()
        oAlert.messageText = "Congradulation, You did it!";
        oAlert.informativeText = "All of the services have been organized!";
        oAlert.alertStyle = NSAlertStyle.InformationalAlertStyle;
        oAlert.beginSheetModalForWindow(self.view.window!, completionHandler: nil)
    }
    
    @IBAction func loop(sender: AnyObject) {
        if serviceType.stringValue == "" {
            displayAlert("service type")
            return
        } else if filePath.URL == nil {
            displayAlert("working directory")
            return
        }
        
        var fm:NSFileManager = NSFileManager()
        var files: [NSURL]! = loopThroughDirectoryAndCreateFileArray(filePath.URL!, stateToBool(recursive.state), videoFormat.stringValue, fm)
        var groupedFiles:NSDictionary = groupFilesByDate(files, fm)
        var filesWithNames:NSDictionary = createFileToNameDict(groupedFiles, fm)
        renameFiles(filesWithNames, fm, serviceType.stringValue, "." + videoFormat.stringValue.lowercaseString)
        displaySuccess()
    }

    @IBAction func viewSource(sender: AnyObject) {
        var github:NSURL = NSURL(string: "https://github.com/AustinLMayes/ServiceOrganizer")!
        NSWorkspace.sharedWorkspace().openURL(github)
    }
}
