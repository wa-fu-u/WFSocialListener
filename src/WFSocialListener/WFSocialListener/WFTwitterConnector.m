//
//  WFTwitterConnector.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/09.
//  Copyright (c) 2013年 Akihiro Uehara. All rights reserved.
//

#import "WFTwitterConnector.h"
@interface WFTwitterConnector () {
}
@end

@implementation WFTwitterConnector
#pragma mark - Private methods
- (NSString *)getIdStr:(id)jsonData {
    NSString *msgid = nil;
    if ([jsonData isKindOfClass:[NSArray class]] && [jsonData count] > 0) {
        id inst = [jsonData objectAtIndex:0];
        if ([inst isKindOfClass:[NSDictionary class]]) {
            msgid = inst[@"id_str"];
        }
    }
    return msgid;
}
#pragma mark - Public methods
- (void)fetchSincePrevious:(WFConnectorHandler)handler {
    __weak WFTwitterConnector *weak_self = self;
    
    NSMutableDictionary *p = [[NSMutableDictionary alloc] init];
    if (self.sinceID != nil) {
        p[@"since_id"] = self.sinceID;
    }
    // fetch
    [super fetch:p handler:^(id jsonData, NSHTTPURLResponse *urlResponse, NSError *error) {
// DLog(@"%s sender:%@ statusCode:%d jsonData:%@ NSError:%@ sinceID:%@",__func__, sender, statusCode, jsonData, error, self.sinceID);
// DLog(@"%s urlResponse:%@ NSError:%@ sinceID:%@",__func__,urlResponse, error, weak_self.sinceID);
        NSString *next_since_id = [weak_self getIdStr:jsonData];
        if (weak_self.sinceID != nil && next_since_id != nil) {
            handler(jsonData, urlResponse, error);
        }
        if (next_since_id != nil) {
            weak_self.sinceID = next_since_id;
        }
    }];
}
@end
