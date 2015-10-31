//
//  PlayRecordingViewController.swift
//  
//
//  Created by MBPRO on 10/18/15.
//
//

import UIKit
import AVFoundation

class PlayRecordingViewController: UIViewController,AVAudioPlayerDelegate{
    
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    var player: AVAudioPlayer!
    var fileName: String! // Saves the file Name recived from Table View
    var dirPath = AudioUrl() // Get the directory path or the recorded files
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dir = dirPath.getRecordingDirectory() 
        if let fullName = NSURL(fileURLWithPath: dir+"/"+fileName){
            player = AVAudioPlayer(contentsOfURL: fullName , error: nil)
            btnPlay.enabled = false
            player.delegate = self
            player.prepareToPlay()
            player.play()

        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSelectedRecording(sender: UIButton) {
        btnPlay.enabled = false
        player.delegate = self
        player.prepareToPlay()
        player.play()
    }
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if flag == true{
            btnPlay.enabled = true
        }
    }
    
    @IBAction func stopPlaying(sender: UIButton) {
        player.stop()
        btnPlay.enabled = true
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
