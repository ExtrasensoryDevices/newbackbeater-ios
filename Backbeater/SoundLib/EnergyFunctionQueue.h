//
//  EnergyFunctionQueue.h
//  Backbeater
//
//  Created by Alina on 2015-07-08.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnergyFunctionQueue : NSObject


-(Float32) push:(Float32)value;
-(void)clear;

@end
