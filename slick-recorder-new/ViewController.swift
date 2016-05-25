//
//  ViewController.swift
//  slick-recorder-new
//
//  Created by MBPRO on 11/12/15.
//  Copyright © 2015 MBPRO. All rights reserved.
//

import UIKit

class ViewController: UITabBarController, UITabBarControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().idleTimerDisabled = true // Prevent App from going to sleep
                
        UITabBar.appearance().tintColor = UIColor.whiteColor() // Custom color for tabbar icons
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.redColor()], forState: UIControlState.Normal)
        
        /// PRESENT MICVIEWCONTROLLER AS FIRST SCREEN WHEN APP IS OPENED FOR FIRST TIME
        dispatch_async(dispatch_get_main_queue(), {
            if let vc = self.storyboard!.instantiateViewControllerWithIdentifier("micStoryboard") as? MicViewController {
                self.presentViewController(vc, animated: true, completion: nil)
            }
            })
        
        // used to control tabs on tabbar
        self.delegate = self
        
        //move tabbar to the top
//        self.tabBar.frame = CGRectMake(0, 30, self.view.bounds.size.width, self.view.bounds.size.height);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
/// PRESENT MICVIEWCONTROLLER RATHER THAN RECORDSOUNDS VIEWCONTROLLER WHEN TAP ON MIC ICON
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if viewController.isKindOfClass(RecordSoundsViewController) == true{
            if let vc = storyboard!.instantiateViewControllerWithIdentifier("micStoryboard") as? MicViewController {
                self.presentViewController(vc, animated: true, completion: nil)
            }
            return false
        }else{
            return true
        }
    }
    /*
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if  viewController.isKindOfClass(UINavigationController) == true{
            if let navigationViewController = viewController as? UINavigationController{
                if let newTableController = navigationViewController.topViewController as? RecordingsTableViewController{
                    newTableController.fillRecordingsArray();
                         newTableController.tableView.reloadData()
                }
            }
        }
        /*
    if let vc = storyboard!.instantiateViewControllerWithIdentifier("micStoryboard") as? MicViewController {
            self.presentViewController(vc, animated: true, completion: nil)
        }
        else{
            print("error")
        }*/

    }*/

}