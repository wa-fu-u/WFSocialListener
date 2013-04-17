//
//  WFtwitterConnection.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/11.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFTwitterSettingInternal.h"
#import "WFTwitterObserverManager.h"

@interface WFTwitterFetchObserver : NSObject
- (id)initWithDelegate:(NSObject<WFTwitterObserverDelegate> *)delegate setting:(WFTwitterSettingInternal *)setting;
- (void)fetch;
@end
