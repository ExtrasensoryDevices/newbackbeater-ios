//
//  Settings.h
//  Backbeater
//
//  Created by Alina on 2015-06-11.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (Settings*)sharedInstance;



// current state / user input
@property (nonatomic, readonly) BOOL sensorIn; // value received from SoundProcessor
@property (nonatomic) float sensitivity;
@property (nonatomic,readonly) NSInteger strikesWindow; // value set by index in array
@property (nonatomic,readonly) NSInteger timeSignature; // value set by index in array
@property (nonatomic) BOOL metronomeIsOn;
@property (nonatomic) NSInteger metronomeTempo;
@property (nonatomic,readonly) NSInteger metronomeSound; // value set by index in array

// possible values
@property (nonatomic, readonly) NSArray* strikesWindowValues;
@property (nonatomic, readonly) NSArray* timeSignatureValues;
// TODO: move sound array here too

// selected indices
@property (nonatomic) NSInteger strikesWindowSelectedIndex;
@property (nonatomic) NSInteger timeSignatureSelectedIndex;
@property (nonatomic) NSInteger metronomeSoundSelectedIndex;






//@property (nonatomic, readonly) NSInteger bpm;
//@property (nonatomic, readonly) float foundBPM;
//@property (nonatomic, readonly) float foundBPMf;
//@property (nonatomic, readonly) BOOL sensitivityFlash;

-(void)saveState;

@end
