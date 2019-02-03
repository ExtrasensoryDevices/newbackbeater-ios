//
//  EnergyFunctionQueue.h
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-07-08.
//

#import <Foundation/Foundation.h>

@interface WindowQueue : NSObject

@property (nonatomic, readonly) NSInteger average;
@property (atomic) NSInteger capacity;


-(instancetype)initWithCapacity:(NSInteger)capacity;

-(instancetype)enqueue:(Float64)value;

-(void)clear;

@end
