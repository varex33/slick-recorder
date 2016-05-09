//
//  RecordSoundsViewController.swift
//  slick recorder
//
//  Created by MBPRO on 10/9/15.
//  Copyright (c) 2015 MBPRO. All rights reserved.
//

import UIKit
import AVFoundation



class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate, EZMicrophoneDelegate, EZRecorderDelegate, EZAudioPlayerDelegate {

    @IBOutlet weak var audioPlot: EZAudioPlotGL!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var btnPause: UIButton!
    /*** EZAdio declarations ****/
    @IBOutlet weak var wavePlot: EZAudioPlotGL?
    var microphone: EZMicrophone!
    
    // Object to create an instance of AVAudioRecorder class
    var recorder: AVAudioRecorder!
    
    // Object to create the name of Audio file and retrieve its path
    var audioPath = AudioUrl()
    
    var player: AVAudioPlayer! // Create recorder object
    var recordedAudio = RecordedAudio()
    
    // Display timer
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
            }
    
    @IBAction func startRecording(sender: UIButton) {
        //Setups recording session and permission
        beginDrawingAudioWave()
        btnPause.hidden = false
        recordButton.hidden = true
        recordWithPermission(true);
        print("recording started ..")


    }
    func beginDrawingAudioWave(){
        /*** AUDIO WAVE WITH EZAUDIO ****/
        
        // Customizing the audio plot that'll show the current microphone input/recording
        wavePlot?.color = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        wavePlot?.plotType = EZPlotType.Rolling
        wavePlot?.shouldFill = true
        wavePlot?.shouldMirror = true
        
        
        // Create an instance of the microphone and tell it to use this view controller instance as the delegate
        microphone = EZMicrophone(delegate: self, startsImmediately: true)

    }
    
    func recordWithPermission(setup: Bool){
        let session = AVAudioSession.sharedInstance()
        if(session.respondsToSelector("requestRecordPermission:")){
            self.setSessionPlayAndRecord()
            if(setup){
                self.setupRecorder()
            }
            self.recorder.record()
            
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
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let error as NSError {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    func updateAudioTimer() {
        //  let timer = recorder.currentTime
        let seconds = NSInteger(recorder.currentTime % 60)
        let minutes = NSInteger(seconds / 60)
        timeLabel.text = NSString(format: "%.2d:%.2d:.2d",minutes, seconds, recorder.currentTime) as String
        
    }

    @IBAction func pauseRecording(sender: UIButton) {
        recorder.pause()
        print("recording paused")
        btnPause.hidden = true
        recordButton.hidden = false
        microphone.stopFetchingAudio()

    }
    @IBAction func stopButton(sender: UIButton) {
        recorder.stop()
        btnPause.hidden = true
        timer.invalidate()
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
}
