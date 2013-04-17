//
//  WFTwitterStreamEvent.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/14.
//  Copyright (c) 2013年 Akihiro Uehara. All rights reserved.
//

#import "WFTwitterConnector.h"

typedef enum {
    WFTWStreamUnknown = 0,
    WFTWStreamBlock,
    WFTWStreamUnblock,
    WFTWStreamFavorite,
    WFTWStreamUnfavorite,
    WFTWStreamFollow,
    WFTWStreamUnfollow,
    WFTWStreamListCreated,
    WFTWStreamListDestroyed,
    WFTWStreamListUpdated,
    WFTWStreamListMemberAdded,
    WFTWStreamListMemberRemoved,
    WFTWStreamListUserSubscribed,
    WFTWStreamListUserUnsubscribed,
    WFTWStreamUserUpdate
} WFTwitterStreamEventType;

@interface WFTwitterStreamEvent : NSObject
// JSONデータの素直な展開
@property (nonatomic, readonly) NSString *event;
@property (nonatomic, readonly) NSDictionary *target;
@property (nonatomic, readonly) NSDictionary *source;
@property (nonatomic, readonly) NSObject *target_object;
@property (nonatomic, readonly) NSDate *created_at;

@property (nonatomic, readonly) WFTwitterStreamEventType eventType;

// source/targetの詳細
@property (nonatomic, readonly) NSString *source_name;
@property (nonatomic, readonly) NSString *source_id_str;

@property (nonatomic, readonly) NSString *target_name;
@property (nonatomic, readonly) NSString *target_id_str;

+(WFTwitterStreamEvent *)parse:(id)jsonData;
@end
