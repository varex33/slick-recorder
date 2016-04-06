//
//  AudioUrl.swift
//  slick recorder
//
//  Created by MBPRO on 10/9/15.
//  Copyright (c) 2015 MBPRO. All rights reserved.
//

import Foundation
// Class to get the path of the audio file
class AudioUrl{
//    var recordedAudio: RecordedAudio!
    var fileName: String{
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        // Set Names for Date and Time
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .MediumStyle
   //     audioTitle = dateFormatter.stringFromDate(date)
  //      recordingDate = date
        return  dateFormatter.stringFromDate(date)
    }

    func getRecordingDirectory()->String{
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return path[0]
    }
    func getUrl()->NSURL{
        let url = (getRecordingDirectory() as NSString).stringByAppendingPathComponent(fileName+".wav")
        let finalUrl = NSURL(fileURLWithPath: url)
        return finalUrl
    }
    func deleteRecording(recName: String)-> Bool{
        let recodingPath = (getRecordingDirectory() as NSString).stringByAppendingPathComponent(recName)
        let ok: Bool
        do {
            try NSFileManager.defaultManager().removeItemAtPath(recodingPath)
            ok = true
        } catch let error as NSError? {
            ok = false
            print(error!)
        }
        
        return ok
    }
}
