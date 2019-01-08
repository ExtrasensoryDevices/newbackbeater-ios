//
//  SoundProcessor.h
//  Backbeater
//
//  Created by Alina Khgolcheva on 2015-07-08.
//

#import <Foundation/Foundation.h>


@protocol SoundProcessorDelegate <NSObject>

-(void)soundProcessorDidDetectSensorIn:(BOOL) sensorIn;
-(void)soundProcessorDidDetectFirstStrike;
-(void)soundProcessorDidFindBPM:(Float64)bpm;

@end


@protocol SoundProcessorTestDelegate <NSObject>

-(void)soundProcessorDidDetectSensorIn:(BOOL) sensorIn;
-(void)soundProcessorDidDetectStrikeStart:(Float32) startValue;
-(void)soundProcessorDidDetectStrikeEnd:(Float32) endValue;
-(void)soundProcessorDidDetectTimeoutEnd:(Float32) maxValue;

@end




@interface SoundProcessor : NSObject

+(instancetype) sharedInstance;

@property (nonatomic, weak) id<SoundProcessorDelegate> delegate;

@property (nonatomic, readonly) BOOL sensorIn;


-(BOOL)start:(NSError**)error;
-(BOOL)stop:(NSError**)error;



// test functionality
@property (nonatomic, weak) id<SoundProcessorTestDelegate> testDelegate;
@property (nonatomic, assign) Float32 testStartThreshold;
@property (nonatomic, assign) Float32 testEndThreshold;
@property (nonatomic, assign) UInt64 testTimeout;


@end
