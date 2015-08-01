//
//  SoundProcessor.m
//  Backbeater
//
//  Created by Alina on 2015-07-08.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

#import "SoundProcessor.h"
#import "ATSoundSessionIO.h"
#import "EnergyFunctionQueue.h"
#import "PublicUtilityWrapper.h"
#import "Settings.h"

#import <UIKit/UIKit.h>



#define kStartThreshold 0.15
#define kEndThreshold 0.1
#define kTimeout 100000000
               //10294458



@implementation SoundProcessor

ATSoundSessionIO *_soundSessionIO;
EnergyFunctionQueue *_energyFunctionQueue;

NSString *_logStringRaw;
NSString *_logStringEnergy;
NSString *_logStringEnergySpikes;

Float32 _maxEnergy;
Float32 _maxEnergyTotal;

Float32 _startThresholdWithSensitivity;

int _strikeCount;

BOOL _strikeState;

+(instancetype)sharedInstance {
    static dispatch_once_t once;
    static id _sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(instancetype)init {
    
    self = [super init];
    if (self != nil) {
        
        _startThreshold = kStartThreshold;
        _startThresholdWithSensitivity = _startThreshold;
        [self updateStartThreshold];
        _endThreshold = kEndThreshold;
        _timeout = kTimeout;
        
        _strikeState = NO;
        
        _energyFunctionQueue = [[EnergyFunctionQueue alloc] init];
        
        _soundSessionIO = [[ATSoundSessionIO alloc] init];
        __block SoundProcessor *blocksafeSelf = self;
        _soundSessionIO.inBlock = ^OSStatus(Float32* left, Float32*right, UInt32 inNumberFrames){
            [blocksafeSelf processData:left right:right numFrames:inNumberFrames];
            return noErr;
        };
        
        [_soundSessionIO prepareSoundProcessingGraph:nil];

        [self addObservers];
    }
    return self;
}

- (void)dealloc
{
    [self removeObservers];
    [_soundSessionIO disposeSoundProcessingGraph:nil];

}


UInt64 strikeStartTime = 0;
UInt64 strikeEndTime = 0;
-(void) processData:(Float32*)left right:(Float32*)right numFrames:(UInt32) numFrames
{
    Float32 *data = left;
    int i;
    _logStringRaw = @"";
    _logStringEnergy = @"";
    _logStringEnergySpikes = @"";
    _maxEnergy = 0.0;
    BOOL strikesInFrameDetected = NO;
    for (i=0; i<numFrames; i++) {
        Float32 energyLevel = [_energyFunctionQueue push:data[i]];
        
        //   _logStringRaw = [_logStringRaw stringByAppendingFormat:@"%f, ", data[0]];
        //    _logStringEnergy = [_logStringEnergy stringByAppendingFormat:@"%f, ", energyLevel];
        
        if (_strikeState == NO && energyLevel >= _startThresholdWithSensitivity) {
            UInt64 newTime = [PublicUtilityWrapper CAHostTimeBase_GetCurrentTime];
            
            UInt64 timeElapsedNs = [PublicUtilityWrapper CAHostTimeBase_AbsoluteHostDeltaToNanos:newTime oldTapTime:strikeEndTime];
            
            if (timeElapsedNs < _timeout) {
                // ignore
                NSLog(@"ignore strike: %llu", timeElapsedNs);
            } else {
                NSLog(@"strike started: %llu, delay: %llu", newTime, timeElapsedNs);
                _strikeState = YES;
                strikeStartTime = newTime;
                strikesInFrameDetected = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate soundProcessorDidDetectStrikeStart: @{@"energyLevel": [NSNumber numberWithFloat:energyLevel],
                                                                         @"time": [NSNumber numberWithFloat:strikeStartTime]}];
                });
                _strikeCount++;
            }
        } else if (_strikeState == YES && energyLevel <= _endThreshold) {
            _strikeState = NO;
            
            strikeEndTime = [PublicUtilityWrapper CAHostTimeBase_GetCurrentTime];
            UInt64 timeElapsedNs = [PublicUtilityWrapper CAHostTimeBase_AbsoluteHostDeltaToNanos:strikeEndTime oldTapTime:strikeStartTime];
            
             NSLog(@"strike ended: %llu", strikeEndTime);
            strikesInFrameDetected = YES;
            
            Float64 delayFator = 0.1;
            Float64 timeElapsedInSec = Float64(timeElapsedNs) * 10.0e-9 * delayFator;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate soundProcessorDidDetectStrikeEnd:@{@"energyLevel": [NSNumber numberWithFloat:energyLevel],
                                                                  @"time": [NSNumber numberWithFloat:strikeEndTime],
                                                                  @"timeElapsedNs": [NSNumber numberWithFloat:timeElapsedNs],
                                                                  @"timeElapsedInSec": [NSNumber numberWithFloat:timeElapsedInSec]}];
            });
        }

        
        
        
        
        if (_maxEnergy < energyLevel) {
            _maxEnergy = energyLevel;
            if (_maxEnergyTotal < _maxEnergy) {
                _maxEnergyTotal = _maxEnergy;
            }
        }
    }
    if (strikesInFrameDetected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate soundProcessorProcessedFrame:@{@"maxPerFrame": [NSNumber numberWithFloat:_maxEnergy],
                                                          @"maxTotal": [NSNumber numberWithFloat:_maxEnergyTotal]}];
        });
    }
    if (_maxEnergy > _startThresholdWithSensitivity) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"\n------------start---------------\n%@\n\n%@\n------------end---------------", _logStringRaw, _logStringEnergy);
//        });
    }
//    NSLog(@"-----------%f----------------", _maxEnergy);
}

-(BOOL)startSoundProcessing:(NSError**)error
{
    //TODO: uncomment
//    if (!_sensorIn){
//        return NO;
//    }
    _maxEnergyTotal = 0.0;
    _strikeState = NO;
    _strikeCount = 0;
    [_energyFunctionQueue clear];
    [_soundSessionIO startSoundProcessing:error];
    
    [self updateInputChannel];
    
    
    return error == nil;
}

-(BOOL)stopSoundProcessing:(NSError**)error
{
    if (_soundSessionIO.isProcessingSound) {
        [_soundSessionIO stopSoundProcessing:error];
    }
    NSLog(@"Strikes total: %i,    Max energy: %f", _strikeCount, _maxEnergyTotal);
    _strikeState = NO;
    _strikeCount = 0;
    _maxEnergyTotal = 0.0;
    [_energyFunctionQueue clear];
    return error == nil;
}



-(void) processEnergyLevel: (Float32) value
{
    
////    _logStringEnergy = [_logStringEnergy stringByAppendingFormat:@"%f, ", value];
//    
//    if (value > 0) {
////         _logStringEnergySpikes = [_logStringEnergySpikes stringByAppendingFormat:@"%f, ", value];
//    }
//    if (value > 0) {
//        //NSLog(@"strike state: %@, value: %f ", (strikeState?@"YES":@"NO"), value);
//    }
//    if (_strikeState == NO && value >= _startTheshold) {
//        //NSLog(@" ----------------------- Started ----------------------- ");
//        //NSLog(@"Strike start, value: %f ", value);
//        _strikeState = YES;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.delegate soundProcessorDidDetectStrikeStart: @{@"energyLevel": [NSNumber numberWithFloat:value]}];
//        });
//        _strikeCount++;
//    } else if (_strikeState == YES && value <= _endTheshold) {
//        //NSLog(@" ------------------------ Ended ------------------------ ");
//        //NSLog(@"Strike end, value: %f ", value);
//        _strikeState = NO;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.delegate soundProcessorDidDetectStrikeEnd:@{@"energyLevel": [NSNumber numberWithFloat:value]}];
//        });
//    }
}

#pragma mark - Properties

-(void)setSensorPluggedIn:(BOOL) sensorIn {
    if (_sensorIn != sensorIn) {
        _sensorIn = sensorIn;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate soundProcessorDidDetectSensorIn: self.sensorIn];
        });
        //TODO: uncomment
//        if (_sensorIn) {
//            NSError *error
//            [self startSoundProcessing:&error];
//            if (error) {
//                NSLog(@"Cannot start sound processing: %@", error);
//            }
//        } else {
//            [self stopSoundProcessing:nil];
//        }
    }
}



#pragma mark - Notifications



-(void)addObservers
{
    AVAudioSession *session = [ AVAudioSession sharedInstance ];
    // Register for Route Change notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleRouteChange:)
                                                 name: AVAudioSessionRouteChangeNotification
                                               object: session];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleInterruption:)
                                                 name: AVAudioSessionInterruptionNotification
                                               object: session];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleMediaServicesWereReset:)
                                                 name: AVAudioSessionMediaServicesWereResetNotification
                                               object: session];
    
    [[Settings sharedInstance] addObserver:self forKeyPath:@"sensitivity" options:NSKeyValueObservingOptionNew context:nil];

}

-(void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVAudioSessionRouteChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVAudioSessionInterruptionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVAudioSessionMediaServicesWereResetNotification" object:nil];
    
    [[Settings sharedInstance] removeObserver:self forKeyPath:@"sensitivity"];

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == Settings.sharedInstance && [keyPath isEqualToString:@"sensitivity"]) {
        [self updateStartThreshold];
    }
}

-(void) updateStartThreshold
{
    float sensitivity = Settings.sharedInstance.sensitivity * 100.0;
//    _startThresholdWithSensitivity = - (pow(sensitivity,3) - 225.0 * pow(sensitivity,2) + 17250.0 * sensitivity - 500000.0) / 500000.0;
    
    float A = 0;
    float B = 0;
    float C = 0;
    
    if (sensitivity < 20){
        A = 7; B = 197; C = 19;
    } else if (sensitivity < 90) {
        A = 1; B = 95; C = 25;
    } else {
        A = 3; B = 310; C = 200;
    }
    
    _startThresholdWithSensitivity = - (A * sensitivity - B ) / C;
    
    NSLog(@"_startThresholdWithSensitivity: %f", _startThresholdWithSensitivity);
    
    NSString *msg = [NSString stringWithFormat:@"sensitivity: %.2f, startThreshold: %.2f", sensitivity, _startThresholdWithSensitivity];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Threshold" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}


-(void)handleMediaServicesWereReset:(NSNotification*)notification{
    //  If the media server resets for any reason, handle this notification to reconfigure audio or do any housekeeping, if necessary
    //    • No userInfo dictionary for this notification
    //      • Audio streaming objects are invalidated (zombies)
    //      • Handle this notification by fully reconfiguring audio
    NSLog(@"handleMediaServicesWereReset: %@ ",[notification name]);
    
}


-(void)handleInterruption:(NSNotification*)notification{
    NSInteger reason = 0;
    NSString* reasonStr=@"";
    if ([notification.name isEqualToString:@"AVAudioSessionInterruptionNotification"]) {
        //Posted when an audio interruption occurs.
        reason = [[[notification userInfo] objectForKey:@" AVAudioSessionInterruptionTypeKey"] integerValue];
        if (reason == AVAudioSessionInterruptionTypeBegan) {
            //       Audio has stopped, already inactive
            //       Change state of UI, etc., to reflect non-playing state
            if(_soundSessionIO.isProcessingSound)[_soundSessionIO stopSoundProcessing:nil];
        }
        
        if (reason == AVAudioSessionInterruptionTypeEnded) {
            //       Make session active
            //       Update user interface
            //       AVAudioSessionInterruptionOptionShouldResume option
            reasonStr = @"AVAudioSessionInterruptionTypeEnded";
            NSNumber* seccondReason = [[notification userInfo] objectForKey:@"AVAudioSessionInterruptionOptionKey"] ;
            switch ([seccondReason integerValue]) {
                case AVAudioSessionInterruptionOptionShouldResume:
                    //          Indicates that the audio session is active and immediately ready to be used. Your app can resume the audio operation that was interrupted.
                    break;
                default:
                    break;
            }
        }
        
        
        if ([notification.name isEqualToString:@"AVAudioSessionDidBeginInterruptionNotification"]) {
            if (_soundSessionIO.isProcessingSound) {
                
            }
            //      Posted after an interruption in your audio session occurs.
            //      This notification is posted on the main thread of your app. There is no userInfo dictionary.
        }
        if ([notification.name isEqualToString:@"AVAudioSessionDidEndInterruptionNotification"]) {
            //      Posted after an interruption in your audio session ends.
            //      This notification is posted on the main thread of your app. There is no userInfo dictionary.
        }
        if ([notification.name isEqualToString:@"AVAudioSessionInputDidBecomeAvailableNotification"]) {
            //      Posted when an input to the audio session becomes available.
            //      This notification is posted on the main thread of your app. There is no userInfo dictionary.
        }
        if ([notification.name isEqualToString:@"AVAudioSessionInputDidBecomeUnavailableNotification"]) {
            //      Posted when an input to the audio session becomes unavailable.
            //      This notification is posted on the main thread of your app. There is no userInfo dictionary.
        }
        
    };
    NSLog(@"handleInterruption: %@ reason %@",[notification name],reasonStr);
}

-(void)handleRouteChange:(NSNotification*)notification{
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    NSString* reasonStr = @"";
//    NSInteger  reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
//    //  AVAudioSessionRouteDescription* prevRoute = [[notification userInfo] objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
//    switch (reason) {
//        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
//            reasonStr = @"The route changed because no suitable route is now available for the specified category.";
//            break;
//        case AVAudioSessionRouteChangeReasonWakeFromSleep:
//            reasonStr = @"The route changed when the device woke up from sleep.";
//            break;
//        case AVAudioSessionRouteChangeReasonOverride:
//            reasonStr = @"The input route was overridden by the app.";
//            break;
//        case AVAudioSessionRouteChangeReasonCategoryChange:
//            reasonStr = @"The category of the session object changed.";
//            break;
//        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
//            reasonStr = @"The previous audio input path is no longer available.";
//            break;
//        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
//            reasonStr = @"A preferred new audio output path is now available.";
//            break;
//        case AVAudioSessionRouteChangeReasonUnknown:
//        default:
//            reasonStr = @"The reason for the change is unknown.";
//            break;
//    }
    
    [self updateInputChannel];
    
}


-(void) updateInputChannel
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSArray *inputs = session.currentRoute.inputs;
    AVAudioSessionPortDescription *input = inputs.count > 0 ? inputs[0] : nil;
    if ([input.portType isEqualToString: AVAudioSessionPortHeadsetMic]) {
        // sensor plugged in
        [self setSensorPluggedIn:true];
    } else { // AVAudioSessionPortBuiltInMic
        // sensor unplugged
        [self setSensorPluggedIn:false];
    }
    
}

@end