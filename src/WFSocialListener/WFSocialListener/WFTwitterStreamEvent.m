//
//  WFTwitterStreamEvent.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/14.
//  Copyright (c) 2013年 Akihiro Uehara. All rights reserved.
//

#import "WFTwitterStreamEvent.h"

@interface WFTwitterStreamEvent () {
    NSDictionary *_eventTypes;
}
@property (nonatomic) NSString *event;
@property (nonatomic) NSDictionary *target;
@property (nonatomic) NSDictionary *source;
@property (nonatomic) NSObject *target_object;
@property (nonatomic) NSDate *created_at;

@property (nonatomic) WFTwitterStreamEventType eventType;

@property (nonatomic) NSString *source_name;
@property (nonatomic) NSString *source_id_str;

@property (nonatomic) NSString *target_name;
@property (nonatomic) NSString *target_id_str;

+(WFTwitterStreamEvent *)parse:(id)jsonData;
@end

@implementation WFTwitterStreamEvent
#pragma mark - Constructor
-(id)init {
    self = [super init];
    if (self) {
        _eventTypes = @{
                        @"block" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamBlock],
                        @"unblock" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamUnblock],
                        @"favorite" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamFavorite],
                        @"unfavorite": [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamUnfavorite],
                        @"follow" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamFollow],
                        @"unfollow" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamUnfollow],
                        @"list_created" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamListCreated],
                        @"list_destroyed" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamListDestroyed],
                        @"list_updated" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamListUpdated],
                        @"list_member_added" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamListMemberAdded],
                        @"list_member_removed" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamListMemberRemoved],
                        @"list_user_subscribed" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamListUserSubscribed],
                        @"list_user_unsubscribed" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamListUserUnsubscribed],
                        @"user_update" : [NSNumber numberWithInt:(WFTwitterStreamEventType)WFTWStreamUserUpdate],
                        };
    }
    return self;
}

+ (WFTwitterStreamEvent *)parse:(id)jsonData {
    WFTwitterStreamEvent *inst = [[WFTwitterStreamEvent alloc] init];

    inst.eventType = [inst getEventType:jsonData];
    if(inst.eventType == WFTWStreamUnknown) {
        return nil;
    }
    
    [inst parseContents:(NSDictionary *)jsonData];
    
    return inst;
}

- (NSString *)description {
    NSMutableString *dsc = [[NSMutableString alloc] init];
    [dsc appendFormat:@"target :%@\n",self.target];
    [dsc appendFormat:@"source :%@\n",self.source];
    [dsc appendFormat:@"event  :%@\n",self.event];
    [dsc appendFormat:@"target_object :%@\n",self.target_object];
    [dsc appendFormat:@"created_at :%@\n",self.created_at];
    
    return dsc;
}

#pragma mark - private method
-(WFTwitterStreamEventType)getEventType:(id)jsonData {
    if (jsonData == nil || ! [jsonData isKindOfClass:[NSDictionary class]] ) {
        return (WFTwitterStreamEventType)WFTWStreamUnknown;
    }
    
    NSDictionary *dic = (NSDictionary *)jsonData;
    NSString *eventName = dic[@"event"];
    NSNumber *eventType = _eventTypes[eventName];
    
    if(eventType == nil) {
        return (WFTwitterStreamEventType) WFTWStreamUnknown;
    } else {
        return (WFTwitterStreamEventType) [eventType intValue];
    }
}

-(void)parseContents:(NSDictionary *)dic {
    NSObject *inst;
    
    self.event  = dic[@"event"];
    
    inst = dic[@"target"];
    if (inst != nil && [inst isKindOfClass:[NSDictionary class]]) {
        self.target = (NSDictionary *)inst;
    }
    
    inst = dic[@"source"];
    if (inst != nil && [inst isKindOfClass:[NSDictionary class]]) {
        self.source = (NSDictionary *)inst;
    }
    
    self.target_object = dic[@"target_object"];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [fmt setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    self.created_at = [fmt dateFromString:dic[@"created_at"]];
    
    self.source_name   = self.source[@"name"];
    self.source_id_str = self.source[@"id_str"];
    
    self.target_name   = self.target[@"name"];
    self.target_id_str = self.target[@"id_str"];
}
#pragma mark - Public methods

@end
