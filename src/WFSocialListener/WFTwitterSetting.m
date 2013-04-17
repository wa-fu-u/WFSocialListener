//
//  WFSocialListenerSetting.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/29.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFTwitterSetting.h"

@implementation WFTwitterSetting
- (id)initWithAccount:(ACAccount *)account {
    return [super init];
}
- (void)setWatchFlag:(WFTwitterEventType)eventType value:(BOOL)value {}
- (void)requestDMToken:(UIWebView *)webView key:(NSString *)key secret:(NSString *)secret callbackURI:(NSString *)callbackURI handler:(WFTwitterSettingHandler)handler {}
- (BOOL)readWatchFlag:(WFTwitterEventType)eventType {return  NO;}
- (void)requestUserStatus:(WFTwitterSettingHandler)handler {}
@end
