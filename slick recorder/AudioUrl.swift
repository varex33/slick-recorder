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
    
    var fileName: String{
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
        // Set Names for Date and Time
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .MediumStyle
        return  dateFormatter.stringFromDate(date)
    }
    func getRecordingDirectory()->String{
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) 
        return path[0]
    }
    func getUrl()->NSURL{
        var url = (getRecordingDirectory() as NSString).stringByAppendingPathComponent(fileName+".wav")
        let finalUrl = NSURL(fileURLWithPath: url)
        return finalUrl
    }
    func deleteRecording(recName: String)-> Bool{
        var error: NSError?
        let recodingPath = (getRecordingDirectory() as NSString).stringByAppendingPathComponent(recName)
        let ok: Bool
        do {
            try NSFileManager.defaultManager().removeItemAtPath(recodingPath)
            ok = true
        } catch let error1 as NSError {
            error = error1
            ok = false
        }
        
        if error != nil{
            print(error, terminator: "")
        }
        return ok
    }
}
