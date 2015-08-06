//
//  PublicUtilityWrapper.h
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-07-20.
//

#import <Foundation/Foundation.h>

@interface PublicUtilityWrapper : NSObject


+ (UInt64) CAHostTimeBase_GetCurrentTime;
+ (UInt64) CAHostTimeBase_AbsoluteHostDeltaToNanos:(UInt64) newTapTime oldTapTime:(UInt64) oldTapTime;

@end
