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

// FIXME アプリ外でアカウントが追加/削除された時の反映処理, アカウント更新時は、conManagerの自動再起動
// FIXME FavoritedはPollingでは取得APIがない。Streaming時のみ有効とか、明記しておく。
// FIXME ユーザ名の入力間違い(認証は通った時)、ユーザ名入力が出ない(アプリ認証ボタンに置換される)。キャッシュ削除しても無駄。

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
