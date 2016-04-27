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
import MediaPlayer

class PlayRecordingViewController: UIViewController,AVAudioPlayerDelegate, EZAudioPlayerDelegate, UITextFieldDelegate{
    
    //    @IBOutlet weak var circularProgress: UIView!
//    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var audioPlot: EZAudioPlotGL!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var renameFile: UITextField!
    
    @IBOutlet weak var playDuration: UILabel!
    @IBOutlet weak var playCurrentTime: UILabel!
    
    // EZAUDIO
    var ezPlayer : EZAudioPlayer!
    var audioFile: EZAudioFile!
    var timer: NSTimer!
    
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    
    var player: AVAudioPlayer!
    var recordedAudio: RecordedAudio! // Saves the file Name recived from Table View
    var dirPath = AudioUrl() // Get the directory path of the recording
    
    // variables used to update UISlider when playing a sound
    var updater : CADisplayLink! = nil // tracks the time into the track
    var updater_running : Bool = false // did the updater start?
    var playing : Bool = false //indicates if track started playing
    
    var previewView = UIView()
    
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
        
        /** ADD VOLUME USING MPVOLUMEVIEW, HIDE SLIDER AND ONLY SHOW ROUTE BUTTON **/
            volumeView.backgroundColor = UIColor.clearColor()
            let audioVolume = MPVolumeView(frame: CGRectMake(5, 10, 230, 50))
            volumeView.addSubview(audioVolume)
            audioVolume.showsVolumeSlider = false
            audioVolume.showsRouteButton = false
        
        /** ADD VOLUME SLIDER USING UISLIDER **/
            volumeSlider.minimumValueImage = UIImage(named: "min-volume")
            volumeSlider.maximumValueImage = UIImage(named: "max-volume")
        
            audioSlider.setThumbImage(UIImage(named: "slider_thumb"), forState: UIControlState.Normal)
    
            /**** EZAUDIO CONFIGURATION ****/
            audioPlot?.color = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
            audioPlot?.backgroundColor = nil
            audioPlot?.plotType = EZPlotType.Buffer
            audioPlot?.shouldFill = true
            audioPlot?.shouldMirror = true
            ezPlayer = EZAudioPlayer(delegate: self)
            // ezPlayer.shouldLoop = true
            // call EZAudio function to process the waveform
            openFile(fullName)
            //   ezPlayer.play()
            
            
            /***  PLAY AUDIO FILE IMPLEMENTATION ***/
            
            showRecordingTime()
            setSessionPlayAudio()
            playAudio(fullName)

//          try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker) // Animates Audio wave

        
        // Cloud Button showed to the right of Navigation Bar
        /*
        let cloudButton = UIImage(named: "cloud")
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(image: cloudButton, style: .Plain, target: self, action: "uploadFileToCloud"), animated: true)
        */
    }
    
    func audioNameEdit(){
        renameFile.hidden = false
        fileName.hidden = true
        renameFile.text = fileName.text
    }
    
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
    
    @IBAction func changeVolume(sender: UISlider) {
        player.volume = volumeSlider.value
    }
    func setSessionPlayAudio(){
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSessionCategoryPlayback)
//            try session.setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.AllowBluetooth)
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
        }
        catch{
            print("Unable to initialize set session active")
        }
    }
    
    func playAudio(fullName: NSURL){
        do{
            player = try AVAudioPlayer(contentsOfURL: fullName )
            player.delegate = self
            player.prepareToPlay()
            self.player.play()
            playing = true // Boolean to control slider status and update playing status
            self.timer = NSTimer(
                timeInterval: 1,
                target: self,
                selector: "updatePlayingTimer",
                userInfo: nil,
                repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            
        }
        catch let error as NSError?{
            print("Error playing audio \(error)")
        }
        
    }
    
    func updatePlayingTimer(){
        let seconds = Int(player.currentTime % 60)
        let minutes = Int(player.currentTime / 60)
        let totalSecDuration = Int(player.duration % 60)
        let totalMinDuration = Int(player.duration / 60)

//        timeLabel.text = String(format: "%.2d:%.2d", minutes, seconds)
        
        // Animate Slider when playing 
        audioSlider.minimumValue = 0.0
        audioSlider.maximumValue = Float(player.duration)
        audioSlider.setValue(Float(player.currentTime), animated: true)

        self.playCurrentTime.text = String(format: "%.1d:%.2d", minutes, seconds)
        self.playDuration.text = String(format: "-%.1d:%.2d", totalMinDuration - minutes, totalSecDuration - seconds )
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
        updater = CADisplayLink(target: self, selector: Selector("updatePlayingTimer"))
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
        updatePlayingTimer()
        // starts playing track again if it had been playing
        if (wasPlaying == true) {
            player.play()
            wasPlaying = false
        }
        
    }
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true{
            //            btnPlay.enabled = true
            playing = false
            updatePlayingTimer()
            self.timer.invalidate()
            //show playing time on top of playing scene
            /*
            let duration = NSInteger(player.duration)
            let seconds = duration
            let minutes = seconds / 60
            let hours = seconds / 3600
            timeLabel.hidden = true
            totalTime.hidden = false
            totalTime.text = NSString(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds) as String
*/
        }
        btnPlay.hidden = false
        btnPause.hidden = true
    }
    
    @IBAction func playSelectedRecording(sender: UIButton) {
        if (playing == false) {
            updater = CADisplayLink(target: self, selector: Selector("updatePlayingTimer"))
            updater.frameInterval = 1
            updater.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            updater_running = true
            playing = true
            //        btnPlay.enabled = false
            btnPause.hidden = false
            btnPlay.hidden = true
            totalTime.hidden = true
        //    timeLabel.hidden = false
            player.delegate = self
            player.prepareToPlay()
            player.play()
            updatePlayingTimer()
        }
        else {
            updatePlayingTimer()
           // player.pause()
            playing = false
        }
    }
    
    
    @IBAction func pausePlaying(sender: UIButton) {
        player.stop()
        btnPause.hidden = true
        btnPlay.hidden = false
        playing = false
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
            self.btnPause.hidden = true
            self.btnPlay.hidden = false
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
