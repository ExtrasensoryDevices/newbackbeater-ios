//
//  Settings.mm
//  Backbeater
//
//  Created by Alina on 2015-06-11.
//



#import "Backbeater-Swift.h"
#import "Settings.h"


@implementation Settings

float DEFAULT_SENSITIVITY = 0.6;

NSArray *_strikesWindowValues;
NSArray *_timeSignatureValues;
NSArray *_metronomeSoundValues;

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
        [self setupKVO];
        [self restoreState];
        _sensorIn = NO;
        _strikesWindowValues = @[@2, @4, @8, @16];
        _timeSignatureValues = @[@1, @2, @3, @4];
        _metronomeSoundValues = @[@1, @2, @3]; //@[@"stick", @"beep", @"clap"];
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



-(void) setupKVO {
    NSArray *properties = @[@"mute", @"sensorIn", @"sensitivity", @"strikesWindowSelectedIndex", @"timeSignatureSelectedIndex", @"metronomeSoundSelectedIndex"];
    for (size_t i = 0; i < properties.count; ++i) {
        NSString *key = (NSString*)properties[i];
        [self addObserver:self forKeyPath:key options:0 context:nil];
    }
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // keep it
    NSLog(@"%@ changed", keyPath);
    id value = [object valueForKey:keyPath];
    NSDictionary *userInfo = @{@"name": keyPath, @"value":value};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SettingsChanged" object:nil userInfo:userInfo];
}




-(NSInteger)strikesWindow
{
    return ((NSNumber*)_strikesWindowValues[_strikesWindowSelectedIndex]).integerValue;
}

-(NSInteger)timeSignature
{
    return ((NSNumber*)_timeSignatureValues[_timeSignatureSelectedIndex]).integerValue;
}


-(NSInteger)metronomeSound
{
    return ((NSNumber*)_metronomeSoundValues[_metronomeSoundSelectedIndex]).integerValue;
}

#pragma mark - Persistence
-(void) restoreState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL changed = NO;
    
    if ([userDefaults objectForKey:@"mute"] != nil) {
        _mute = [userDefaults boolForKey:@"mute"];
    } else {
        changed = YES;
        _mute = false;
    }
    
    
    if ([userDefaults objectForKey:@"sensitivity"] != nil) {
        _sensitivity = [userDefaults floatForKey:@"sensitivity"];
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
    
    
    if (changed) {
        [self saveState];
    }
}

-(void) saveState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:_mute forKey:@"mute"];
    [userDefaults setFloat: _sensitivity forKey:@"sensitivity"];
    [userDefaults setInteger:_strikesWindowSelectedIndex forKey:@"strikesWindowSelectedIndex"];
    [userDefaults setInteger:_timeSignatureSelectedIndex forKey:@"timeSignatureSelectedIndex"];
    [userDefaults setInteger:_metronomeSoundSelectedIndex forKey:@"metronomeSoundSelectedIndex"];
    
    [userDefaults synchronize];
}

@end

    

