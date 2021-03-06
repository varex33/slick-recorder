//
//  Settings.swift
//  slick recorder
//
//  Created by MBPRO on 10/31/15.
//  Copyright (c) 2015 MBPRO. All rights reserved.
//

import Foundation
import UIKit
import SwiftyDropbox

class Settings: UIViewController{
    
    @IBOutlet weak var dropboxSwitch: UISwitch!
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add observer to notify when app goes to the background
        /*
        let app = UIApplication.sharedApplication()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveSwitchesStates", name: "kSaveSwitchesStatesNotification", object: app);
        */
        restoreSwitchesStates()

        // Show dropbox user name on settings window
      
        self.updateDropboxUser()
        NSNotificationCenter.defaultCenter().addObserverForName("DropboxAccountConnected", object: nil, queue: NSOperationQueue.mainQueue()) { (note) -> Void in
            self.updateDropboxUser()
        }
    }
/*
    func saveSwitchesStates() {
//        NSUserDefaults.standardUserDefaults().setBool(dropboxSwitch.on, forKey: "open")
//        NSUserDefaults.standardUserDefaults().synchronize()
    }
*/
  func updateDropboxUser() {
    if let client = Dropbox.authorizedClient {
        
      // Get the current user's account info
      //            client.usersGetCurrentAccount().response { response, error in
      client.users.getCurrentAccount().response{ response, error in
        if let account = response {
          self.userName.text = account.name.givenName
        } else {
          print(error!)
        }
      }
    }
    else{
        print("not authorized")
    }
  }
  
    func restoreSwitchesStates() {
        if let _ = Dropbox.authorizedClient {

        dropboxSwitch.on = true
        }
        else{
            dropboxSwitch.on = false
            
        }
    }

    @IBAction func dropboxSwitch(sender: UISwitch) {
//        Dropbox.authorizeFromController(self)
        NSUserDefaults.standardUserDefaults().setBool(dropboxSwitch.on, forKey: "open")

        if sender.on {
            if Dropbox.authorizedClient == nil{
                Dropbox.authorizeFromController(self)
                
            }
            else{
                print("User is already authorized")
            }
        }
        else{
            Dropbox.unlinkClient()
            self.userName.text = ""
            print("User is unlnked from dropbox")
        }
    }
}
