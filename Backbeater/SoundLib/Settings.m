//
//  Settings.mm
//  Backbeater
//
//  Created by Alina on 2015-06-11.
//



#import "Backbeater-Swift.h"
#import "Settings.h"


@implementation Settings

NSArray *_strikesWindowValues;
NSArray *_timeSignatureValues;
NSArray *_metronomeSoundFileNames;

//TODO: import from swift
float DEFAULT_SENSITIVITY = 100;
int DEFAULT_TEMPO = 120;
int MAX_TEMPO = 221;
int MIN_TEMPO = 20;

+ (Settings*)sharedInstance {
    static Settings *_instance = nil;
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
        [self restoreState];
        _sensorIn = NO;
        _strikesWindowValues = @[@2, @4, @8, @16];
        _timeSignatureValues = @[@1, @2, @3, @4];
        _metronomeSoundFileNames = @[@"stick", @"metronome", @"sideStick"];
    }
    return self;
}



-(NSArray *)strikesWindowValues
{
    return [_strikesWindowValues copy];
}


-(NSArray *)timeSignatureValues
{
    return [_timeSignatureValues copy];
}


-(void)setMetronomeTempo:(NSInteger)value
{
    NSInteger boundedValue = value >  MAX_TEMPO ? MAX_TEMPO : (value < MIN_TEMPO ? MIN_TEMPO : value);
    if (_metronomeTempo != boundedValue) {
        _metronomeTempo = boundedValue;
    }
}



-(NSInteger)strikesWindow
{
    return ((NSNumber*)_strikesWindowValues[_strikesWindowSelectedIndex]).integerValue;
}

-(NSInteger)timeSignature
{
    return ((NSNumber*)_timeSignatureValues[_timeSignatureSelectedIndex]).integerValue;
}


-(NSURL*)urlForSound
{
    return [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:_metronomeSoundFileNames[_metronomeSoundSelectedIndex] ofType:@"wav"]];
}

#pragma mark - Persistence
-(void) restoreState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL changed = NO;
    
    if ([userDefaults objectForKey:@"sensitivity"] != nil) {
        _sensitivity = [userDefaults integerForKey:@"sensitivity"];
    } else {
        changed = YES;
        _sensitivity = DEFAULT_SENSITIVITY;
    }
    
    if ([userDefaults objectForKey:@"strikesWindowSelectedIndex"] != nil) {
        _strikesWindowSelectedIndex = [userDefaults integerForKey:@"strikesWindowSelectedIndex"];
    } else {
        changed = YES;
        _strikesWindowSelectedIndex = 1;
    }
    
    
    if ([userDefaults objectForKey:@"timeSignatureSelectedIndex"] != nil) {
        _timeSignatureSelectedIndex = [userDefaults integerForKey:@"timeSignatureSelectedIndex"];
    } else {
        changed = YES;
        _timeSignatureSelectedIndex = 0;
    }
    
    
    if ([userDefaults objectForKey:@"metronomeSoundSelectedIndex"] != nil) {
        _metronomeSoundSelectedIndex = [userDefaults integerForKey:@"metronomeSoundSelectedIndex"];
    } else {
        changed = YES;
        _metronomeSoundSelectedIndex = 0;
    }
    
    if ([userDefaults objectForKey:@"metronomeIsOn"] != nil) {
        _metronomeIsOn = [userDefaults boolForKey:@"metronomeIsOn"];
    } else {
        changed = YES;
        _metronomeIsOn = false;
    }
    
    
    if ([userDefaults objectForKey:@"metronomeTempo"] != nil) {
        _metronomeTempo = [userDefaults integerForKey:@"metronomeTempo"];
    } else {
        changed = YES;
        _metronomeTempo = DEFAULT_TEMPO;
    }
 
    if (changed) {
        [self saveState];
    }
}

-(void) saveState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger: _sensitivity forKey:@"sensitivity"];
    [userDefaults setInteger:_strikesWindowSelectedIndex forKey:@"strikesWindowSelectedIndex"];
    [userDefaults setInteger:_timeSignatureSelectedIndex forKey:@"timeSignatureSelectedIndex"];
    [userDefaults setInteger:_metronomeSoundSelectedIndex forKey:@"metronomeSoundSelectedIndex"];
    [userDefaults setBool:_metronomeIsOn forKey:@"metronomeIsOn"];
    [userDefaults setInteger:_metronomeTempo forKey:@"metronomeTempo"];
    
    [userDefaults synchronize];
}

@end

    

