//
//  TwitterStreamingConnector.h
//  WFSocialListener
//
//  Created by akihiro uehara on 2013/03/07.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFConnector.h"

@class WFTwitterStreamConnector;
@protocol WFTwitterStreamDelegate <NSObject>
- (void)didReceivedJSONData:(WFTwitterStreamConnector *)sender jsonData:(id)jsonData;
- (void)didReceivedErrorHttpResponse:(WFTwitterStreamConnector *)sender httpResponse:(NSHTTPURLResponse *)res;
- (void)didStreamDisconnected:(WFTwitterStreamConnector *)sender error:(NSError *)error;
@end

@interface WFTwitterStreamConnector : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
- (id)initWithDelegate:(NSObject<WFTwitterStreamDelegate> *)delegate account:(WFAccount *)a endpoint:(NSString *)e parameters:(NSDictionary *)p;
- (void)start;
- (void)cancel;
@end
