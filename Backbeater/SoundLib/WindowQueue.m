//
//  EnergyFunctionQueue.m
//  Backbeater
//
//  Created by Alina on 2015-07-08.
//

#import "WindowQueue.h"


@implementation WindowQueue

NSInteger _capacity;
NSMutableArray* _array;
long _sum;


-(instancetype)initWithCapacity:(NSInteger)capacity
{
    self = [super init];
    if (self) {
        _capacity = capacity;
        _array = [[NSMutableArray alloc] init];
    }
    return self;
}


-(NSInteger)capacity
{
    return _capacity;
}

-(void)setCapacity:(NSInteger)capacity
{
    [self clear];
    _capacity = capacity;
}



- (void)clear
{
    _sum =0;
    [_array removeAllObjects];
}

-(instancetype) enqueue:(NSInteger)value {
    
    NSNumber *fadingObject = nil;
    if (_array.count == _capacity){
        fadingObject = [_array objectAtIndex:0];
        [_array removeObjectAtIndex:0];
    }
    [_array addObject:[NSNumber numberWithInteger:value]];
    [self updateAverageObjectRemoved:fadingObject.integerValue objectAdded:value];
    return self;
}

-(void) updateAverageObjectRemoved:(NSInteger)valueRemoved objectAdded:(NSInteger)valueAdded{
    if (_array.count == 0){
        _sum = 0;
        return;
    }
    _sum -= valueRemoved;
    _sum += valueAdded;
    
}

-(NSInteger) average {
    if (_array.count == 0){
        return 0;
    }
    return _sum / _array.count;
    
}
@end
