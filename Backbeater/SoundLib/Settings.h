//
//  Settings.h
//  Backbeater
//
//  Created by Alina on 2015-06-11.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (Settings*)sharedInstance;




@property (nonatomic) BOOL mute;
@property (nonatomic, readonly) BOOL sensorIn;
@property (nonatomic) float sensitivity;
@property (nonatomic,readonly) NSInteger strikesWindow;
@property (nonatomic,readonly) NSInteger timeSignature;
@property (nonatomic,readonly) NSInteger metronomeSound;

@property (nonatomic) NSInteger strikesWindowSelectedIndex;
@property (nonatomic) NSInteger timeSignatureSelectedIndex;
@property (nonatomic) NSInteger metronomeSoundSelectedIndex;

@property (nonatomic, readonly) NSArray* strikesWindowValues;
@property (nonatomic, readonly) NSArray* timeSignatureValues;

//@property (nonatomic, readonly) NSInteger bpm;
//@property (nonatomic, readonly) float foundBPM;
//@property (nonatomic, readonly) float foundBPMf;
//@property (nonatomic, readonly) BOOL sensitivityFlash;

-(void)saveState;

@end
