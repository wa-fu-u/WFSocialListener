//
//  WFSocialListener.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/11.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFSocialListenerTypes.h"
#import "WFTwitterSetting.h"
#import "WFSocialListener/WFReachability.h"
#import "WFSocialListener/WFTwitterObserverManager.h"

@class WFSocialListener;
@protocol WFSocialListenerDelegate <NSObject>
- (void)didTwitterUpdated:(WFSocialListener *)sender account:(ACAccount *)account eventType:(WFTwitterEventType)eventType json:(id)json;
@optional
- (void)didReadAccounts:(WFSocialListener *)sender accountTypeIdentifier:(NSString *)identifier;
@end

@interface WFSocialListener : NSObject<WFTwitterObserverDelegate>
@property (nonatomic, readonly) NetworkStatus networkStatus;
@property (nonatomic, readonly) BOOL isStreaming;

@property (nonatomic, readonly) NSArray *twitterSettings;

- (id)initWithDelegate:(NSObject<WFSocialListenerDelegate> *)delegate;

- (void)importSettings:(NSDictionary *)settings;
- (NSDictionary *)exportSettings;

- (void)start;
- (void)cancel;
@end
