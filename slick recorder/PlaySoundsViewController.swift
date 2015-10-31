//
//  PlaySoundsViewController.swift
//  slick recorder
//
//  Created by MBPRO on 10/10/15.
//  Copyright (c) 2015 MBPRO. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var btnPlay: UIButton!
    var player: AVAudioPlayer! // Create recorder object
    var dirPath = AudioUrl()
    var fileName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dir = dirPath.getRecordingDirectory()
        if let fullName = NSURL(fileURLWithPath: dir+"/"+fileName!){

        player = AVAudioPlayer(contentsOfURL: fullName, error: nil)
        }
    }

    @IBAction func playSound(sender: UIButton) {
        player.prepareToPlay()
        player.play()
        btnPlay.enabled = false
        player.delegate = self
    }
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if flag == true{
            btnPlay.enabled = true
        }
    }
    
    @IBAction func stopSound(sender: UIButton) {
        player.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
