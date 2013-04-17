//
//  WFSocialListener.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/11.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFSocialListener.h"

#import "WFTwitterSettingInternal.h"
#import "WFTwitterObserverManager.h"

@interface WFSocialListener () {
    __weak NSObject<WFSocialListenerDelegate> *_delegate;
    WFTwitterObserverManager *_observerManager;
}
@property (nonatomic) NetworkStatus networkStatus;
@property (nonatomic) BOOL isStreaming;
@property (nonatomic) NSArray *twitterSettings;
@end

@implementation WFSocialListener
#pragma mark - Constructor
- (id)initWithDelegate:(NSObject<WFSocialListenerDelegate> *)delegate {
    self = [super init];
    if (self){
        _delegate = delegate;
        [self loadAllTwitterAccountSettings];        
    }
    return self;
}
- (void)dealloc {
    [self cancel];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)(_observerManager)) {
        self.isStreaming   = _observerManager.isStreaming;
        self.networkStatus = _observerManager.networkStatus;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WFSocialListenerDelegate <NSObject>
- (void)didTwitterUpdated:(id)sender account:(WFAccount *)account eventType:(WFTwitterEventType)event jsonData:(id)json {
//DLog(@"%s sender:%@ account:%@ eventType:%d json:%@",  __func__, sender, account, event, json);
    [_delegate didTwitterUpdated:self account:account.account eventType:event json:json];
}

#pragma mark - Private methods
// 現在のデバイスのTwitterアカウント設定を読み込みます
- (void)loadAllTwitterAccountSettings {
    NSMutableArray *settings = [[NSMutableArray alloc] init];
    
    ACAccountStore *store      = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [store requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            for (ACAccount *account in store.accounts) {
                if ([account.accountType.identifier isEqualToString:ACAccountTypeIdentifierTwitter]) {
                    WFTwitterSettingInternal *setting = [[WFTwitterSettingInternal alloc] initWithAccount:account];
                    [settings addObject:setting];
                }
            }
            [self updateSettings:settings];
        }
    }];
}
// 現在の設定情報をアカウントから探す
- (WFTwitterSettingInternal *)findSetting:(ACAccount *)account {
    for (WFTwitterSettingInternal *setting in _twitterSettings) {
        ACAccount *a = setting.account.account;
        if ([a.accountType.identifier isEqualToString:account.accountType.identifier] && [a.username isEqualToString:account.username]) {
            return setting;
        }
    }
    return nil;
}
// アカウントから唯一の文字列を作ります
- (NSString *)getAccountKey:(ACAccount *)account {
    return [NSString stringWithFormat:@"%@::%@", account.accountType.identifier, account.username ];
}

/* FIXME 読み込み関連
- (WFTwitterSetting *)getTwitterSetting:(ACAccount *)account {
    // 設定を取り出す。見つからなければ新規に取り出す新規に作る
    WFTwitterSettingInternal *setting = [self findSetting:account];
    if (setting == nil ) {
        setting = [[WFTwitterSettingInternal alloc] initWithAccount:account];
    }
    
    return setting;
}
*/
- (void)updateSettings:(NSArray *)settings {
    self.twitterSettings = settings;
    if ([_delegate respondsToSelector:@selector(didReadAccounts:accountTypeIdentifier:)]) {
        [_delegate didReadAccounts:self accountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    }
    // 再起動
    [self start];
}
#pragma mark - Public methods
- (void)importSettings:(NSDictionary *)settings {
    /* FIXME 実装
    ACAccountStore *store      = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [store requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            for (ACAccount *a in store.accounts) {
                // 設定情報を取得
                WFTwitterSettingInternal *setting = (WFTwitterSettingInternal *)[self getTwitterSetting:a];
                // 指定された設定情報を上書き
                NSString *key   = [self getAccountKey:a];
                NSDictionary *s = settings[key];
                if (s != nil) {
                    [setting importSettings:s];
                }
            }
            
        }
    }];
     */
}
- (NSDictionary *)exportSettings {
    /* FIXME 実装
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    for (WFTwitterSettingInternal *s in _twitterSettings) {
        NSString *key = [self getAccountKey:s.account];
        settings[key] = [s exportSettings];
    }
    return settings;
     */
    return nil;
}

- (void)start {
    [self cancel];

    _observerManager = [[WFTwitterObserverManager alloc] initWithDelegate:self settings:self.twitterSettings];
    [_observerManager addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:(__bridge void *)(_observerManager)];
    [_observerManager addObserver:self forKeyPath:@"isStreaming" options:NSKeyValueObservingOptionNew context:(__bridge void *)(_observerManager)];

    [_observerManager start];
}
- (void)cancel {
    if(_observerManager != nil) {
        [_observerManager removeObserver:self forKeyPath:@"status"];
        [_observerManager removeObserver:self forKeyPath:@"isStreaming"];
        _observerManager = nil;
    }
}
@end
