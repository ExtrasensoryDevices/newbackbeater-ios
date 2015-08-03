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
@property (nonatomic) BOOL sensorIn; 
@property (nonatomic) NSInteger sensitivity;
@property (nonatomic,readonly) NSInteger strikesWindow; // value set by index in array
@property (nonatomic,readonly) NSInteger timeSignature; // value set by index in array
@property (nonatomic) BOOL metronomeIsOn;
@property (nonatomic) NSInteger metronomeTempo;
@property (nonatomic, readonly) NSURL *urlForSound; // url for the selected sound

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
