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
        
        // used to control tabs on tabbar
        self.delegate = self
        
        //move tabbar to the top
//        self.tabBar.frame = CGRectMake(0, 30, self.view.bounds.size.width, self.view.bounds.size.height);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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

    }

}