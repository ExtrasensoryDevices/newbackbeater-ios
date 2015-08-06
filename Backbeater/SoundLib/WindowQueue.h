//
//  EnergyFunctionQueue.h
//  Backbeater
//
//  Created by Alina on 2015-07-08.
//

#import <Foundation/Foundation.h>

@interface WindowQueue : NSObject

@property (nonatomic, readonly) NSInteger average;
@property (atomic) NSInteger capacity;


-(instancetype)initWithCapacity:(NSInteger)capacity;

-(instancetype)enqueue:(NSInteger)value;

-(void)clear;

@end
