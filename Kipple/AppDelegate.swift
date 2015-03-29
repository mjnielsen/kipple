//
//  AppDelegate.swift
//  Kipple
//
//  Created by Michael Nielsen on 28/03/2015.
//  Copyright (c) 2015 Michael Nielsen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var passphraseField: NSTextField!
    @IBOutlet weak var specialCheckBox: NSButton!
    @IBOutlet weak var lengthSlider: NSSlider!
    @IBOutlet weak var lengthField: NSTextField!
    @IBOutlet weak var securePassphraseField: NSSecureTextField!
    
    @IBOutlet weak var aboutWindow: NSWindow!

    @IBOutlet weak var helpWindow: NSWindow!
    
    var url: NSURL!
    var d: Diceware!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        self.url =  NSBundle.mainBundle()
            .URLForResource("diceware.wordlist.asc", withExtension: nil)
        
        self.d = Diceware(urlForWordlistFile: url)
        
        self.passphraseField.hidden = true
        self.securePassphraseField.hidden = false
        
        updateUI(num: 6, special: false)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func aboutPressed(sender: AnyObject) {
        aboutWindow.makeKeyAndOrderFront(sender)
    }

    @IBAction func helpPressed(sender: AnyObject) {
        helpWindow.makeKeyAndOrderFront(sender)
    }
    
    @IBAction func newPassphrase(sender: AnyObject) {
        let num = self.lengthSlider.integerValue
        let special = self.specialCheckBox.state
        
        updateUI(num: num, special: ((special == 1) ? true : false))
    }

    @IBAction func specialBoxToggle(sender: AnyObject) {
        let num = self.lengthSlider.integerValue
        let special = self.specialCheckBox.state
        
        updateUI(num: num, special: (special == 1 ? true : false))
    }
    
    @IBAction func viewButtonToggle(sender: AnyObject) {
        if self.passphraseField.hidden == true {
            self.passphraseField.hidden = false
            self.securePassphraseField.hidden = true
        }
        else {
            self.passphraseField.hidden = true
            self.securePassphraseField.hidden = false
        }
    }
    
    func updateUI(num: Int = 5, special: Bool = false) {
        var passphrase = self.d.getPassphrase(num, special: special)
        
        self.passphraseField.stringValue = passphrase
        self.securePassphraseField.stringValue = passphrase
        
        self.lengthField.integerValue = num
        
        self.specialCheckBox.state = (special ? 1 : 0)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(theApplication:
        NSApplication) -> Bool {
        // Quit when all windows closed
        return true
    }
}

