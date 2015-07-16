//
//  EnergyFunctionQueue.m
//  Backbeater
//
//  Created by Alina on 2015-07-08.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

#import "EnergyFunctionQueue.h"

#define kNumValues 4
#define kEmpty -1


@implementation EnergyFunctionQueue



Float32 buffer[kNumValues];
int count = kEmpty;



-(instancetype)init
{
    self = [super init];
    if (self) {
        [self clear];
    }
    return self;
}



- (void)clear
{
    count = kEmpty;
    for (int i=0; i<kNumValues; i++) {
        buffer[i] = 0;
    }
}


-(void) push:(Float32)value resultHandler:(void (^)(BOOL success, Float32 value))resultHandler
{
    count++;
    Float32 square = value*value;
    buffer[count % kNumValues] = square;
    if (count < kNumValues) {
        resultHandler(NO, 0);
    } else {
        Float32 energy = 0;
        for (int i=0; i<kNumValues; i++) {
            energy += buffer[i];
        }
        resultHandler(YES, energy);
    }
}

@end
