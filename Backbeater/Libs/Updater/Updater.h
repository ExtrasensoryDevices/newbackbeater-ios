//
//  Updater.h
//
//  Created by Alina on 10/16/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Updater : NSObject<UIAlertViewDelegate>

- (id)initWithPlistUrl:(NSString *)plistUrl;
- (void)checkForUpdate;

@end
