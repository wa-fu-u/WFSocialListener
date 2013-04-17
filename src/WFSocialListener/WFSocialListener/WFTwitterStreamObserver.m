//
//  WFTwitterStreamObserver.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/15.
//  Copyright (c) 2013年 Akihiro Uehara. All rights reserved.
//

#import "WFTwitterStreamObserver.h"
#import "WFTwitterStreamEvent.h"

@interface WFTwitterStreamObserver () {
    __weak NSObject<WFTwitterObserverDelegate> *_delegate;
    WFTwitterSettingInternal *_setting;
    WFTwitterStreamConnector *_streamConnector;
    dispatch_queue_t _queue;
    NSDate *_startStreamingAt;
}
@property (nonatomic) BOOL isRunning;
@end

@implementation WFTwitterStreamObserver
#pragma mark - Constructor
- (id)initWithDelegate:(NSObject<WFTwitterObserverDelegate> *)delegate setting:(WFTwitterSettingInternal *)setting  queue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _setting  = setting;
        _queue    = queue;
    }
    return self;
}

#pragma mark - Private methods
-(WFTwitterEventType)isTWEvent:(id)json {
    WFTwitterEventType parsedEventType = Unknown;
    // イベントとして解析
    WFTwitterStreamEvent *event = [WFTwitterStreamEvent parse:json];
    if (event != nil) {
        // ターゲットを確認
        if([_setting.account.username isEqualToString:event.target_name]) {
            switch (event.eventType) {
                case WFTWStreamFollow:   parsedEventType = TWNewFollower; break;
                case WFTWStreamFavorite: parsedEventType = TWFavorited; break;
                default:
                    break;
            }
        }
    }
    return parsedEventType;
}

-(WFTwitterEventType)parseTweetType:(id)jsonData {
    if(jsonData == nil || ![jsonData isKindOfClass:[NSDictionary class]]) return Unknown;

    NSDictionary *json = (NSDictionary *)jsonData;
        
    // DM？
    if(json[@"direct_message"] != nil) {
        return TWDirectMessage;
    }

    // Retweets？
    NSString *text = json[@"text"];
    NSString *rtTxt = [NSString stringWithFormat:@"RT @%@", _setting.account.username];
    if([text hasPrefix:rtTxt]) {
        return TWRetweet;
    }

    // mentionか
    NSDictionary *entities = json[@"entities"];
    NSArray *user_mentions = entities[@"user_mentions"];
    if(user_mentions != nil && [user_mentions isKindOfClass:[NSArray class]]) {
        for(NSDictionary *m in user_mentions) {
            NSString *name = m[@"name"];
            if([_setting.account.account.username isEqualToString:name]) {
                return TWMention;
            }
        }
    }

    // 自分の投稿を除くTWか？
    if(json[@"user"] != nil && [json[@"user"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *userdic = (NSDictionary *)json[@"user"];
        NSString *srcUserName = userdic[@"name"];
        if( ! [_setting.account.username isEqualToString:srcUserName]) {
            return TWHomeTimeLine;
        }
    }

    return Unknown;
}

// 再接続時間の計算。接続時間が1分未満なら、1分待つ。そうでなければ、10秒後に。単純すぎるけど、とりあえず
-(NSTimeInterval)getReconnectionInterval {
    NSTimeInterval duration = -1 * [_startStreamingAt timeIntervalSinceNow];
    if(duration > 60 ) {
        return 10;
    } else {
        return 60;
    }
}
-(void)reconnect {
    __weak WFTwitterStreamObserver *weak_self = self;
    double delayInSeconds = [self getReconnectionInterval];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(weak_self.isRunning) {
            [weak_self start];
        }
    });
}

-(void)callDelegateWithEvent:(WFTwitterEventType)eventType jsonData:(id)jsonData {
    // フィルタリング
    BOOL callDelegate = NO;
    switch (eventType) {
        case TWHomeTimeLine: callDelegate = [_setting watchNewTweet]; break;
        case TWMention: callDelegate = [_setting watchMention]; break;
        case TWRetweet: callDelegate = [_setting watchRetweet]; break;
        case TWFavorited: callDelegate = [_setting watchFavorited]; break;
        case TWNewFollower: callDelegate = [_setting watchNewFollower]; break;
        case TWDirectMessage: callDelegate = [_setting watchDirectMessage]; break;
        default: break;
    }

    // delegate呼び出し
    if(callDelegate) {
        [_delegate didTwitterUpdated:self account:_setting.account eventType:eventType jsonData:jsonData];
    }

}
#pragma mark - WFTwitterStreamDelegate <NSObject>
- (void)didReceivedJSONData:(WFTwitterStreamConnector *)sender jsonData:(id)jsonData {
    WFTwitterEventType eventType;
    // イベント解析
    eventType = [self isTWEvent:jsonData];
    // TW解析
    if(eventType == Unknown) {
        eventType = [self parseTweetType:jsonData];
    }
    [self callDelegateWithEvent:eventType jsonData:jsonData];
}

- (void)didReceivedErrorHttpResponse:(WFTwitterStreamConnector *)sender httpResponse:(NSHTTPURLResponse *)response {
    [self reconnect];
}

- (void)didStreamDisconnected:(WFTwitterStreamConnector *)sender error:(NSError *)error {
    [self reconnect];
}

#pragma mark - Public method
-(void)start {
    _isRunning = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        _startStreamingAt = [NSDate date];
        _streamConnector = [[WFTwitterStreamConnector alloc]
                            initWithDelegate:self
                            account:_setting.account
                            endpoint:@"https://userstream.twitter.com/1.1/user.json" parameters:nil];
        [_streamConnector start];
    });
}
-(void)cancel {
    _isRunning = NO;
    [_streamConnector cancel];
    _streamConnector = nil;
}
@end
