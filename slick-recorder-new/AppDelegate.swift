//
//  AppDelegate.swift
//  slick-recorder-new
//
//  Created by MBPRO on 11/12/15.
//  Copyright © 2015 MBPRO. All rights reserved.
//

import UIKit
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Handle Dropbox Authorization when application launch
        Dropbox.setupWithAppKey("bd31o3eded5n334")

        // Override point for customization after application launch.
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if let authResult = Dropbox.handleRedirectURL(url) {
            switch authResult {
            case .Success(let token):
              NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "DropboxAccountConnected", object: self))
                print("Success! User is logged into Dropbox.")
            case .Error( let error, let description):
                print("Error: \(description)")
                /*
                let alert = UIAlertController(title: "Dropbox Error", message: "Unable to link to Dropbox", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                */
                UIAlertView(title: "Dropbox Error", message: "Unable to link to Dropbox", delegate: nil, cancelButtonTitle: "Ok").show()
            }
        }
        
        return false
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
            NSNotificationCenter.defaultCenter().postNotificationName("kSaveSwitchesStatesNotification", object: nil);
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

