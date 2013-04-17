//
//  WFtwitterConnection.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/11.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFTwitterFetchObserver.h"
#import "WFTwitterConnector.h"

@interface WFTwitterFetchObserver () {
    __weak NSObject<WFTwitterObserverDelegate> *_delegate;
    WFTwitterSettingInternal *_setting;
    
    NSDictionary *_connectors;
    NSNumber *_previousNewFollowerID;
}
@end

@implementation WFTwitterFetchObserver
#pragma mark - Constructor
- (id)initWithDelegate:(NSObject<WFTwitterObserverDelegate> *)delegate setting:(WFTwitterSettingInternal *)setting  {
    self = [super init];
    if (self) {
        _delegate   = delegate;
        _setting  = setting;
        
        _previousNewFollowerID = nil;
        [self initConnectors];
    }
    return self;
}
// コネクタを初期化します
- (void)initConnectors {
    NSMutableDictionary *connectors = [[NSMutableDictionary alloc] init];
    
    connectors[[NSNumber numberWithInt:TWHomeTimeLine]] =
    [[WFTwitterConnector alloc] initWithAccount:_setting.account
                                       endpoint:@"https://api.twitter.com/1.1/statuses/home_timeline.json"
                                     parameters:@{@"trim_user" : @"true", @"exclude_replies": @"true", @"contributor_details" : @"false", @"include_entities" : @"false"}];
    
    connectors[[NSNumber numberWithInt:TWMention]] =
    [[WFTwitterConnector alloc] initWithAccount:_setting.account
                                       endpoint:@"https://api.twitter.com/1.1/statuses/mentions_timeline.json"
                                     parameters:@{@"trim_user" : @"true", @"include_entities" : @"false", @"contributer_details" : @"false"}];
    
    connectors[[NSNumber numberWithInt:TWRetweet]] =
    [[WFTwitterConnector alloc] initWithAccount:_setting.account
                                       endpoint:@"https://api.twitter.com/1.1/statuses/retweets_of_me.json"
                                     parameters:@{@"trim_user" : @"true", @"include_entities" : @"false", @"include_user_entities" : @"false"}];
    /* 他者のFavoritedの行動はStreamingで取得
     connectors[[NSNumber numberWithInt:TWFavorited]] =
     [[WFTwitterConnector alloc] initWithAccount:_setting.account
     endpoint:@"https://api.twitter.com/1.1/favorites/list.json"
     parameters:@{@"trim_user" : @"true", @"include_entities" : @"false", @"include_user_entities" : @"false"}];
     */
    connectors[[NSNumber numberWithInt:TWNewFollower]] =
    [[WFTwitterConnector alloc] initWithAccount:_setting.account
                                       endpoint:@"https://api.twitter.com/1.1/followers/ids.json"
                                     parameters:@{@"count" : @"100"}];
    
    connectors[[NSNumber numberWithInt:TWDirectMessage]] =
    [[WFTwitterConnector alloc] initWithAccount:_setting.account
                                       endpoint:@"https://api.twitter.com/1.1/direct_messages.json"
                                     parameters:@{@"skip_status" : @"true", @"include_entities" : @"false", @"count" : @"20"}];
    
    _connectors = connectors;
}

#pragma mark - Private methods
- (void)watch:(WFTwitterEventType)event
{
    WFTwitterConnector *c = [_connectors objectForKey:[NSNumber numberWithInt:event]];
    if (c != nil) {
        if (event == TWNewFollower) {
            [self checkNewFollower];
        } else {
            [c fetchSincePrevious:^(id jsonData, NSHTTPURLResponse *urlResponse, NSError *e) {
                if (urlResponse.statusCode == 200 && e == nil) {
                    if ([_delegate respondsToSelector:@selector(didTwitterUpdated:account:eventType:jsonData:)]) {
                        [_delegate didTwitterUpdated:self account:_setting.account eventType:event jsonData:jsonData];
                    }
                }
            }];
        }
//        DLog(@"%s :: username:%@, event:%d ", __func__, c.account.account.username, event);
    }
}
- (void)checkNewFollower {
    WFTwitterConnector *c = [_connectors objectForKey:[NSNumber numberWithInt:TWNewFollower]];
    [c fetch:nil handler:^(id jsonData, NSHTTPURLResponse *urlResponse, NSError *e) {
        if (urlResponse.statusCode == 200 && e == nil) {
            NSNumber *newFollowerID = nil;
            
            // ユーザリストを取得
            NSArray *ids = [jsonData objectForKey:@"ids"];
            if (ids == nil) {
                //
            } else if ([ids count] == 0) {
                // フォロワーゼロ
            } else {
                newFollowerID = [ids objectAtIndex:0];
            }
            
            // ハンドラを呼び出し
            if (_previousNewFollowerID != nil && newFollowerID != nil && ![_previousNewFollowerID isEqualToNumber:newFollowerID]) {
                if ([_delegate respondsToSelector:@selector(didTwitterUpdated:account:eventType:jsonData:)]) {
                    [_delegate didTwitterUpdated:self account:_setting.account eventType:TWNewFollower jsonData:jsonData];
                }
            }
            
            // IDを更新
            if (newFollowerID != nil) {
                _previousNewFollowerID = newFollowerID;
            }
        }
    }];
}


#pragma mark - Public methods
- (void)fetch {    
    for (NSNumber *key in [_connectors allKeys]) {
        WFTwitterEventType event = [key intValue];
        if ( [_setting readWatchFlag:event] ) { // should watch
            [self watch:event];
        }
    }    
}
@end
