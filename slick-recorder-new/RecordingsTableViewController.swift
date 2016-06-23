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
    var recordings = [RecordedAudio]() // Array of objects that contain recordings info

    var fileUrl = AudioUrl() // Object to get audio filepath
    var recordedAudio = RecordedAudio() // Object to get recorded audio path and name
    var formatDate = NSDateFormatter()
    var count = 0
    var tempDate = NSDate()
    var player: AVAudioPlayer!
    
    func fillRecordingsArray(){
        let audioDir = fileUrl.getRecordingDirectory()
//        recordedAudio.audioTitle = fileUrl.getRecordingDirectory()
        do{
            let allRecordings = (try NSFileManager.defaultManager().contentsOfDirectoryAtPath(audioDir)) as [String]
            // Remove all recordings from array when rows are added or deleted so user can see only available rows
            recordings.removeAll()
            for name in allRecordings{
                let recording = RecordedAudio()

                /** RECORDING FILE NAME **/
                recording.audioTitle = name
                print("here \(name)")
                /*** GET RECORDING DATE ***/
                let fileAttributes: [String: AnyObject] = (try NSFileManager.defaultManager().attributesOfItemAtPath("\(audioDir)/\(recording.audioTitle)"))
                recording.recordingDate = fileAttributes[NSFileCreationDate]! as! NSDate
                recordings.append(recording)
                

            }
            recordings.sortInPlace({ (recording1, recording2) -> Bool in
                
                return recording1.recordingDate.timeIntervalSince1970 > recording2.recordingDate.timeIntervalSince1970
            })
        }
        catch{
            print("error filling array")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Before showing table we must call fillRecordingsArray to populate Array of Recordings
        fillRecordingsArray()
        

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.delegate = self
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    override func viewWillAppear(animated: Bool) {
//        self.tabBar.frame = CGRectMake(0, 30, self.view.bounds.size.width, self.view.bounds.size.height)
    }

    override func viewDidAppear(animated: Bool) {
        fillRecordingsArray()
        self.tableView.reloadData()

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
        

        /*** Display Name of Audio files by counting the number of recordings **/
        let totalRecordings = recordings.count
        cell.textLabel?.text = "My Recording \(totalRecordings - indexPath.row )"
//          cell.textLabel?.text = recordings[indexPath.row].recordingGivenTitle
        
        
        /*** Show File Date time Information as Row Detail ****/
        let audioName = recordings[indexPath.row].audioTitle
        cell.detailTextLabel?.text = recordings[indexPath.row].audioTitle
        cell.detailTextLabel?.font = cell.detailTextLabel?.font.fontWithSize(12)
        
        
        
        /**** SHOW AUDIO FILE SIZE AND TIME DURATION TO THE RIGHT OF TABLEVIEW ****/
        
        do{
            let dir = fileUrl.getRecordingDirectory()
            let fullName = NSURL(fileURLWithPath: dir+"/"+recordings[indexPath.row].audioTitle)
            try player = AVAudioPlayer(contentsOfURL: fullName)
            let minutes = Int(player.duration / 60)
            let seconds = Int(player.duration % 60)
            
            if minutes == 0{ // Re arragenge subview space and show only seconds
                
                /**** Show File size on the right of the tableview cell ****/
                
                let rightView = UIView(frame: CGRectMake(0, 20, 100, 30))
                //rightView.backgroundColor = UIColor.yellowColor()
                let labelRight = UILabel(frame: CGRectMake(25, 14, 55, 20))
                //labelRight.backgroundColor = UIColor.blueColor()
                labelRight.text = String(format: "%.1f", getAudioFileSize(audioName)/1000000)+"Mb |"
                labelRight.textColor = UIColor.whiteColor()
                labelRight.font = labelRight.font.fontWithSize(12)
                rightView.addSubview(labelRight)
                
                
                /**** Show Audio File Duration on the right of Table view ****/

                let labelDuration = UILabel(frame: CGRectMake(70,14,35,20))
                //labelDuration.backgroundColor = UIColor.blackColor()
                labelDuration.text = String(format: " %.2ds", seconds)
                labelDuration.font = labelRight.font.fontWithSize(12)
                labelDuration.textColor = UIColor.whiteColor()
                rightView.addSubview(labelDuration)
                cell.accessoryView = rightView // Add Custom View in AccesoryView
                
            }
            else{
                if minutes > 60 {
                    /**** Show File size on the right of the tableview cell ****/
                    
                    let rightView = UIView(frame: CGRectMake(0, 20, 110, 30))
                    //   cell.contentView.addSubview(rightView)
                    //rightView.backgroundColor = UIColor.yellowColor()
                    let labelRight = UILabel(frame: CGRectMake(10, 14, 55, 20))
                    //labelRight.backgroundColor = UIColor.blueColor()
                    labelRight.text = String(format: "%.1f", getAudioFileSize(audioName)/1000000)+"Mb |"
                    labelRight.textColor = UIColor.whiteColor()
                    labelRight.font = labelRight.font.fontWithSize(12)
                    rightView.addSubview(labelRight)
                    
                    
                    /**** Show Audio File Duration on the right of Table view ****/
                    
                    let labelDuration = UILabel(frame: CGRectMake(60,14,55,20))
                    //labelDuration.backgroundColor = UIColor.blackColor()
                    labelDuration.text = String(format: " %.1dh %.2dm", minutes / 60, minutes - 60)
                    labelDuration.font = labelRight.font.fontWithSize(12)
                    labelDuration.textColor = UIColor.whiteColor()
                    rightView.addSubview(labelDuration)
                    cell.accessoryView = rightView // Add Custom View in AccesoryView

                    
                }
                else if minutes < 10{ // Re arragenge subview space if minutes is only 1 digit
                    
                    /**** Show File size on the right of the tableview cell ****/
                    
                    let rightView = UIView(frame: CGRectMake(0, 20, 110, 30))
                    //rightView.backgroundColor = UIColor.yellowColor()
                    let labelRight = UILabel(frame: CGRectMake(20, 14, 45, 20))
                    //labelRight.backgroundColor = UIColor.blueColor()
                    labelRight.text = String(format: "%.1f", getAudioFileSize(audioName)/1000000)+"Mb |"
                    labelRight.textColor = UIColor.whiteColor()
                    labelRight.font = labelRight.font.fontWithSize(12)
                    rightView.addSubview(labelRight)
                    
                    
                    /**** Show Audio File Duration on the right of Table view ****/
                    
                    let labelDuration = UILabel(frame: CGRectMake(60,14,55,20))
                    //labelDuration.backgroundColor = UIColor.blackColor()
                    labelDuration.text = String(format: " %.1dm %.2ds", minutes, seconds)
                    labelDuration.font = labelRight.font.fontWithSize(12)
                    labelDuration.textColor = UIColor.whiteColor()
                    rightView.addSubview(labelDuration)
                    cell.accessoryView = rightView // Add Custom View in AccesoryView

                    
                }
                else{
                    /**** Show File size on the right of the tableview cell ****/
                    
                    let rightView = UIView(frame: CGRectMake(0, 20, 110, 30))
                    //   cell.contentView.addSubview(rightView)
                    //rightView.backgroundColor = UIColor.yellowColor()
                    let labelRight = UILabel(frame: CGRectMake(10, 14, 55, 20))
                    //labelRight.backgroundColor = UIColor.blueColor()
                    labelRight.text = String(format: "%.1f", getAudioFileSize(audioName)/1000000)+"Mb |"
                    labelRight.textColor = UIColor.whiteColor()
                    labelRight.font = labelRight.font.fontWithSize(12)
                    rightView.addSubview(labelRight)
                    
                    
                    /**** Show Audio File Duration on the right of Table view ****/

                    let labelDuration = UILabel(frame: CGRectMake(60,14,55,20))
                    //labelDuration.backgroundColor = UIColor.blackColor()
                    labelDuration.text = String(format: " %.1dm %.2ds", minutes, seconds)
                    labelDuration.font = labelRight.font.fontWithSize(12)
                    labelDuration.textColor = UIColor.whiteColor()
                    rightView.addSubview(labelDuration)
                    cell.accessoryView = rightView // Add Custom View in AccesoryView
                }
               
            }
            //print(String(format: "%.1d:%.2d", minutes, seconds))
        }
        catch{
            print("unable to open audio fileeeee")
        }
        
        // Color Cell Text
//        cell.backgroundColor = UIColor(red: 0.8, green: 0.6, blue: 0.8, alpha: 1)
       // cell.backgroundColor = UIColor.darkGrayColor()

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
        
        // save in recording the name of the row selected
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
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // save in recording the name of the row selected
        let recording = recordings[indexPath.row]
/*
        let renameFile = UITableViewRowAction(style: .Normal, title: "Re Name") { action, index in
            print("rename")
            self.performSegueWithIdentifier("renameFile", sender: recording)
        }
        renameFile.backgroundColor = UIColor.grayColor()
  */
        let deleteFile = UITableViewRowAction(style: .Destructive, title: "Delete") { action, index in

            if self.fileUrl.deleteRecording(recording.audioTitle){
                // if file was deleted from directory successfully we then delete file from Array or recordings
                self.deleteRecordingFromArray(recording.audioTitle)
                    // Delete the row from the data source
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
        }
     //   renameFile.backgroundColor = UIColor.grayColor()
        
  //      return [renameFile, deleteFile]
        return [deleteFile]
        
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
        if segue.identifier == "playAudioCell"{
            let player: PlayRecordingViewController = segue.destinationViewController as! PlayRecordingViewController
            let data = sender as? RecordedAudio
            player.recordedAudio = data
        }
        
        // Hide tabbar on next scene (playRecording)
        let destViewController = segue.destinationViewController as! PlayRecordingViewController
        destViewController.hidesBottomBarWhenPushed = true
        
    }
    
    
    
}
