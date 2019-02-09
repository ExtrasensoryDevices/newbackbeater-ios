//
//  SoundProcessor.h
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-07-08.
//

#import <Foundation/Foundation.h>


@protocol SoundProcessorDelegate

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

@property (nonatomic, weak) id<SoundProcessorDelegate> delegate;

@property (nonatomic, readonly) BOOL sensorIn;


-(instancetype)initWithIdleTimeout:(Float64) idleTimeout;
-(BOOL)start:(NSInteger) sensivity error: (NSError**)error;
-(BOOL)stop:(NSError**)error;

-(void)setSensivity:(NSInteger) sensivity;


// test functionality
@property (nonatomic, weak) id<SoundProcessorTestDelegate> testDelegate;
@property (nonatomic, assign) Float32 testStartThreshold;
@property (nonatomic, assign) Float32 testEndThreshold;
@property (nonatomic, assign) UInt64 testTimeout;


@end
