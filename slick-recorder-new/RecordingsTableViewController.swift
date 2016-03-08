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
//    var recordings = [String]() // Array of Strings that contain recordings name
    var recordings = [RecordedAudio]() // Array of Strings that contain recordings name

    var recordingsSize = [String]()
    var fileUrl = AudioUrl() // Object to pull audio filepath
    var recordedAudio = RecordedAudio() // Object to pull recorded audio path and name
    var formatDate = NSDateFormatter()
    var count = 0
    var tempDate = NSDate()

//    var fetchedResultController: NSFetchedResultsController!
    
    func fillRecordingsArray(){
        let audioDir = fileUrl.getRecordingDirectory()
//        recordedAudio.audioTitle = fileUrl.getRecordingDirectory()
        do{
            let allRecordings = (try NSFileManager.defaultManager().contentsOfDirectoryAtPath(audioDir)) as [String]
            // Remove all recordings from array when rows are added or deleted so user can see only available rows
            recordings.removeAll()
            for name in allRecordings{
                let recording = RecordedAudio()
                recording.audioTitle = name
                recordings.append(recording)

                // get DATE substring from original file name
                let dateRange = name.startIndex.advancedBy(0)..<name.startIndex.advancedBy(11)
                let strDate = name.substringWithRange(dateRange)
                
                //get TIME substring from original file name
                let timeRange = name.startIndex.advancedBy(14)..<name.startIndex.advancedBy(25)
//                let strTime = name.substringWithRange(timeRange)
              //  print(strTime)
                
                // convert string to date
                formatDate.dateStyle = .MediumStyle
                if let recordingDate = formatDate.dateFromString(strDate)
                {
                    // Detect if date have changed
                    if count == 0 {
                         tempDate = recordingDate
                        print("first date: \(recordingDate)")
     //                   let strDate = formatDate.stringFromDate(recordingDate!)
     //                   let defaults = NSUserDefaults.standardUserDefaults()
    //                    defaults.setValuesForKeysWithDictionary(strDate: )
                    }
                    else if tempDate != recordingDate{
                        print("save new date \(recordingDate)")
                        tempDate = recordingDate
    //                    flag = false
                    }
                    else{
                        print("same date \(recordingDate)")
                       // print(recordingDate!)
     //                   flag = false
                    }
                }
                else{
                    print("error processing date")
                }

                count++
               // print(str)
            }
        }
        catch{
            print("error filling array")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Before showing table we must call fillRecordingsArray to populate Array of Recordings
        fillRecordingsArray()
        
        // Sort Array by Date, lastest recording on top
//        recordings.sortInPlace(){$0 < $1}

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.delegate = self
        

        
    }
    override func viewWillAppear(animated: Bool) {
//        self.tabBar.frame = CGRectMake(0, 30, self.view.bounds.size.width, self.view.bounds.size.height)
    }
    
    override func viewDidAppear(animated: Bool) {
        fillRecordingsArray()
        self.tableView.reloadData()

//        print("calling view did appear")
    }
    
    // Function to delete recordings
    func deleteRecordingFromArray(recordingName: String){
        let index = recordings.indexOf { (recording) -> Bool in
            recording.audioTitle == recordingName
        }
        if let i = index {
            recordings.removeAtIndex(i)
        }
    }
    
    func getAudioFileSize(name:String) -> Double{
        // Get File Size
        let audioDir = fileUrl.getRecordingDirectory()
        let fileNSUrl = NSURL(fileURLWithPath: audioDir+"/"+name)
        do{
            let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(fileNSUrl.path!)
            let fileSize = fileAttributes[NSFileSize]
            let sizeAsNumber = fileSize as! Double
            return sizeAsNumber
//            print("file size: \(sizeAsNumber/1000)")
        }
        catch let err as NSError{
            print("Error: \(err)")
            return 0
        }
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recordingCell", forIndexPath: indexPath) as UITableViewCell ?? UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "recordingCell")
        
        cell.textLabel?.text = "Audio " + recordings[indexPath.row].audioTitle
        
        // Show Audio File size in Mega bytes
        let audioName = recordings[indexPath.row].audioTitle
        cell.detailTextLabel?.text = String(format: "%.1f", getAudioFileSize(audioName)/1000000)+"Mb"
        
        // Color Cell Text
//        cell.backgroundColor = UIColor(red: 0.8, green: 0.6, blue: 0.8, alpha: 1)
        cell.backgroundColor = UIColor.darkGrayColor()

        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()

        /*
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.whiteColor().CGColor
        border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width:  cell.frame.size.width, height: cell.frame.size.height)

        cell.layer.addSublayer(border)
        */
        cell.layer.masksToBounds = true
        cell.layer.borderColor = UIColor( white: 1.0, alpha: 0.5).CGColor
        cell.layer.borderWidth = 0.5

        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        let recordingName = recordings[indexPath.row]

        // save recording name in recordedAudio object
        recordedAudio.audioTitle = recordings[indexPath.row].audioTitle

       self.performSegueWithIdentifier("playAudioCell", sender: recordedAudio)
        
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
        if fileUrl.deleteRecording(recording.audioTitle){
            // if file was deleted from directory successfully we then delete file from Array or recordings
            deleteRecordingFromArray(recording.audioTitle)
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
//        let data = sender as! String
        let data = sender as? RecordedAudio
//        player.fileName = data
        player.recordedAudio = data
        
        // Hide tabbar on next scene (playRecording)
        let destViewController = segue.destinationViewController as! PlayRecordingViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        
    }
    
    
}
