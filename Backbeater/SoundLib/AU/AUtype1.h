//
//  AUtype1.h
//  BB
//
//  Created by Sung Yoon on 12-02-23.
//  Copyright (c) 2012 Bamsom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAStreamBasicDescription.h"

@protocol AUT1;

@interface AUtype1 : NSObject {
    id <AUT1> delegate;
}

@property (nonatomic, assign) id <AUT1> delegate;
@property (nonatomic, assign)	BOOL	mute;

- (void)setup;

@end

@protocol AUT1

- (void)detectTempo:(AudioBufferList *)data 
             ofSize:(UInt32)inNumFrames 
               with:(Float64)SampleRate 
          stampedAt:(AudioTimeStamp *)timeStamp ;

- (void)fillBuffer:(AudioBufferList *)data ofSize:(UInt32)inNumFrames with:(Float64)SampleRate;

@end