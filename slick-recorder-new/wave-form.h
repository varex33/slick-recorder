//
//  wave-form.h
//  slick-recorder-new
//
//  Created by MBPRO on 1/19/16.
//  Copyright © 2016 MBPRO. All rights reserved.
//

#ifndef wave_form_h
#define wave_form_h


#endif /* wave_form_h */

#import <UIKit/UIKit.h>

// Import EZAudio header
#import "EZAudio/EZAudio.h"

@interface WaveForm : NSObject <EZAudioPlayerDelegate, EZMicrophoneDelegate, EZRecorderDelegate>


/**
 Use a OpenGL based plot to visualize the data coming in
 */
//@property (nonatomic, weak) IBOutlet EZAudioPlotGL *recordingAudioPlot;

/**
 The microphone component
 */
//@property (nonatomic, strong) EZMicrophone *microphone;



@end
