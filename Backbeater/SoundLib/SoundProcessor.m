//
//  SoundProcessor.m
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-07-08.
//

#import "SoundProcessor.h"
#import "ATSoundSessionIO.h"
#import "EnergyFunctionQueue.h"
#import "PublicUtilityWrapper.h"
#import <UIKit/UIKit.h>
#import "Backbeater-Swift.h"


//#define kStartThreshold 0.15
//#define kEndThreshold 0.1
#define kTimeout 200000000 // 200 000 000ns = 250ms

@interface SoundProcessor()

@property (nonatomic) BOOL testing;

@end


@implementation SoundProcessor

AudioInput* audioInput;
//ATSoundSessionIO *_soundSessionIO;
EnergyFunctionQueue *_energyFunctionQueue;

Float32 _testMaxEnergy;

Float32 _startThreshold;
Float32 _endThreshold;
Float32 _timeout;

Float64 _idleTimeout;

NSArray *_startThresholdArray;
//= @[@10, @9, @8, @7, @6, @5, @4.5, @4, @3.5, @3, @2.5, @2.4, @2.3, @2.2, @2.1, @2, @1.95, @1.9, @1.85, @1.8, @1.75, @1.7, @1.65, @1.6, @1.55, @1.54, @1.53, @1.52, @1.51, @1.5, @1.475, @1.45, @1.425, @1.4, @1.39, @1.38, @1.37, @1.36, @1.35, @1.34, @1.33, @1.32, @1.31, @1.3, @1.29, @1.28, @1.27, @1.26, @1.25, @1.24, @1.23, @1.22, @1.21, @1.2, @1.19, @1.18, @1.17, @1.16, @1.15, @1.14, @1.12, @1.1, @1.07, @1.03, @1, @0.95, @0.9, @0.83, @0.75, @0.65, @0.55, @0.45, @0.35, @0.25, @0.15, @0.1, @0.09, @0.08, @0.06, @0.02, @0.015, @0.01, @0.0075, @0.005, @0.003, @0.002, @0.0015, @0.001, @0.0009, @0.0008, @0.0007, @0.0006, @0.0005, @0.00045, @0.0004, @0.00035, @0.0003, @0.00025, @0.0002, @0.00015, @0.0001];

int _strikeCount;

BOOL _strikeState;


-(instancetype)initWithIdleTimeout:(Float64) idleTimeout {

    self = [super init];
    if (self != nil) {
        
        _idleTimeout = idleTimeout;
        
        _startThresholdArray = @[@10, @9, @8, @7, @6, @5, @4.5, @4, @3.5, @3, @2.5, @2.4, @2.3, @2.2, @2.1, @2, @1.95, @1.9, @1.85, @1.8, @1.75, @1.7, @1.65, @1.6, @1.55, @1.54, @1.53, @1.52, @1.51, @1.5, @1.475, @1.45, @1.425, @1.4, @1.39, @1.38, @1.37, @1.36, @1.35, @1.34, @1.33, @1.32, @1.31, @1.3, @1.29, @1.28, @1.27, @1.26, @1.25, @1.24, @1.23, @1.22, @1.21, @1.2, @1.19, @1.18, @1.17, @1.16, @1.15, @1.14, @1.12, @1.1, @1.07, @1.03, @1, @0.95, @0.9, @0.83, @0.75, @0.65, @0.55, @0.45, @0.35, @0.25, @0.15, @0.1, @0.09, @0.08, @0.06, @0.02, @0.015, @0.01, @0.0075, @0.005, @0.003, @0.002, @0.0015, @0.001, @0.0009, @0.0008, @0.0007, @0.0006, @0.0005, @0.00045, @0.0004, @0.00035, @0.0003, @0.00025, @0.0002, @0.00015, @0.0001];
        
//        _startThreshold = kStartThreshold;
//        _endThreshold = kEndThreshold;
        _timeout = kTimeout;
        
        [self updateStartThreshold:0];
        
        // init test data
        _testStartThreshold = _startThreshold;
        _testEndThreshold = _endThreshold;
        _testTimeout = _timeout;

        _strikeState = NO;
        
        _energyFunctionQueue = [[EnergyFunctionQueue alloc] init];
        
        __block SoundProcessor *blocksafeSelf = self;
        audioInput = [[AudioInput alloc] initWithAudioInputCallback:^(double timestamp, NSInteger numbers, NSArray<NSNumber *> * samples) {
           [blocksafeSelf processData:samples numFrames:numbers];
        } sampleRate:3000.0 numberOfChannels:1];
        
        [self addObservers];
        
        [self updateInputChannel];
    }
    return self;
}

- (void)dealloc
{
    [self removeObservers];
}


-(BOOL)testing
{
    return _testDelegate != nil;
}


UInt64 _strikeStartTime = 0;
UInt64 _strikeEndTime = 0;
BOOL _insideTimeout = false;
//-(void) processData:(Float32*)left right:(Float32*)right numFrames:(UInt32) numFrames
-(void) processData:(NSArray<NSNumber *>*) data numFrames:(NSInteger) numFrames
{
    int i;
    for (i=0; i<numFrames; i++) {
        
        Float32 __startTh = self.testing ? _testStartThreshold : _startThreshold;
        Float32 __endTh = self.testing ? _testEndThreshold : _endThreshold;
        Float32 __timeout = self.testing ? _testTimeout : _timeout;
        
        Float32 energyLevel = [_energyFunctionQueue push:data[i].floatValue];
        UInt64 newTime = [PublicUtilityWrapper CAHostTimeBase_GetCurrentTime];
        UInt64 timeElapsedNs = [PublicUtilityWrapper CAHostTimeBase_AbsoluteHostDeltaToNanos:newTime oldTapTime:_strikeEndTime];
        
        if (timeElapsedNs > __timeout) {
            // if timeout just ended : report max energy
            if (_insideTimeout) {
                [self testDidDetectTimeoutEnd:_testMaxEnergy];
                _testMaxEnergy = 0;
                _insideTimeout = false;
            }
        } else {
            // still in timeout, update max energy end wait for timeout to end
//            NSLog(@" %.5f - %.5f", energyLevel, _testMaxEnergy);
            _testMaxEnergy = MAX(energyLevel, _testMaxEnergy);
            return;
        }
        
        
        // timeout ended, handle energy level
        if (_strikeState == NO && energyLevel >= __startTh) {
            _strikeState = YES;
            _strikeStartTime = newTime;
            
            _insideTimeout = true;
            
            _testMaxEnergy = energyLevel;
//            NSLog(@" started: %.5f - %.5f", energyLevel, _testMaxEnergy);
            if (self.testing) {
                [self testDidDetectStrikeStart: energyLevel];
            }
        } else if (_strikeState == YES && energyLevel <= __endTh) {
            _strikeState = NO;
            
            _strikeEndTime = [PublicUtilityWrapper CAHostTimeBase_GetCurrentTime];
            
            if (self.testing) {
                [self testDidDetectStrikeEnd:energyLevel];
            }
            [self didDetectStrike];
        }
    }
}

-(BOOL)start:(NSInteger) sensivity error: (NSError**)error
{
    [self updateStartThreshold:sensivity];
    _strikeState = NO;
    _strikeCount = 0;
    [_energyFunctionQueue clear];
    
//    [_soundSessionIO prepareSoundProcessingGraph:nil];
//    [_soundSessionIO startSoundProcessing:error];
    [audioInput startRecording];
    
    return error == nil;
}

-(BOOL)stop:(NSError**)error
{
//    if (_soundSessionIO.isProcessingSound) {
//        [_soundSessionIO stopSoundProcessing:error];
//    }
    [audioInput stopRecording];
    
    _strikeState = NO;
    _strikeCount = 0;
    [_energyFunctionQueue clear];
    return error == nil;
}


-(void)setSensivity:(NSInteger) sensivity {
    [self updateStartThreshold:sensivity];
}


#pragma mark - Properties

-(void)setSensorPluggedIn:(BOOL) sensorIn {
    if (_sensorIn != sensorIn) {
        _sensorIn = sensorIn;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate soundProcessorDidDetectSensorIn: self.sensorIn];
        });
    }
}



UInt64 _newTapTime = 0;
UInt64 _oldTapTime = 0;
UInt64 _tapCount = 0;

-(void)didDetectStrike
{
    _newTapTime = [PublicUtilityWrapper CAHostTimeBase_GetCurrentTime];
    UInt64 timeElapsedNs = [PublicUtilityWrapper CAHostTimeBase_AbsoluteHostDeltaToNanos:_newTapTime oldTapTime:_oldTapTime];
    Float64 delayFator = 0.1;
    Float64 timeElapsedInSec = ((Float64)timeElapsedNs) * 10.0e-9 * delayFator;
        
    BOOL isNewTapSeq = (timeElapsedInSec > _idleTimeout) ? YES : NO;
        
    if (isNewTapSeq) {
        _tapCount = 0;
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

-(void) updateStartThreshold:(NSInteger) sensitivity
{
    _startThreshold = ((NSNumber*)_startThresholdArray[sensitivity]).floatValue;
    _endThreshold = 1.1 * _startThreshold;
}



#pragma mark - Testing

-(void)testDidDetectStrikeStart:(Float32) startEnergy
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.testDelegate soundProcessorDidDetectStrikeStart:startEnergy];
    });
}


-(void)testDidDetectStrikeEnd:(Float32) endEnergy
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.testDelegate soundProcessorDidDetectStrikeEnd:endEnergy];
    });
}

-(void)testDidDetectTimeoutEnd:(Float32) maxEnergy
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.testDelegate soundProcessorDidDetectTimeoutEnd:maxEnergy];
    });
}


#pragma mark - Notifications



-(void)addObservers
{
    // Register for Route Change notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleRouteChange:)
                                                 name: AVAudioSessionRouteChangeNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleInterruption:)
                                                 name: AVAudioSessionInterruptionNotification
                                               object: nil];

}

-(void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: AVAudioSessionRouteChangeNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: AVAudioSessionInterruptionNotification object:nil];
}

-(void)handleInterruption:(NSNotification*)notification{
    NSInteger reason = 0;
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        //Posted when an audio interruption occurs.
        reason = [[[notification userInfo] objectForKey: AVAudioSessionInterruptionTypeKey] integerValue];
        switch (reason) {
        case AVAudioSessionInterruptionTypeBegan:
            // Audio has stopped, already inactive, change state of UI, etc., to reflect non-playing state
            [self stop:nil];
        case AVAudioSessionInterruptionTypeEnded:
            // Make session active, update user interface
//            [_soundSessionIO prepareSoundProcessingGraph:nil];
                break;
        }
    };
}

-(void)handleRouteChange:(NSNotification*)notification{
    [self updateInputChannel];
}


-(void) updateInputChannel
{
    @synchronized(self) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSArray<AVAudioSessionPortDescription*> *inputs = session.currentRoute.inputs;
        AVAudioSessionPortDescription *input = inputs.count > 0 ? inputs[0] : nil;
        
        if ([input.portType isEqualToString: AVAudioSessionPortHeadsetMic] ||
            [input.portType isEqualToString: AVAudioSessionPortUSBAudio]) {
            // sensor plugged in
            [self setSensorPluggedIn:true];
        } else {
            // sensor unplugged
            [self setSensorPluggedIn:false];
        }
    }
}

@end
