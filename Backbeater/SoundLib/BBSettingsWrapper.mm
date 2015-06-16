//
//  BBSettingsWrapper.m
//  Backbeater
//
//  Created by Alina on 2015-06-11.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

#import "BBSettingsWrapper.h"
#import "BBSetting.h"
#import "AUtype1.h"
#import "AUtype1Delegate.h"


@interface BBSettingsWrapper()

    @property (readwrite, nonatomic) BBSetting *settings;
    @property (readwrite, nonatomic) AUtype1 *rioUnit;
    @property (readwrite, nonatomic) AUtype1Delegate *rioUnitDelegate;

@end

@implementation BBSettingsWrapper




+ (BBSettingsWrapper*)sharedInstance {
    static BBSettingsWrapper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}



- (instancetype)init
{
    self = [super init];
    if (self) {
        _settings = [BBSetting sharedInstance];
        [self setupKVO];
    }
    return self;
}

-(void) setupKVO
{
    [_settings addObserver:self forKeyPath:@"sensitivity" options:0 context:nil];
    [_settings addObserver:self forKeyPath:@"bpm" options:0 context:nil];
    [_settings addObserver:self forKeyPath:@"mute" options:0 context:nil];
    [_settings addObserver:self forKeyPath:@"sensorIn" options:0 context:nil];
    [_settings addObserver:self forKeyPath:@"foundBPMf" options:0 context:nil];
    [_settings addObserver:self forKeyPath:@"sensitivityFlash" options:0 context:nil];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@ changed", keyPath);
    
    id value = [object valueForKey:keyPath];
    if ([value isKindOfClass: NSObject.class]) {
        
    }
    NSDictionary *userInfo = @{@"name": keyPath, @"value":value};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SettingsChanged" object:nil userInfo:userInfo];
}



-(void) setMetSound:(NSInteger)metSound {
    _settings.metSound = metSound;
}
-(NSInteger) metSound {
    return _settings.metSound;
}

-(void) setMute:(BOOL)mute {
    _settings.mute = mute;
}
-(BOOL) mute {
    return _settings.mute;
}


-(BOOL) sensorIn {
    return _settings.sensorIn;
}

-(NSInteger) bpm {
    return _settings.bpm;
}


-(void) setSensitivity:(float)sensitivity {
    _settings.sensitivity = sensitivity;
}
-(float) sensitivity {
    return _settings.sensitivity;
}

-(void) setStrikesFilter:(NSInteger)strikesFilter {
    _strikesFilter = strikesFilter;
    NSDictionary *userInfo = @{@"name": @"strikesFilter", @"value":[NSNumber numberWithInteger:strikesFilter]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SettingsChanged" object:nil userInfo:userInfo];
}

-(void) setTimeSignature:(NSInteger)timeSignature {
    _timeSignature = timeSignature;
    NSDictionary *userInfo = @{@"name": @"timeSignature", @"value":[NSNumber numberWithInteger:timeSignature]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SettingsChanged" object:nil userInfo:userInfo];
}

-(float) foundBPM {
    return _settings.foundBPM;
}

-(float) foundBPMf {
    return _settings.foundBPMf;
}

-(BOOL) sensitivityFlash {
    return _settings.sensitivityFlash;
}




@end
