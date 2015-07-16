//
//  EnergyFunctionQueue.h
//  Backbeater
//
//  Created by Alina on 2015-07-08.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnergyFunctionQueue : NSObject


-(void) push:(Float32)value resultHandler:(void (^)(BOOL success, Float32 value))resultHandler;
-(void)clear;

@end
