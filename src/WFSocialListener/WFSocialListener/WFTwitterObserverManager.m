//
//  WFTwitterNetManager.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/30.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFTwitterObserverManager.h"
#import "WFTwitterSettingInternal.h"
#import "WFTwitterFetchObserver.h"
#import "WFTwitterStreamObserver.h"


//#define FETCH_INTERVAL 60
#define FETCH_INTERVAL 15
#define QUEUE_NAME "com.wa-fu-u.twitter_fetch_queue"

@interface WFTwitterObserverManager () {
    __weak NSObject<WFTwitterObserverDelegate> *_delegate;
    
    NSTimeInterval    _fetchInterval;
    dispatch_queue_t  _fetchQueue;
    dispatch_source_t _timer;
    
    NSArray *_fetchObservers;
    NSArray *_streamObservers;
    
    WFReachability *_reachability;
    BOOL _isRunning;
}
@property (nonatomic) NetworkStatus networkStatus;
@property (nonatomic) BOOL isStreaming;
@end

@implementation WFTwitterObserverManager

- (id)initWithDelegate:(NSObject<WFTwitterObserverDelegate> *)delegate settings:(NSArray *)settings {
    self = [super init];
    if (self) {
        _delegate      = delegate;
        _fetchInterval = FETCH_INTERVAL;
        
        _fetchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        
        NSMutableArray *cons;
        cons = [[NSMutableArray alloc] init];
        for (WFTwitterSettingInternal *setting in settings) {
            [cons addObject:[[WFTwitterFetchObserver alloc] initWithDelegate:_delegate setting:setting]];
        }
        _fetchObservers = cons;
        
        cons = [[NSMutableArray alloc] init];
        for (WFTwitterSettingInternal *setting in settings) {
            [cons addObject:[[WFTwitterStreamObserver alloc] initWithDelegate:_delegate setting:setting queue:_fetchQueue]];
        }
        _streamObservers = cons;
        
        _reachability = [[WFReachability alloc] init];
        [_reachability addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:(__bridge void *)(_reachability)];
        [_reachability start];
        self.networkStatus = _reachability.status;
  
// FIXME
//        [self startPolling];
    }
    return self;
}
- (void)dealloc {
    [_reachability removeObserver:self forKeyPath:@"status"];
    [self cancelPolling];
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)(_reachability)) {
        self.networkStatus = _reachability.status;
        if(_isRunning) {
            [self start];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Private methods
- (void)startPolling {
    if (_timer != nil) return;
    
    __weak WFTwitterObserverManager *weak_self = self;
    _timer =dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _fetchQueue);
    dispatch_source_set_timer(_timer,
                              DISPATCH_TIME_NOW,
                              _fetchInterval * NSEC_PER_SEC,
                              (_fetchInterval /2) * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{ [weak_self fetch]; });
    
    dispatch_resume(_timer);
}
- (void)cancelPolling {
    if (_timer != nil) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)startStreaming {
    for (WFTwitterStreamObserver *con in _streamObservers) {
        dispatch_async(_fetchQueue, ^{
            [con start];
        });
    }
}

- (void)cancelStreaming {
    for (WFTwitterStreamObserver *con in _streamObservers) {
        dispatch_async(_fetchQueue, ^{
            [con cancel];
        });
    }
}

#pragma mark - Public methods
- (void)fetch {
    for (WFTwitterFetchObserver *con in _fetchObservers) {
        dispatch_async(_fetchQueue, ^{
            [con fetch];
        });
    }
}

-(void)start {
    [self cancel];
    
    self.isStreaming = (self.networkStatus == WiFiReachable);

    if(self.isStreaming) {
        [self startStreaming];
    } else {
        [self startPolling];
    }
    _isRunning = YES;
}
-(void)cancel {
    _isRunning = NO;
    [self cancelPolling];
    [self cancelStreaming];
}
@end
