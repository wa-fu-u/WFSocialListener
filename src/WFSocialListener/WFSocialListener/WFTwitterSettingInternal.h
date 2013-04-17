//
//  WFTwitterSettingInternal.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/30.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFTwitterSetting.h"
#import "WFAccount.h"
#import "WFOAuthConnection.h"

@interface WFTwitterSettingInternal : WFTwitterSetting
@property (nonatomic, readonly) WFAccount *account;

- (void)importSettings:(NSDictionary *)settings;
- (NSDictionary *)exportSettings;
@end
