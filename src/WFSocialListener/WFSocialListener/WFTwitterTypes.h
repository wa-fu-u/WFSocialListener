//
//  WFTwitterTypes.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/06.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#ifndef WFSocialListener_WFTwitterTypes_h
#define WFSocialListener_WFTwitterTypes_h

#define kWFTwitterErrorDomain @"WFTwitterErrorDomain"
typedef enum {
    WFTwitterUnknownError = 0,
    WFTwitterOAuthRequestError,
    WFTwitterAccountVerificationError,
} WFTwitterErrorCode;

typedef enum {
    Unknown         = 0,
    TWHomeTimeLine  = 1,
    TWMention       = 2,
    TWRetweet       = 3,
    TWFavorited     = 4,
    TWNewFollower   = 5,
    TWDirectMessage = 6
} WFTwitterEventType;


#endif
