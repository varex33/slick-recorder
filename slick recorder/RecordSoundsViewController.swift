//
//  RecordSoundsViewController.swift
//  slick recorder
//
//  Created by MBPRO on 10/9/15.
//  Copyright (c) 2015 MBPRO. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var btnResumeRecording: UIButton!

    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var btnPause: UIButton!
        // Object to create an instance of AVAudioRecorder class
    var recorder: AVAudioRecorder!
    
    // Object to create the name of Audio file and retrieve its path
    var audioPath = AudioUrl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnResumeRecording.hidden = true
      //  println(audioPath.getUrl())
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startRecording(sender: UIButton) {
    // Show stop button when recording starts
    btnPause.hidden = false
    micButton.hidden = true
        println("recording in started ..")
    var err : NSError?
    recorder = AVAudioRecorder(URL: audioPath.getUrl() , settings: nil, error: &err)
    recorder.prepareToRecord()
    recorder.record()
    recorder.delegate = self

    }
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        
        if flag == true{
            // Get name of the recording  by using lastPathComponent
            let recordingName = recorder.url.lastPathComponent
            
        // Since we need to pass the name of the recording to the next scene we cast sender as recordingName
        self.performSegueWithIdentifier("stopRecording", sender: recordingName)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stopRecording"{
            
            // We need to specify the type of playSound as PlaySoundsViewController so we can pull properties
            let playSound: PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            
            // Sender already have the name of the recording so we need to only cast it as String
            let data = sender as! String
            
            // We created variable receivedAudio as property of the PlaySoundsViewController class so we can send the object we saved on data
            playSound.fileName = data
        }
    }

    @IBAction func stopRecording(sender: UIButton) {
        recorder.stop()
        micButton.enabled = true
        micButton.hidden = false
        btnPause.hidden = true
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        recorder.pause()
        println("recording paused")
        btnPause.hidden = true
        btnResumeRecording.hidden = false
    }
    
    @IBAction func resumeRecording(sender: UIButton) {
        recorder.record()
        btnPause.hidden = false
        btnResumeRecording.hidden = true
        println("recording after pause")
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
