//
//  WFTwitterNetManager.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/30.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFSocialListenerTypes.h"
#import "WFAccount.h"
#import "WFReachability.h"

@protocol WFTwitterObserverDelegate <NSObject>
- (void)didTwitterUpdated:(id)sender account:(WFAccount *)account eventType:(WFTwitterEventType)event jsonData:(id)json;
@end

// WFTwitterObserverをまとめます
@interface WFTwitterObserverManager : NSObject
@property (nonatomic, readonly) NetworkStatus networkStatus;
@property (nonatomic, readonly) BOOL isStreaming;

- (id)initWithDelegate:(NSObject<WFTwitterObserverDelegate> *)delegate settings:(NSArray *)settings;

- (void)fetch;
- (void)start;
- (void)cancel;
@end
