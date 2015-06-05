//
//  BBSetting.h
//  BB
//
//  Created by SUNG YOON on 12-03-28.
//  Copyright (c) 2012 Bamsom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSetting : NSObject

@property (nonatomic) BOOL mute;
@property (nonatomic) BOOL sensorIn;

@property (nonatomic) BOOL inMusicPlayer;

@property (nonatomic) NSInteger bpm;
@property (nonatomic, assign) NSInteger metSound;
@property (nonatomic, assign) float sensitivity;

@property (nonatomic, assign) float foundBPM;
@property (nonatomic, assign) float foundBPMf;
@property (nonatomic, assign) BOOL sensitivityFlash;


+ (BBSetting *)sharedInstance;

@end
