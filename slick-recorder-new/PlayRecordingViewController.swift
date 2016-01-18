//
//  PlayRecordingViewController.swift
//
//
//  Created by MBPRO on 10/18/15.
//
//

import UIKit
import AVFoundation
import SwiftyDropbox


class PlayRecordingViewController: UIViewController,AVAudioPlayerDelegate{
    
//    @IBOutlet weak var circularProgress: UIView!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var totalTime: UILabel!

    var player: AVAudioPlayer!
    var fileName: String! // Saves the file Name recived from Table View
    var recordedAudio: RecordedAudio!
    var dirPath = AudioUrl() // Get the directory path of the recording

    // variables used to update UISlider when playing a sound
    var updater : CADisplayLink! = nil // tracks the time into the track
    var updater_running : Bool = false // did the updater start?
    var playing : Bool = false //indicates if track started playing

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dir = dirPath.getRecordingDirectory()
        do{
            
            showRecordingTime()
            let fullName = NSURL(fileURLWithPath: dir+"/"+fileName)
            player = try? AVAudioPlayer(contentsOfURL: fullName )
//            player = try? AVAudioPlayer(contentsOfURL: recordedAudio.audioUrl )
            btnPlay.enabled = false
            player.delegate = self
            player.prepareToPlay()
            player.play()
            audioSlider.continuous = false
        }
        // Cloud Button showed to the right of Navigation Bar
        let cloudButton = UIImage(named: "cloud")
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(image: cloudButton, style: .Plain, target: self, action: "uploadFileToCloud"), animated: true)

    }
    
    func showRecordingTime(){
        updater = CADisplayLink(target: self, selector: Selector("updateProgress"))
        updater.frameInterval = 1
        updater.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        updater_running = true
    }
    
    func setTabBarVisible(visible: Bool, animated: Bool) {
        // hide tab bar
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        var offsetY = (visible ? -height! : height)
//        println ("offsetY = \(offsetY)")
        
        // zero duration means no animation
        let duration:NSTimeInterval = (animated ? 0.3 : 0.0)
        
        // animate tabBar
        if frame != nil {
            UIView.animateWithDuration(duration) {
                self.tabBarController?.tabBar.frame = CGRectOffset(frame!, 0, offsetY!)
                self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height + offsetY!)
                self.view.setNeedsDisplay()
                self.view.layoutIfNeeded()
                return
            }
        }
    }
    
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        setTabBarVisible(!tabBarIsVisible(), animated: true)
    }
    
    func tabBarIsVisible() -> Bool {
        return self.tabBarController?.tabBar.frame.origin.y < UIScreen.mainScreen().bounds.height
    }
    
    override func viewWillDisappear(animated: Bool) {
        if playing == true {
            player.stop()
        }
        updater.invalidate()
        updater_running = false
        super.viewWillDisappear(animated)
    }
    
       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func progressSlider(sender: UISlider) {
        // if the track was playing store true, so we can restart playing after changing the track position
        var wasPlaying : Bool = false
        if playing == true {
            player.pause()
            wasPlaying = true
        }
        player.currentTime = NSTimeInterval(round(audioSlider.value))
        updateProgress()
        // starts playing track again if it had been playing
        if (wasPlaying == true) {
            player.play()
            wasPlaying == false
        }
        
    }
    
    @IBAction func playSelectedRecording(sender: UIButton) {
    if (playing == false) {
        updater = CADisplayLink(target: self, selector: Selector("updateProgress"))
        updater.frameInterval = 1
        updater.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        updater_running = true
        btnPlay.enabled = false
        totalTime.hidden = true
        timeLabel.hidden = false
        player.delegate = self
        player.prepareToPlay()
        player.play()
        updateProgress()
        }
    else {
        updateProgress()
        player.pause()
        playing = false
        }
    }
    
    func updateProgress() {
        let timer = player.currentTime
        let seconds = NSInteger(player.currentTime/60)
        let minutes = NSInteger(player.duration) / 60
        audioSlider.minimumValue = 0.0
        audioSlider.maximumValue = Float(player.duration)
        audioSlider.setValue(Float(player.currentTime), animated: true)
//        timeLabel.text = NSString(format: "%.2f : %.2f", current_time, total) as String
        timeLabel.text = NSString(format: "%.2d:%.2d:%.2f ",minutes, seconds, timer) as String

    }

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true{
            btnPlay.enabled = true
            updateProgress()
            
            //show playing time in h/m/s format
            let duration = NSInteger(player.duration)
            let seconds = duration
            let minutes = seconds / 60
            let hours = seconds / 3600
            timeLabel.hidden = true
            totalTime.hidden = false
            totalTime.text = NSString(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds) as String
        }
    }
    
    @IBAction func stopPlaying(sender: UIButton) {
        player.stop()
        btnPlay.enabled = true
    }
    
    
    func uploadFileToCloud(){
        // Verify user is logged into Dropbox
        if let client = Dropbox.authorizedClient {
            
            // Get the current user's account info
            client.usersGetCurrentAccount().response { response, error in
                if let account = response {
                    print("Hello \(account.name.givenName)")
                } else {
                    print(error!)
                }
            }
            
            // List folder
            client.filesListFolder(path: "").response { response, error in
                if let result = response {
                    print("Folder contents:")
                    for entry in result.entries {
                        print(entry.name)
                    }
                } else {
                    print(error!)
                }
            }
            
            // Upload a file
            //  let fileData = "Hello!".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            // Get Recording Path
            let recordingPath = dirPath.getRecordingDirectory()+"/"+fileName
            let data = NSData(contentsOfFile: recordingPath)
            
            client.filesUpload(path: "/"+fileName, body: data!).response { response, error in
                if let metadata = response {
                    print("Uploaded file name: \(metadata.name)")
                    print("Uploaded file revision: \(metadata.rev)")
                    
                    // Get file (or folder) metadata
                    client.filesGetMetadata(path: "/"+self.fileName).response { response, error in
                        if let metadata = response {
                            //  print("Name: \(metadata.name)")
                            if let file = metadata as? Files.FileMetadata {
                                
                                print("This is a file.")
                                print("File size: \(file.size)")
                                print("int size: \(Int(file.size / 1000))")
                            }
                            
                        } else {
                            print(error!)
                        }
                    }
                }
            }
        } // End Dropbox.authorizedClient
        else{
            print("User not authorized in Dropbox")
        }
        
    }
    

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
