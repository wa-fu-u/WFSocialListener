//
//  WFOAuthError.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/19.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFError : NSError
+(id)createError:(NSString *)domain code:(NSInteger)code shortDescription:(NSString *)shortDescription description:(NSString *)description suggestion:(NSString *)suggestion;
@end
