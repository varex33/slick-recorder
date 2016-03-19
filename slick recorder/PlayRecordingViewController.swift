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


class PlayRecordingViewController: UIViewController,AVAudioPlayerDelegate{
    
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    var player: AVAudioPlayer!
    var fileName: String! // Saves the file Name recived from Table View
    var dirPath = AudioUrl() // Get the directory path of the recording
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dir = dirPath.getRecordingDirectory() 
        do{
            let fullName = NSURL(fileURLWithPath: dir+"/"+fileName)
            player = try? AVAudioPlayer(contentsOfURL: fullName )
            btnPlay.enabled = false
            player.delegate = self
            player.prepareToPlay()
            player.play()

        }
        // Cloud Button showed to the right of Navigation Bar
        let cloudButton = UIImage(named: "cloud")
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(image: cloudButton, style: .Plain, target: self, action: "uploadFileToCloud"), animated: true)
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
//        let fileData = "Hello!".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            // Get Recording Path
        let recordingPath = dirPath.getRecordingDirectory()+"/"+fileName
        let data = NSData(contentsOfFile: recordingPath)

        client.filesUpload(path: "/"+fileName, body: data!).response { response, error in
            if let metadata = response {
                print("Uploaded file name: \(metadata.name)")
                print("Uploaded file revision: \(metadata.rev)")
                
                // Get file (or folder) metadata
                client.filesGetMetadata(path: "/"+self.fileName).response { response, error in
                    if let metadata = response {
                        print("Name: \(metadata.name)")
                        if let file = metadata as? Files.FileMetadata {
                            print("This is a file.")
                            print("File size: \(file.size)")
                        } else if let folder = metadata as? Files.FolderMetadata {
                            print("This is a folder.")
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
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
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
