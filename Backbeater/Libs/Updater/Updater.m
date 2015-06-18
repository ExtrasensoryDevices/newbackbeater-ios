//
//  Updater.m
//
//  Created by Alina on 10/16/14.
//

#import "Updater.h"
#import "AFHTTPRequestOperation.h"

@interface Updater ()

@property (copy, nonatomic) NSString *plistUrl;

- (void)askUserToUpdate;

@end

@implementation Updater

- (id)initWithPlistUrl:(NSString *)plistUrl {
    if (self = [super init]){
        self.plistUrl = plistUrl;
    }
    
    return self;
}

- (void)checkForUpdate {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.plistUrl]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:15];
    
    AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
    policy.allowInvalidCertificates = YES;
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.securityPolicy = policy;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *plist = [operation.responseString propertyList];
        
        if (!plist) return;
        
        NSArray *items = [plist objectForKey:@"items"];
        
        if (!items) return;
        
        for (NSDictionary *dict in items){
            NSDictionary *metadata = [dict objectForKey:@"metadata"];
            NSString *buildNumber = [metadata objectForKey:@"bundle-build-number"];
            
            if ([buildNumber length] > 0){
                NSString *currentBuildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
                
                if ([currentBuildNumber caseInsensitiveCompare:buildNumber] != NSOrderedSame){
                    [self askUserToUpdate];
                }
                
                break;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"update failed")
        ;
    }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)askUserToUpdate {
    [[[UIAlertView alloc] initWithTitle:@"Update Available"
                                message:@""
                               delegate:self
                      cancelButtonTitle:@"Not now"
                      otherButtonTitles:@"Update", nil] show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex > 0){
        NSString *url = [@"itms-services://?action=download-manifest&url=" stringByAppendingString:self.plistUrl];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

@end
