//
//  RecordingsTableViewController.swift
//  slick recorder
//
//  Created by MBPRO on 10/18/15.
//  Copyright (c) 2015 MBPRO. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class RecordingsTableViewController: UITableViewController, UITabBarControllerDelegate, NSFetchedResultsControllerDelegate{
    var recordings = [String]() // Array of Strings that contain recordings name
    var fileUrl = AudioUrl() // Object to pull audio filepath
    
    var fetchedResultController: NSFetchedResultsController!
    
    func fillRecordingsArray(){
        let audioDir = fileUrl.getRecordingDirectory()
        if let allRecordings = NSFileManager.defaultManager().contentsOfDirectoryAtPath(audioDir, error: nil) as?[String]{
            for name in allRecordings{
                recordings.append(name)
            }
        }
    }
    
/*
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        ViewController.rel
    }
*/
    override func viewDidLoad() {
        super.viewDidLoad()
        // Before showing table we must call fillRecordingsArray to populate Array of Recordings
        fillRecordingsArray()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem()

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // Function to delete recordings 
    func deleteRecordingFromArray(recordingName: String){
        let index = find(recordings, recordingName)
        recordings.removeAtIndex(index!)
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("recordingCell") as? UITableViewCell
        if cell == nil{
            cell = UITableViewCell(style: .Default, reuseIdentifier: "recordingCell")
        }
        cell!.textLabel?.text = recordings[indexPath.row]
        return cell!
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let recordingName = recordings[indexPath.row]
        
        // we only need to send the audio name because the path is always the same
        self.performSegueWithIdentifier("playAudioCell", sender: recordingName)
        
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }


    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // save in recording the name if the recording to be deleted
        let recording = recordings[indexPath.row]
        
        // Attemp to delete file from directory
        if fileUrl.deleteRecording(recording){
            // if file was deleted from directory successfully we then delete file from Array or recordings
            deleteRecordingFromArray(recording)
            if editingStyle == .Delete {
                // Delete the row from the data source
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let player: PlayRecordingViewController = segue.destinationViewController as! PlayRecordingViewController

    // we only need to send the audio file name to play so sender is casted as string
    let data = sender as! String
    player.fileName = data

    }



}
