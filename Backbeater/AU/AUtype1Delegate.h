//
//  AUtype1Delegate.h
//  BB
//
//  Created by SUNG YOON on 12-03-14.
//  Copyright (c) 2012 Bamsom. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>
#import "AUtype1.h"

@interface AUtype1Delegate : NSObject <AUT1> {
}

- (void)setupWithMaxSensitivity:(Float32)max andMinSensitivity:(Float32)min ;


@end
