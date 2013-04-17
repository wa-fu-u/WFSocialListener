//
//  WFSocialListenerSetting.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/29.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import "WFSocialListenerTypes.h"

typedef void(^WFTwitterSettingHandler)(BOOL succeeded, NSError *error);

//ユーザアカウントごとのListener設定
@interface WFTwitterSetting : NSObject
// account details
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *screen_name;
@property (nonatomic, readonly) NSString *profile_image_url;
@property (nonatomic, readonly) BOOL canAccessDirectMessage;
// watching settings
@property (nonatomic, readonly) BOOL watchNewTweet;
@property (nonatomic, readonly) BOOL watchMention;
@property (nonatomic, readonly) BOOL watchRetweet;
@property (nonatomic, readonly) BOOL watchFavorited;
@property (nonatomic, readonly) BOOL watchNewFollower;
@property (nonatomic, readonly) BOOL watchDirectMessage;

- (id)initWithAccount:(ACAccount *)account;
// モニタ状態を設定します。DMをモニタするときは、ユーザの認証が必要な場合があります。そのときにdelegateが必要になります。初めてDMをONにする時以外は、nilでかまいません。
- (void)setWatchFlag:(WFTwitterEventType)eventType value:(BOOL)value;
// DMトークンを取得します。すでにトークンがある場合は、直ちに取得完了のハンドラが呼ばれます。
- (void)requestDMToken:(UIWebView *)webView key:(NSString *)key secret:(NSString *)secret callbackURI:(NSString *)callbackURI handler:(WFTwitterSettingHandler)handler;
// 特定のイベントタイプのWatchフラグを返します
- (BOOL)readWatchFlag:(WFTwitterEventType)eventType;
- (void)requestUserStatus:(WFTwitterSettingHandler)handler;
@end
