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
    var recordedAudio: RecordedAudio!
    var fileName: String{
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        //        dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
        // Set Names for Date and Time
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .MediumStyle
  //      dateFormatter.stringFromDate(date)
//        let recordingDate = date
        return  dateFormatter.stringFromDate(date)
    }

    func getRecordingDirectory()->String{
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return path[0]
    }
    func getUrl()->NSURL{
        let url = (getRecordingDirectory() as NSString).stringByAppendingPathComponent(fileName+".m4a")
        let finalUrl = NSURL(fileURLWithPath: url)
        return finalUrl
    }
    func deleteRecording(recName: String)-> Bool{
        let recodingPath = (getRecordingDirectory() as NSString).stringByAppendingPathComponent(recName)
        let flag: Bool
        do {
            try NSFileManager.defaultManager().removeItemAtPath(recodingPath)
            flag = true
        } catch let error as NSError? {
            flag = false
            print(error!)
        }
        
        return flag
    }
}
