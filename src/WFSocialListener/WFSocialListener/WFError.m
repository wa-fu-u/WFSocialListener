//
//  WFOAuthError.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/19.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFError.h"

@implementation WFError
//- (NSDictionary *)userInfo;
+(id)createError:(NSString *)domain code:(NSInteger)code shortDescription:(NSString *)shortDescription description:(NSString *)description suggestion:(NSString *)suggestion {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    // エラー原因の短い説明
    if (shortDescription != nil) {
        dict[NSLocalizedFailureReasonErrorKey] = shortDescription;
    }
    // エラー原因の説明
    if (description != nil) {
        dict[NSLocalizedDescriptionKey] = description;
    }
    // エラー原因の対処方法
    if (suggestion != nil) {
        dict[NSLocalizedRecoverySuggestionErrorKey] = suggestion;
    }
    return [WFError errorWithDomain:domain code:code userInfo:dict];
}
@end
