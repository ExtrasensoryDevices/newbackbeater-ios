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
@property (nonatomic, readonly) NSInteger bpm;
@property (nonatomic) float sensitivity;
@property (nonatomic) NSInteger strikesFilter;
@property (nonatomic) NSInteger timeSignature;
@property (nonatomic) NSInteger metSound;

@property (nonatomic, readonly) float foundBPM;
@property (nonatomic, readonly) float foundBPMf;
@property (nonatomic, readonly) BOOL sensitivityFlash;



@end
