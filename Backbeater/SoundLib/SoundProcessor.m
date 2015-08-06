//
//  SoundProcessor.m
//  Backbeater
//
//  Created by Alina on 2015-07-08.
//

#import "SoundProcessor.h"
#import "ATSoundSessionIO.h"
#import "EnergyFunctionQueue.h"
#import "PublicUtilityWrapper.h"
#import "Settings.h"

#import <UIKit/UIKit.h>



#define kStartThreshold 0.15
#define kEndThreshold 0.1
#define kTimeout 250000000 // 250 000 000ns = 250ms
               //10294458




@implementation SoundProcessor

ATSoundSessionIO *_soundSessionIO;
EnergyFunctionQueue *_energyFunctionQueue;

NSString *_logStringRaw;
NSString *_logStringEnergy;
NSString *_logStringEnergySpikes;

Float32 _maxEnergy;
Float32 _maxEnergyTotal;

Float32 _startThreshold;
Float32 _endThreshold;
Float32 _timeout;

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
        _endThreshold = kEndThreshold;
        _timeout = kTimeout;
        [self updateStartThreshold];
        
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


UInt64 _strikeStartTime = 0;
UInt64 _strikeEndTime = 0;
-(void) processData:(Float32*)left right:(Float32*)right numFrames:(UInt32) numFrames
{
    Float32 *data = left;
    int i;
    for (i=0; i<numFrames; i++) {
        Float32 energyLevel = [_energyFunctionQueue push:data[i]];
        
        if (_strikeState == NO && energyLevel >= _startThreshold) {
            UInt64 newTime = [PublicUtilityWrapper CAHostTimeBase_GetCurrentTime];
            
            UInt64 timeElapsedNs = [PublicUtilityWrapper CAHostTimeBase_AbsoluteHostDeltaToNanos:newTime oldTapTime:_strikeEndTime];
            
            if (timeElapsedNs < _timeout) {
                // ignore
            } else {
                _strikeState = YES;
                _strikeStartTime = newTime;
            }
        } else if (_strikeState == YES && energyLevel <= _endThreshold) {
            _strikeState = NO;
            
            _strikeEndTime = [PublicUtilityWrapper CAHostTimeBase_GetCurrentTime];
            [self didDetectStrike];
        }
    }
}

-(BOOL)start:(NSError**)error
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

-(BOOL)stop:(NSError**)error
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



UInt64 _newTapTime = 0;
UInt64 _oldTapTime = 0;
UInt64 _tapCount = 0;
float IDLE_TIMEOUT = 5.0;

-(void)didDetectStrike
{
    _newTapTime = [PublicUtilityWrapper CAHostTimeBase_GetCurrentTime];
    UInt64 timeElapsedNs = [PublicUtilityWrapper CAHostTimeBase_AbsoluteHostDeltaToNanos:_newTapTime oldTapTime:_oldTapTime];
    Float64 delayFator = 0.1;
    Float64 timeElapsedInSec = Float64(timeElapsedNs) * 10.0e-9 * delayFator;
        
    BOOL isNewTapSeq = (timeElapsedInSec > IDLE_TIMEOUT) ? YES : NO;
        
    if (isNewTapSeq) {
        _tapCount = 0;
        // flash sensitivity
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate soundProcessorDidDetectFirstStrike];
        });
    } else {
        Float64 bpm = 60.0 / timeElapsedInSec;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate soundProcessorDidFindBPM:bpm];
        });
    }
    
    _oldTapTime = _newTapTime;
    _tapCount += 1;
}

-(void) updateStartThreshold
{
    float sensitivity = (float)Settings.sharedInstance.sensitivity;
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
    
    _startThreshold = - (A * sensitivity - B ) / C;
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
