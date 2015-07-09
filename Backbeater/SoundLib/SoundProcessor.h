//
//  SoundProcessor.h
//  Backbeater
//
//  Created by Alina on 2015-07-08.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundProcessor : NSObject

+(instancetype) sharedInstance;

-(BOOL)startSoundProcessing:(NSError**)error;
-(BOOL)stopSoundProcessing:(NSError**)error;

@end
