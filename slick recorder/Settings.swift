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
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dropboxSwitch(sender: UISwitch) {
        if sender.on{
            if Dropbox.authorizedClient == nil{
                Dropbox.authorizeFromController(self)
            }
            else{
                println("User is already authorized")
            }
        }
    }
}
