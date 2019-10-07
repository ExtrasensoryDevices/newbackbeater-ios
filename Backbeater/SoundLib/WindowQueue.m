//
//  EnergyFunctionQueue.m
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-07-08.
//

#import "WindowQueue.h"


@implementation WindowQueue

NSInteger _capacity;
NSMutableArray* _array;
Float64 _sum;


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
    if (_capacity == 2) {
        _capacity = 1;
    }
}



- (void)clear
{
    _sum =0;
    [_array removeAllObjects];
}

-(instancetype) enqueue:(Float64)value {
    
    NSNumber *fadingObject = nil;
    if (_array.count == _capacity){
        fadingObject = [_array objectAtIndex:0];
        [_array removeObjectAtIndex:0];
    }
    [_array addObject:[NSNumber numberWithFloat:value]];
    [self updateAverageObjectRemoved:fadingObject.floatValue objectAdded:value];
    return self;
}

-(void) updateAverageObjectRemoved:(Float64)valueRemoved objectAdded:(Float64)valueAdded{
    if (_array.count == 0) {
        _sum = 0;
        return;
    }
    _sum -= valueRemoved;
    _sum += valueAdded;
    
}

-(NSInteger) average {
    if (_array.count == 0) {
        return 0;
    }
    return (NSInteger)(_sum / (double)_array.count);
    
}
@end
