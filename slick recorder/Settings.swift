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
    @IBOutlet weak var dropboxUser: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dropboxSwitch(sender: UISwitch) {
        if sender.on{
            if Dropbox.authorizedClient == nil{
                Dropbox.authorizeFromController(self)
                
                if let client = Dropbox.authorizedClient {
                // Get the current user's account info
                    client.usersGetCurrentAccount().response { response, error in
                        if let account = response {
                            self.dropboxUser.text = account.name.givenName
//                            print("Hello \(account.name.givenName)")
                        } else {
                            print(error!)
                        }
                    }
                }

            }
            else{
                print("User is already authorized")
            }
        }
    }
}
