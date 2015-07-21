//
//  PublicUtilityWrapper.m
//  Backbeater
//
//  Created by Alina Kholcheva on 2015-07-20.
//  Copyright (c) 2015 Samsung Accelerator. All rights reserved.
//

#import "PublicUtilityWrapper.h"
#import "CAHostTimeBase.h"

@implementation PublicUtilityWrapper


+(UInt64) CAHostTimeBase_GetCurrentTime
{
    return CAHostTimeBase::GetCurrentTime();
}


+(UInt64) CAHostTimeBase_AbsoluteHostDeltaToNanos:(UInt64) newTapTime oldTapTime:(UInt64) oldTapTime
{
    return CAHostTimeBase::AbsoluteHostDeltaToNanos(newTapTime, oldTapTime);
}
@end
