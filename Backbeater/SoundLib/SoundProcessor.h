//
//  SoundProcessor.h
//  Backbeater
//
//  Created by Alina on 2015-07-08.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SoundProcessorDelegate <NSObject>

-(void)soundProcessorDidDetectSensorIn:(BOOL) sensorIn;
//-(void)soundProcessorDidDetectStrikeStart:(NSDictionary*) params;
//-(void)soundProcessorDidDetectStrikeEnd:(NSDictionary*) params;
//-(void)soundProcessorProcessedFrame:(NSDictionary*) params;


-(void)soundProcessorDidDetectFirstStrike;
-(void)soundProcessorDidFindBPM:(Float64)bpm;

@end

@interface SoundProcessor : NSObject

+(instancetype) sharedInstance;

@property (nonatomic, weak) id<SoundProcessorDelegate> delegate;

@property (nonatomic, readonly) BOOL sensorIn;
//@property (nonatomic, assign) Float32 startThreshold;
//@property (nonatomic, assign) Float32 startThresholdWithSensitivity;
//@property (nonatomic, assign) Float32 endThreshold;
//@property (nonatomic, assign) UInt64 timeout;


-(BOOL)start:(NSError**)error;
-(BOOL)stop:(NSError**)error;

@end
