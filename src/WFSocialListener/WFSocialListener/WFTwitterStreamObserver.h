//
//  WFTwitterStreamObserver.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/15.
//  Copyright (c) 2013年 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFTwitterSettingInternal.h"
#import "WFTwitterObserverManager.h"
#import "WFTwitterStreamConnector.h"

@interface WFTwitterStreamObserver : NSObject<WFTwitterStreamDelegate>
- (id)initWithDelegate:(NSObject<WFTwitterObserverDelegate> *)delegate setting:(WFTwitterSettingInternal *)setting queue:(dispatch_queue_t)queue;
-(void)start;
-(void)cancel;
@end
