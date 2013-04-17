//
//  Reachability.h
//  WFSocialListener
//
//  Created by akihiro uehara on 2013/03/06.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	NotReachable = 0,
	WiFiReachable,
	WWANReachable
} NetworkStatus;

// see http://developer.apple.com/library/ios/#samplecode/Reachability/Introduction/Intro.html
@interface WFReachability : NSObject
// ネットワーク接続状態。KVO
@property (nonatomic, readonly) NetworkStatus status;
// モニタリングをしているか。KVO
@property (nonatomic, readonly) BOOL isWatching;

+(WFReachability *)sharedInstance;

// モニタリングを開始します
- (void)start;
// モニタリングを停止します。
- (void)stop;
@end
