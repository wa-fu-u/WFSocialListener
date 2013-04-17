//
//  WFSocialListenerSettingInternal.m
//  WFSocialListenerInternal
//
//  Created by Akihiro Uehara on 2013/04/29.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFTwitterSettingInternal.h"
#import "WFTwitterTokenRequest.h"
#import "WFTwitterVerifyCredential.h"
#import "WFTwitterAccountVerifyCredentials.h"
#import "WFError.h"

#define kWatchNewTweetKey @"watchNewTweetKey"
#define kWatchMentionKey  @"watchMentionKey"
#define kRetweetKey       @"watchRetweetKey"
#define kFavoritedKey     @"watchFavoritedKey"
#define kNewFollowerKey   @"watchNewFollowerKey"
#define kDirectMessageKey @"watchDirectMessagekey"

#define kMentionSinceIDKey     @"mentionSinceIDKey"
#define kRetwieetsSinceIDKey   @"retwieetsSinceIDKey"
#define kDirectMessagesSinceID @"directMessagesSinceIDKey"

#define kClientCredential  @"clientCredential"

@interface WFTwitterSettingInternal () {
    __weak WFTwitterSettingInternal *_weakSelf;
    WFTwitterAccountVerifyCredentials *_verifyCredentials;
    WFTwitterTokenRequest *_tokenRequest;
    WFTwitterVerifyCredential *_verifyCredential;
}
@property (nonatomic) WFAccount *account;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *screen_name;
@property (nonatomic) NSString *profile_image_url;

@property (nonatomic) BOOL watchNewTweet;
@property (nonatomic) BOOL watchMention;
@property (nonatomic) BOOL watchRetweet;
@property (nonatomic) BOOL watchFavorited;
@property (nonatomic) BOOL watchNewFollower;
@property (nonatomic) BOOL watchDirectMessage;
@property (nonatomic) BOOL canAccessDirectMessage;
@end

@implementation WFTwitterSettingInternal
@synthesize account;
@synthesize name;
@synthesize screen_name;
@synthesize profile_image_url;

@synthesize watchNewTweet;
@synthesize watchMention;
@synthesize watchRetweet;
@synthesize watchFavorited;
@synthesize watchNewFollower;
@synthesize watchDirectMessage;
@synthesize canAccessDirectMessage;

#pragma mark - Constructor
- (id)initWithAccount:(ACAccount *)a {
    self = [super init];
    if (self) {
        _weakSelf = self;
        self.account = [[WFAccount alloc] initWithAccount:a];
        self.name    = a.username;
    }
    return self;
}
#pragma mark - Private methods
#pragma mark - Public methods
- (void)setWatchFlag:(WFTwitterEventType)eventType value:(BOOL)value {
    switch (eventType) {
        case TWHomeTimeLine: self.watchNewTweet = value; break;
        case TWMention:      self.watchMention = value; break;
        case TWRetweet:      self.watchRetweet = value; break;
        case TWFavorited:    self.watchFavorited = value; break;
        case TWNewFollower:  self.watchNewFollower = value; break;
        case TWDirectMessage:
            if (self.canAccessDirectMessage) {
                self.watchDirectMessage = value;
            }
            break;
        default:
            DLog(@"WARNING! %s Unexpected event type:%d", __func__, eventType);
            break;
    }
}
// 特定のイベントタイプをWatchすべきかを返します
- (BOOL)readWatchFlag:(WFTwitterEventType)eventType {
    switch (eventType) {
        case TWHomeTimeLine: return self.watchNewTweet;
        case TWMention:      return self.watchMention;
        case TWRetweet:      return self.watchRetweet;
        case TWFavorited:    return self.watchFavorited;
        case TWNewFollower:  return self.watchNewFollower;
        case TWDirectMessage:return self.watchDirectMessage;
        default: return NO;
    }
}

- (void)requestDMToken:(UIWebView *)webView key:(NSString *)key secret:(NSString *)secret callbackURI:(NSString *)callbackURI handler:(WFTwitterSettingHandler)handler {
    WFOAuthCredential *clientCre = [[WFOAuthCredential alloc] initWithKey:key secret:secret];
    self.account.clientCredential = clientCre;
    
    // FIXME ユーザ名の入力間違い(認証は通った時)、ユーザ名入力が出ない(アプリ認証ボタンに置換される)。キャッシュ削除しても無駄。
    // [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    _tokenRequest =
    [WFTwitterTokenRequest
     requestToken:webView
     account:self.account
     callbackURL:callbackURI
     handler:^(BOOL succeeded, NSError *error) {
         _weakSelf.canAccessDirectMessage = succeeded;
         handler(succeeded, error);
     }];
}

- (void)requestUserStatus:(WFTwitterSettingHandler)handler {
    _verifyCredential =
    [WFTwitterVerifyCredential
     accountVerifyCredential:self.account
     handler:^(id jsonData, NSHTTPURLResponse *urlResponse, NSError *error) {
         [_weakSelf handleVerifyCredential:handler jsonData:jsonData urlResponse:urlResponse error:error];
     }];
}
- (void)handleVerifyCredential:(WFTwitterSettingHandler)handler jsonData:(id)jsonData urlResponse:(NSHTTPURLResponse *)urlResponse error:(NSError *)error {
    if (_verifyCredential.verified ) {
        self.name              = _verifyCredential.name;
        self.screen_name       = _verifyCredential.screen_name;
        self.profile_image_url = _verifyCredential.profile_image_url;
    }
    // FIXME アカウント名違いの時の処理、警告
    handler(_verifyCredential.verified, error);
    _verifyCredential = nil;
}

- (NSDictionary *)exportSettings {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    dic[kWatchNewTweetKey] = [NSNumber numberWithBool:self.watchNewTweet];
    dic[kWatchMentionKey]  = [NSNumber numberWithBool:self.watchMention];
    dic[kRetweetKey]       = [NSNumber numberWithBool:self.watchRetweet];
    dic[kFavoritedKey]     = [NSNumber numberWithBool:self.watchFavorited];
    dic[kNewFollowerKey]   = [NSNumber numberWithBool:self.watchNewFollower];
    dic[kDirectMessageKey] = [NSNumber numberWithBool:self.watchDirectMessage];
    
//FIXME  実装
    /*
     if (self.canAccessDirectMessage) {
     dic[kTokenKey]  = _token;
     dic[kSecretKey] = _secret;
     }*/
    
    return dic;
}

- (void)importSettings:(NSDictionary *)dic {
    self.watchNewTweet = [dic[kWatchNewTweetKey] boolValue];
    self.watchMention  = [dic[kWatchMentionKey] boolValue];
    self.watchRetweet  = [dic[kRetweetKey] boolValue];
    self.watchFavorited     = [dic[kFavoritedKey] boolValue];
    self.watchNewFollower   = [dic[kNewFollowerKey] boolValue];
    self.watchDirectMessage = [dic[kDirectMessageKey] boolValue];
    
// FIXME  実装
    /*
     _token = dic[kTokenKey];
     _secret= dic[kSecretKey];
     
     self.canAccessDirectMessage = (_token != nil) && (_secret != nil);
     
     // Credentialを更新
     
     
     if (self.canAccessDirectMessage) {
     WFOAuthCredential *tokenCre = [[WFOAuthCredential alloc] initWithKey:_token secret:_secret];
     [self.account setAppCredentials: tokenCredential:tokenCre];
     ACAccountCredential *c = [[ACAccountCredential alloc] initWithOAuthToken:_token tokenSecret:_secret];
     self.account.credential = c;
     }*/
}
@end
