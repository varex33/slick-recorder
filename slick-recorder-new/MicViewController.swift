//
//  MicViewController.swift
//
//
//  Created by MBPRO on 12/16/15.
//
//

import UIKit
import AVFoundation

protocol PlayerDelegate : class {
    func soundFinished(sender : AnyObject)
}


class MicViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, EZMicrophoneDelegate,EZRecorderDelegate, EZAudioPlayerDelegate {
    
//    var wave: WaveForm = WaveForm()
    
    @IBOutlet weak var btnResumeRecording: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var initialTimeLabel: UILabel!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var buttonFinish: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var matrixHolder: UIImageView!
    @IBOutlet weak var greenNeon: UIButton!
    @IBOutlet weak var neonMessage: UILabel!
    
    var imageArray = [UIImage]()

/*** Initialize variables to show Blinking Label when recording starts **/
    var timer = NSTimer()
    var date = NSDate()
    var blinkRecFlag = true
    var blinkPauseFlag = false
//    @IBOutlet weak var blinkingRec: UIButton!
//    @IBOutlet weak var blinkingRec2: UIButton!
    
//    @IBOutlet weak var blinkingPause: UIButton!
    
    /*** EZAdio declarations ****/
    @IBOutlet weak var wavePlot: EZAudioPlotGL?
     var microphone: EZMicrophone!
    
     var fileName: String? // save the name of recorded file
    
    // Object to create an instance of AVAudioRecorder class
    var recorder: AVAudioRecorder!
    
    // Object to create the name of Audio file and retrieve its path
    var audioPath = AudioUrl()
    
    var player: AVAudioPlayer! // Create recorder object
    var recordedAudio = RecordedAudio()
    
     var recording : Bool = false //indicates if track started recording

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateLabel.text = dateFormatter.stringFromDate(date)
    }
    
    @IBAction func startRecording(sender: UIButton) {
        btnResumeRecording.hidden = true
        buttonClose.hidden = true
        buttonFinish.hidden = false
     //   readyLabel.hidden = true
        dateLabel.hidden = false
        timeLabel.hidden = false
        greenNeon.hidden = true
        neonMessage.hidden = true
        
        /** Matrix Animation ****/
        
        for index in 1...30 {
            let matrixImage = "matrix\(index).jpg"
            imageArray.append(UIImage(named: matrixImage)!)
        }
        matrixHolder.animationImages = imageArray
        matrixHolder.animationDuration = 2
        matrixHolder.startAnimating()
            
        /**** REC blinking when Recording ****/
        /*
        timer = NSTimer(timeInterval: 0.5, target: self, selector:"blink", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        */
        
        /*** DRAW WAVE WITH EZAUDIO ****/
        
        // Customizing the audio plot that'll show the current microphone input/recording
      //  wavePlot?.color = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        wavePlot?.plotType = EZPlotType.Rolling
        wavePlot?.shouldFill = true
        wavePlot?.shouldMirror = true

       // wavePlot?.backgroundColor = UIColor(patternImage: UIImage(named: "web-container.png")!)
       
        /*** RECORDING IMPLEMENTATION ****/
        
        //Setups recording session and permission
        recordWithPermission(true);
        
        print("recording started ..")
        
        // Create an instance of the microphone and tell it to use this view controller instance as the delegate
        microphone = EZMicrophone(delegate: self, startsImmediately: true)
        
        
        
        // Show pause button while recording
        initialTimeLabel.hidden = true
        timeLabel.hidden = false
        recordButton.hidden = true
        btnPause.hidden = false

        
    }
    func recordWithPermission(setup: Bool){
        let session = AVAudioSession.sharedInstance()
        if(session.respondsToSelector("requestRecordPermission:")){
                    self.setSessionPlayAndRecord()
                        if(setup){
                            setupRecorder()
                        }
                            recorder.record()
                            recording = true
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(
                            0.1,
                            target: self,
                            selector: "updateAudioTimer",
                            userInfo: nil,
                            repeats: true)
        }
        else{
            print("Permission to record denied")
        }
        
    }

    func setSessionPlayAndRecord(){
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        }
        catch{
            print("Unable to set Audio session caterogy")
        }
        /*
        do{
            try session.setMode("AVAudioSessionModeVoiceChat")
        }
        catch{
            print("Unable to set Audio session mode")
        }*/
        do{
            try session.setActive(true)
        }
        catch{
            print("Unable to set Audio session active")
        }
    }
    
    func closeAudioSession(){
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setActive(false)
            timer.invalidate()
        }
        catch let error as NSError{
            print("unable to deactive session")
            print(error.localizedDescription)
        }
    }


    func setupRecorder(){
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(unsignedInt:kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 128000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        
        do {
            recorder = try AVAudioRecorder(URL: audioPath.getUrl(), settings:recordSettings)
            recorder.delegate = self
            recorder.meteringEnabled = true
          //  recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let error as NSError {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
      func updateAudioTimer() {
      //  let timer = recorder.currentTime
        let seconds = NSInteger(recorder.currentTime % 60)
        let minutes = NSInteger(recorder.currentTime / 60)
        timeLabel.text = NSString(format: "%.2d:%.2d:%.2d",minutes / 60, minutes, seconds) as String
    }

    
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
        self.wavePlot?.updateBuffer(buffer[0], withBufferSize: bufferSize);
        });
    }
    
    override func viewWillAppear(animated: Bool) {
        self.hidesBottomBarWhenPushed = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
/*
    @IBAction func doneButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
  */
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print(error!)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if flag == true{
            recordedAudio.audioUrl = recorder.url
            recordedAudio.audioTitle = recorder.url.lastPathComponent
//            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
            print("recording finished")
            self.dismissViewControllerAnimated(true, completion: nil)

        }
        
    }
    
    @IBAction func quitRecording(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func finishRecording(sender: UIButton) {
        if recording == true || btnResumeRecording.hidden == false{
            recorder.stop()
            microphone.stopFetchingAudio()
            closeAudioSession()
            self.dismissViewControllerAnimated(true, completion: nil)
        }

        
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        if recording{
            recorder.stop()
            microphone.stopFetchingAudio()
            let session = AVAudioSession.sharedInstance()
            do{
                try session.setActive(false)
                btnResumeRecording.enabled = true
                timer.invalidate()
            }
            catch let error as NSError{
                print("unable to deactive session")
                print(error.localizedDescription)
            }
        }
        else{
             self.dismissViewControllerAnimated(true, completion: nil)
        }

//        recButton.enabled = true
//        recButton.hidden = false
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        recorder.pause()
        blinkPauseFlag = true
        recording = false
        print("recording paused")
        btnPause.hidden = true
        btnResumeRecording.hidden = false
        microphone.stopFetchingAudio()
        matrixHolder.stopAnimating()
    }
    
    @IBAction func resumeRecording(sender: UIButton) {
        recorder.record()
        btnPause.hidden = false
        matrixHolder.startAnimating()
     //   blinkingPause.hidden = true
        recording = true
        btnResumeRecording.hidden = true
        microphone.startFetchingAudio()
        print("recording after pause")
    }
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
        let audio: PlayRecordingViewController = segue.destinationViewController as! PlayRecordingViewController
        
        // cast sender as the object we will use to send the audio name and path
        let data = sender as! RecordedAudio

        // Pass the selected object to the new view controller.
        audio.recordedAudio = data
    }
    
    */
}
