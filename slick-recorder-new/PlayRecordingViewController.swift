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
//import MediaPlayer

class PlayRecordingViewController: UIViewController, EZAudioPlayerDelegate, UITextFieldDelegate{
    
    //    @IBOutlet weak var circularProgress: UIView!
//    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
   
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var renameFile: UITextField!
    
    @IBOutlet weak var playDuration: UILabel!
    @IBOutlet weak var playCurrentTime: UILabel!
    
    // EZAUDIO
    var ezPlayer = EZAudioPlayer()
    var audioFile: EZAudioFile!
    
    @IBOutlet weak var audioPlot: EZAudioPlotGL!
    
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    
    var player: AVAudioPlayer!
    var recordedAudio: RecordedAudio! // Saves the file Name recived from Table View
    var dirPath = AudioUrl() // Get the directory path of the recording
    
    // variables used to update UISlider when playing a sound
    var updater : CADisplayLink! = nil // tracks the time into the track
    var updater_running : Bool = false // did the updater start?
    var playing = false //indicates if track started playing
    var timer: NSTimer! // Tracks the time into the track
    
    var previewView = UIView()
    
    var recordingsQueqe: AVQueuePlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            let dir = dirPath.getRecordingDirectory()
            let fullName = NSURL(fileURLWithPath: dir+"/"+recordedAudio.audioTitle)

        /** DISPLAY AND EDIT AUDIO FILE NAME **/
            self.fileName.text = recordedAudio.audioTitle //  Display File Name below slider
            renameFile.delegate = self
            renameFile.hidden = true
            fileName.userInteractionEnabled = true
            let selector: Selector = "audioNameEdit"
            let tapGesture = UITapGestureRecognizer(target: self, action: selector)
            tapGesture.numberOfTapsRequired = 1
            fileName.addGestureRecognizer(tapGesture)
        
        // SHOW ZERO ON TIMER LABELS BEFORE NSTIMER KICKS UP
            playCurrentTime.text = String(format: "%.1d:%.2d", 0, 0) // Left Timer
            playDuration.text = String(format: "-%.1d:%.2d", 0, 0 ) // Right Timer

        
        /** ADD VOLUME USING MPVOLUMEVIEW, HIDE SLIDER AND ROUTE BUTTON POSTPONED UNTIL FINDING A WAY TO SET SPEAKER ICONS ON THE SIDES OF SLIDER (if useing again, need too add view to storyboard)**/
        /*
            volumeView.backgroundColor = UIColor.clearColor()
            let audioVolume = MPVolumeView(frame: CGRectMake(5, 10, 230, 50))
            volumeView.addSubview(audioVolume)
            audioVolume.showsVolumeSlider = false
            audioVolume.showsRouteButton = false
        */
        
        /** ADD VOLUME SLIDER USING UISLIDER **/
            volumeSlider.minimumValueImage = UIImage(named: "min-volume")
            volumeSlider.maximumValueImage = UIImage(named: "max-volume")
        
            audioSlider.setThumbImage(UIImage(named: "slider_thumb"), forState: UIControlState.Normal)
    
            /**** EZAUDIO CONFIGURATION ****/
            //audioPlot.color = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
           // audioPlot.backgroundColor = UIColor(red: 0.816, green: 0.349, blue: 0.255, alpha: 1)
            audioPlot?.plotType = EZPlotType.Rolling
            audioPlot?.shouldFill = true
            audioPlot?.shouldMirror = true
            ezPlayer = EZAudioPlayer(delegate: self)
        
        
            /***  PLAY AUDIO FILE IMPLEMENTATION ***/
            
           // updateTimeSlider()
        //
        // Listen for EZAudioPlayer notifications
        //
            setupNotifications()
        //
            setSessionPlayAudio()
            openFile(fullName)
            ezPlayer.play()

     
        
        // Cloud Button showed to the right of Navigation Bar
        /*
        let cloudButton = UIImage(named: "cloud")
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(image: cloudButton, style: .Plain, target: self, action: "uploadFileToCloud"), animated: true)
        */
    }
    
    //------------------------------------------------------------------------------
    //pragma mark - Notifications
    //------------------------------------------------------------------------------
    func setupNotifications(){
        
        NSNotificationCenter.defaultCenter().addObserverForName(EZAudioPlayerDidChangeAudioFileNotification,
                                                                object: self.player,
                                                                queue: nil,
                                                                usingBlock: audioPlayerDidChangeAudioFile)
        
        NSNotificationCenter.defaultCenter().addObserverForName(EZAudioPlayerDidChangePlayStateNotification,
                                                                object: self.player,
                                                                queue: nil,
                                                                usingBlock: audioPlayerDidChangePlayState)
    }
    
    func audioPlayerDidChangeAudioFile(notificacion: NSNotification){
        ezPlayer = notificacion.object as! EZAudioPlayer
     //   print("Player changed audio file:", ezPlayer.audioFile)
    }
    
    func audioPlayerDidChangePlayState(notification: NSNotification){
        ezPlayer = notification.object as! EZAudioPlayer
        print("Player changed playin state: ", ezPlayer.isPlaying)
        if ezPlayer.isPlaying == false{
            btnPlay.hidden = false
            btnPause.hidden = true
            self.timer.invalidate()
        }

    }


    func audioNameEdit(){
        renameFile.hidden = false
        fileName.hidden = true
        renameFile.text = fileName.text
    }
    
    /// CHANGE FILE NAME POSTPONED
    /*
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        renameFile.hidden = true
        fileName.hidden = false
        fileName.text = renameFile.text
        let newName = (dirPath.getRecordingDirectory() as NSString).stringByAppendingPathComponent(renameFile.text!)
        do{
            try newName.writeToFile(newName, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch{
            print("unable to save file")
        }
        
        return true
    }
    */
    
    @IBAction func changeVolume(sender: UISlider) {
        ezPlayer.volume = volumeSlider.value
    }
    
    func setSessionPlayAudio(){
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSessionCategoryPlayback)
        }
        catch let error as NSError{
            print("Unable to initialize session category")
            print(error.localizedDescription)
        }
        /*
        do{
            try session.setMode("AVAudioSessionModeVoiceChat")
        }
        catch{
            print("Unable to initialize session mode")
            
        }*/
        do{
            try session.setActive(true)
            
            // INITIALIZE TIMERS ON THE SIDES OF SLIDER
            self.timer = NSTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(PlayRecordingViewController.updatePlayingTimer),
                userInfo: nil,
                repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)

        }
        catch{
            print("Unable to initialize set session active")
        }
    }
    
    func updatePlayingTimer(){
            let seconds = Int(ezPlayer.currentTime % 60)
            let minutes = Int(ezPlayer.currentTime / 60)
          //  let totalSecDuration = Int(player.duration % 60)
            let totalMinDuration = Int(ezPlayer.duration / 60)
            let hour = 60
         //   print("durationnn: \(Int(ezPlayer.duration / 60))")

    //        timeLabel.text = String(format: "%.2d:%.2d", minutes, seconds)
            
            /*** Show Current / Total Time on the sides of  Slider **/
            
            if totalMinDuration - hour > 0{
                self.playCurrentTime.text = String(format: "%.1d:%.2d:%.2d", minutes / 60, minutes, seconds) // Left Timer
                self.playDuration.text = String(format: "-%.1d:%.1d:%.2d", (totalMinDuration - minutes) / hour, totalMinDuration - minutes, seconds )
            }
            else{
                self.playCurrentTime.text = String(format: "%.1d:%.2d", minutes, seconds) // Left Timer
                //self.playDuration.text = String(format: "-%.1d:%.2d", totalMinDuration - minutes, Int(player.duration)  - seconds ) // Right Timer
                self.playDuration.text = String(format: "-%.1d:%.2d", totalMinDuration - minutes, seconds ) // Right Timer

            }
        
    }
    
    @IBAction func fowardButton(sender: UIButton) {
        ezPlayer.currentTime += 10
        updatePlayingTimer()
        
    }
    
    @IBAction func rewindButton(sender: UIButton) {
        ezPlayer.currentTime -= 10
        updatePlayingTimer()
    }
    
    func openFile(filePath: NSURL){
        //        self.audioFile = [EZAudioFile audioFileWithURL:filePathURL];
        audioFile = EZAudioFile(URL: filePath)
        
        audioSlider.maximumValue = Float(audioFile.totalFrames)
        //
        // Plot the whole waveform
        //
        audioPlot?.plotType = EZPlotType.Rolling
        audioPlot?.shouldFill = true
        audioPlot?.shouldMirror = true
        
        let waveData = audioFile.getWaveformData()
        self.audioPlot.updateBuffer(waveData.buffers[0], withBufferSize: waveData.bufferSize)
        
        //
        // Play the audio file
        //
        ezPlayer.audioFile = audioFile
        
        
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        })
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue(), {
            if !self.audioSlider.touchInside{
                self.audioSlider.value = Float(framePosition)
                
                if self.audioSlider.value == 0{
                    self.playCurrentTime.text = String(format: "%.1d:%.2d", 0, 0) // Left Timer
                    self.playDuration.text = String(format: "-%.1d:%.2d", 0, 0 ) // Right Timer
                }
            }
        })
    }
      /*
    func updateTimeSlider(){
        updater = CADisplayLink(target: self, selector: Selector("updatePlayingTimer"))
        updater.frameInterval = 1
        updater.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        updater_running = true
    }
    */
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
        if ezPlayer.isPlaying == true {
            ezPlayer.pause()
            print("player stopped")
            let session = AVAudioSession.sharedInstance()
            do{
                try session.setActive(false)
                //updater.invalidate()
                //updater_running = false
            }
            catch{
                print("unable to deactivate session")
            }
            self.timer.invalidate()

        }

        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
       @IBAction func playSelectedRecording(sender: UIButton) {
        
        if audioPlot.shouldMirror && audioPlot.plotType == EZPlotType.Buffer{
            audioPlot.shouldMirror = false
            audioPlot.shouldFill = false
        }
        btnPause.hidden = false
        btnPlay.hidden = true
        
        // INITIALIZE TIMERS ON THE SIDES OF SLIDER
        self.timer = NSTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(PlayRecordingViewController.updatePlayingTimer),
            userInfo: nil,
            repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)

        ezPlayer.play()


    }
    
    @IBAction func pausePlaying(sender: UIButton) {
          if ezPlayer.isPlaying{
            ezPlayer.pause()
            btnPause.hidden = true
            btnPlay.hidden = false
       //     totalTime.hidden = true
        }
    }
    
    /*
    @IBAction func btnStop(sender: UIButton) {
        player.stop()
        player.currentTime = 0
        btnPause.hidden = true
        btnPlay.hidden = false
        playing = false
    }*/
    
    @IBAction func uploadToCloud(sender: UIButton) {
        // Verify user is logged into Dropbox
        if let client = Dropbox.authorizedClient {
            
            // Get the current user's account info
            client.users.getCurrentAccount().response{ response, error in
                if let account = response {
                    print("Hello \(account.name.givenName)")
                } else {
                    print(error!)
                }
            }
            
            // List folder
//            client.users.getCurrentAccount().response{ response, error in
            client.files.listFolder(path: "").response { response, error in
                if let result = response {
                    print("Folder contents:")
                    for entry in result.entries {
                        print(entry.name)
                    }
                } else {
                    print(error!)
                }
            }
            
            /****** Subview to show upload progress ****/
            
            self.previewView = UIView(frame: CGRectMake(25, 250, 250, 100))
            self.previewView.backgroundColor = UIColor(red: 5 , green: 5, blue: 5, alpha: 0.5)
            self.view.addSubview(self.previewView)
            
            // Label inside view
            let label = UILabel(frame: CGRectMake(10, -5, 200, 100))
            label.text = "Upload progress"
            self.previewView.addSubview(label)
            
            let progressBar = UIProgressView(frame: CGRectMake(5, 60, 200, 10))
            let progressLabel = UILabel(frame: CGRectMake(80, 60, 150, 40))
            self.previewView.addSubview(progressBar)
            self.previewView.addSubview(progressLabel)

            
            
            // Upload a file
            //  let fileData = "Hello!".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            // Get Recording Path
            let recordingPath = dirPath.getRecordingDirectory()+"/"+recordedAudio.audioTitle
            let data = NSData(contentsOfFile: recordingPath)
            
            client.files.upload(path: "/"+recordedAudio.audioTitle, body: data!).progress({(bytesWritten : Int64, totalBytesWritten : Int64, totalBytesExpectedToWrite : Int64) -> Void in
                
                let uploadProgress : Float  = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) as Float;
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Progressview inside view
                    
                    // Upadate progress bar
                    progressBar.progress = uploadProgress
                    print (Int(uploadProgress * 100))
                    // Show progress in label
                    progressLabel.text = "\(Int(uploadProgress * 100))%"
                    //                                   progressLabel.text = "100%"
                    
                    // If upload is completed delete pop up
                    if totalBytesWritten == totalBytesExpectedToWrite{
                        self.previewView.removeFromSuperview()
                    }
                    
                });
                
            }).response { response, error in
                if let metadata = response {
                    print("Uploaded file name: \(metadata.name)")
                    print("Uploaded file revision: \(metadata.rev)")
                    
                }
                if let e = error{
                    print(e)
                }
            }
        } // End Dropbox.authorizedClient
        else{
            print("User not authorized in Dropbox")
            UIAlertView(title: "Dropbox Error", message: "Unable to link to Dropbox", delegate: nil, cancelButtonTitle: "Ok").show()

        }
        
    }
    
    
    @IBAction func deleteAudioFile(sender: UIButton) {
        
        /*** Pop up confirmation to delete file ***/
        
        let alert = UIAlertController(title: "Delete Audio File", message: "Are you sure?", preferredStyle: .Alert)
        let actionYes = UIAlertAction(title: "Yes", style: .Default, handler: {(alert: UIAlertAction!) in
            if self.dirPath.deleteRecording(self.recordedAudio.audioTitle){
                // Navigate back to tableview once file is deleted
                self.navigationController?.popViewControllerAnimated(true)
            }
            else{
                print("error while deleting file")
            }
        })
        let actionNo = UIAlertAction(title: "No", style: .Default, handler: {(alert: UIAlertAction) in
            self.btnPause.hidden = false
            self.btnPlay.hidden = true
        })
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    func deleteAudioFile(){
        performSegueWithIdentifier("playAudioCell", sender: nil)
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
