//
//  RecordedAudio.swift
//  slick-recorder-new
//
//  Created by MBPRO on 11/28/15.
//  Copyright © 2015 MBPRO. All rights reserved.
//

import Foundation

class RecordedAudio {
    var audioUrl: NSURL!
    var audioTitle: String!
    var recordingDate: NSDate!
    var recordingDirectory: NSString!
    var fileName: String{
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        //        dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
        // Set Names for Date and Time
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .MediumStyle
        audioTitle = dateFormatter.stringFromDate(date)
        recordingDate = date
        return  dateFormatter.stringFromDate(date)
    }
    func test(){
        print("test")
    }

}