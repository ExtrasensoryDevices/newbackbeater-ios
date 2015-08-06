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
        _metronomeSoundFileNames = @[@"sideStick", @"stick", @"metronome", @"surprise"];
    }
    return self;
}




// setters
-(void)setMetronomeTempo:(NSInteger)value
{
    NSInteger MAX_TEMPO = [BridgeConstants MAX_TEMPO];
    NSInteger MIN_TEMPO = [BridgeConstants MIN_TEMPO];
    NSInteger boundedValue = value >  MAX_TEMPO ? MAX_TEMPO : (value < MIN_TEMPO ? MIN_TEMPO : value);
    if (_metronomeTempo != boundedValue) {
        _metronomeTempo = boundedValue;
        [Flurry logEvent:[FlurryEvent METRONOME_TEMPO_VALUE_CHANGED]
          withParameters:@{@"value": [NSNumber numberWithInteger:_metronomeTempo]}];
    }
}


-(void)setMetronomeIsOn:(BOOL)value
{
    if (_metronomeIsOn != value) {
        _metronomeIsOn = value;
        [Flurry logEvent:[FlurryEvent METRONOME_STATE_CHANGED]
          withParameters:@{@"value": [NSNumber numberWithBool:_metronomeIsOn]}];
    }
}


-(void)setSensitivity:(NSInteger)value
{
    if (_sensitivity != value) {
        _sensitivity = value;
        [Flurry logEvent:[FlurryEvent SENSITIVITY_VALUE_CHANGED]
          withParameters:@{@"value": [NSNumber numberWithInteger:_sensitivity]}];
    }
}


-(void)setStrikesWindowSelectedIndex:(NSInteger)value
{
    if (_strikesWindowSelectedIndex != value) {
        _strikesWindowSelectedIndex = value;
        [Flurry logEvent:[FlurryEvent STRIKES_WINDOW_VALUE_CHANGED]
          withParameters:@{@"value": [NSNumber numberWithInteger:self.strikesWindow]}];
    }
}


-(void)setTimeSignatureSelectedIndex:(NSInteger)value
{
    if (_timeSignatureSelectedIndex != value) {
        _timeSignatureSelectedIndex = value;
        [Flurry logEvent:[FlurryEvent TIME_SIGNATURE_VALUE_CHANGED]
          withParameters:@{@"value": [NSNumber numberWithInteger:self.timeSignature]}];
    }
}



// getters

-(NSArray *)strikesWindowValues
{
    return [_strikesWindowValues copy];
}


-(NSArray *)timeSignatureValues
{
    return [_timeSignatureValues copy];
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
        _sensitivity = [BridgeConstants DEFAULT_SENSITIVITY];
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
        _metronomeTempo = [BridgeConstants DEFAULT_TEMPO];
    }
    
    if ([userDefaults objectForKey:@"songList"] != nil) {
        _songList = [userDefaults objectForKey:@"songList"];
    } else {
        _songList = nil;
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
    [userDefaults setObject:_songList forKey:@"songList"];
    
    [userDefaults synchronize];
}

@end

    

