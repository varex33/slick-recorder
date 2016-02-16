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


class PlayRecordingViewController: UIViewController,AVAudioPlayerDelegate, EZAudioPlayerDelegate{
    
//    @IBOutlet weak var circularProgress: UIView!
    @IBOutlet weak var btnStop: UIButton!
    //@IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var audioPlot: EZAudioPlotGL!
    
    // EZAUDIO
    var ezPlayer : EZAudioPlayer!
    var audioFile: EZAudioFile!
    
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var totalTime: UILabel!

    var player: AVAudioPlayer!
//    var fileName: String! // Saves the file Name recived from Table View
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
            // PATH TO AUDIO FILE
            let fullName = NSURL(fileURLWithPath: dir+"/"+recordedAudio.audioTitle)

  //          print("This is the name \(recordedAudio.audioTitle)")
            showRecordingTime()
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            // EZAUDIO CONFIGURATION
            audioPlot?.color = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
            audioPlot?.plotType = EZPlotType.Buffer
            audioPlot?.shouldFill = true
            audioPlot?.shouldMirror = true
            ezPlayer = EZAudioPlayer(delegate: self)
           // ezPlayer.shouldLoop = true
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
            // call EZAudio function to process the waveform
            openFile(fullName)
         //   ezPlayer.play()
            
            // PLAY AUDIO FILE
            player = try? AVAudioPlayer(contentsOfURL: fullName )
           // player = try? AVAudioPlayer(contentsOfURL: recordedAudio.audioUrl )
         //   btnPlay.enabled = false
            
            player.delegate = self
            player.prepareToPlay()
            player.play()

 //           audioSlider.continuous = false
        }
        catch let error as NSError?{
            print("Error intiating audio session \(error)")
        }
        // Cloud Button showed to the right of Navigation Bar
        let cloudButton = UIImage(named: "cloud")
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(image: cloudButton, style: .Plain, target: self, action: "uploadFileToCloud"), animated: true)

    }
    
    func openFile(filePath: NSURL){
        
//        self.audioFile = [EZAudioFile audioFileWithURL:filePathURL];
        audioFile = EZAudioFile(URL: filePath)
        //
        // Plot the whole waveform
        //
        audioPlot?.plotType = EZPlotType.Buffer
        audioPlot?.shouldFill = true
        audioPlot?.shouldMirror = true
        
        let waveData = audioFile.getWaveformData()
        self.audioPlot.updateBuffer(waveData.buffers[0], withBufferSize: waveData.bufferSize)
        
        //
        // Play the audio file
        //
//        [self.player setAudioFile:self.audioFile];
        ezPlayer.audioFile = audioFile

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
        let offsetY = (visible ? -height! : height)
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
            wasPlaying = false
        }
        
    }
    
    @IBAction func playSelectedRecording(sender: UIButton) {
    if (playing == false) {
        updater = CADisplayLink(target: self, selector: Selector("updateProgress"))
        updater.frameInterval = 1
        updater.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        updater_running = true
//        btnPlay.enabled = false
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
        timeLabel.text = NSString(format: "%.2d:%.2d:%.2f",minutes, seconds, timer) as String

    }

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true{
//            btnPlay.enabled = true
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
//        btnPlay.enabled = true
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
            let recordingPath = dirPath.getRecordingDirectory()+"/"+recordedAudio.audioTitle
            let data = NSData(contentsOfFile: recordingPath)
            
            client.filesUpload(path: "/"+recordedAudio.audioTitle, body: data!).response { response, error in
                if let metadata = response {
                    print("Uploaded file name: \(metadata.name)")
                    print("Uploaded file revision: \(metadata.rev)")
                    
                    // Get file (or folder) metadata
                    client.filesGetMetadata(path: "/"+self.recordedAudio.audioTitle).response { response, error in
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
