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


class MicViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var btnResumeRecording: UIButton!
    
    @IBOutlet weak var recButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    
    
    var fileName: String? // save the name of recorded file
    
    // Object to create an instance of AVAudioRecorder class
    var recorder: AVAudioRecorder!
    
    // Object to create the name of Audio file and retrieve its path
    var audioPath = AudioUrl()
    
    var player: AVAudioPlayer! // Create recorder object
    
    var recordedAudio = RecordedAudio()
    
    var delegate : PlayerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnResumeRecording.hidden = true
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.hidesBottomBarWhenPushed = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        

    }
    
    @IBAction func startRecording(sender: UIButton) {
        // Show stop button when recording starts
        btnPause.hidden = false
        recButton.hidden = true
        print("recording started ..")
        
        // Create Audio Session
        
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
        if recorder != nil{
            recorder.prepareToRecord()
            recorder.record()
            recorder.delegate = self
        }
    }
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print(error!)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if flag == true{
            recordedAudio.audioUrl = recorder.url
            recordedAudio.audioTitle = recorder.url.lastPathComponent
            //fileName = recorder.url.lastPathComponent
            print("recording finished")
        }
        
    }
    
    @IBAction func playRecording(sender: UIButton) {
        //       let dir = audioPath.getRecordingDirectory()
        do{
            //            let fullName = NSURL(fileURLWithPath: dir+"/"+fileName!)
            //            player = try? AVAudioPlayer(contentsOfURL: fullName)
            player = try? AVAudioPlayer(contentsOfURL: recordedAudio.audioUrl)
            
        }
        if player == nil{
            print("error while playing")
        }
        if player != nil{
            print("recording playing")
            player.delegate = self
            player.prepareToPlay()
            player.play()
            btnPlay.enabled = false
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.delegate?.soundFinished(self)
        
        if flag == true{
            btnPlay.enabled = true
            print("finished playing")
        }
        else{
            print("still playing")
        }
    }
    
    
    @IBAction func stopRecording(sender: UIButton) {
        recorder.stop()
        recButton.enabled = true
        recButton.hidden = false
        btnPause.hidden = true
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        recorder.pause()
        print("recording paused")
        btnPause.hidden = true
        btnResumeRecording.hidden = false
    }
    
    @IBAction func resumeRecording(sender: UIButton) {
        recorder.record()
        btnPause.hidden = false
        btnResumeRecording.hidden = true
        print("recording after pause")
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
