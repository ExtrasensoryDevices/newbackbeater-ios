//
//  EnergyFunctionQueue.m
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-07-08.
//

#import "EnergyFunctionQueue.h"

#define kNumValues 4
#define kEmpty -1


@implementation EnergyFunctionQueue



Float32 buffer[kNumValues];
int _index = kEmpty;



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
    _index = kEmpty;
    for (int i=0; i<kNumValues; i++) {
        buffer[i] = 0;
    }
}


-(Float32) push:(Float32)value
{
    
    _index = (_index+1) % kNumValues;
    Float32 square = value*value;
    buffer[_index] = square;
    Float32 energy = 0;
    for (int i=0; i<kNumValues; i++) {
        energy += buffer[i];
    }
    return energy;
}

@end
