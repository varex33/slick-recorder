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
        dateFormatter.dateFormat = "ss-mm-hh-MM-yyyy"
        return  dateFormatter.stringFromDate(date)
    }
    func getRecordingDirectory()->String{
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
        return path[0]
    }
    func getUrl()->NSURL{
        var url = getRecordingDirectory().stringByAppendingPathComponent(fileName+".mov")
        let finalUrl = NSURL(fileURLWithPath: url)
        return finalUrl!
    }
    func deleteRecording(recName: String)-> Bool{
        var error: NSError?
        let recodingPath = getRecordingDirectory().stringByAppendingPathComponent(recName)
        let ok: Bool = NSFileManager.defaultManager().removeItemAtPath(recodingPath, error: &error)
        
        if error != nil{
            print(error)
        }
        return ok
    }
}
