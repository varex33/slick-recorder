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

/*** Initialize variables to show Blinking Label when recording starts **/
    var timer = NSTimer()
    var showRecLabel = true
    @IBOutlet weak var blinkingRec: UIButton!
    
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
    
    func blink(){
        print("test blink")
        if (showRecLabel == false){
            blinkingRec.hidden = false
            showRecLabel = true
        }
        else{
            blinkingRec.hidden = true
            showRecLabel = false
        }
//        self.view.backgroundColor = UIColor.grayColor()
//        self.view.backgroundColor = UIColor.redColor()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        btnResumeRecording.hidden = true
        
        timer = NSTimer(timeInterval: 0.5, target: self, selector:"blink", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        //  Translation to Swift from EZAUDIO Objective C code
        
        // Customizing the audio plot that'll show the current microphone input/recording

        wavePlot?.color = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        wavePlot?.plotType = EZPlotType.Rolling
        wavePlot?.shouldFill = true
        wavePlot?.shouldMirror = true
        
        
        // Start Recording
        
        print("recording started ..")
        
        // Create Audio Session
        
        let recordSettings = [
            AVSampleRateKey: 16000.0
            
            ] as [String: AnyObject]

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            recorder = try AVAudioRecorder(URL: audioPath.getUrl(), settings:recordSettings)

        } catch let error as NSError? {
            recorder = nil
            print("This is the error:\(error!)")

        }
        
        // Create an instance of the microphone and tell it to use this view controller instance as the delegate
        microphone = EZMicrophone(delegate: self, startsImmediately: true)
        
        
        /*
        // Recording Settings
        let recordSettings = [
//            AVFormatIDKey: kAudioFormatMPEG4AAC
            AVSampleRateKey: 16000.0,
            
            ] as [String: AnyObject]
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            recorder = try AVAudioRecorder(URL: audioPath.getUrl() , settings: recordSettings)
        }
        catch let error as NSError? {
            recorder = nil
            print(error!)
        }
        */
        if recorder != nil{
            recorder.prepareToRecord()
            recorder.record()
            recorder.delegate = self
        }
        
        // Show pause button while recording
        btnPause.hidden = false
        
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
        }
        
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        recorder.stop()
        btnResumeRecording.enabled = true
//        recButton.enabled = true
//        recButton.hidden = false
        btnPause.hidden = true
        timer.invalidate()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        recorder.pause()
        print("recording paused")
        btnPause.hidden = true
        btnResumeRecording.hidden = false
        microphone.stopFetchingAudio()
    }
    
    @IBAction func resumeRecording(sender: UIButton) {
        recorder.record()
        btnPause.hidden = false
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
