//
//  WFOAuthTypes.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/06.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#ifndef WFSocialListener_WFOAuthTypes_h
#define WFSocialListener_WFOAuthTypes_h

#define kWFOAuthErrorDomain @"WFOAuthErrorDomain"
typedef enum {
    WFOAuthUnknownError = 0,
    WFOAuthHttpError,
    WFOAuthUnexpectedResponse,
    WFOAuthParseError,
} WFOAuthErrorCode;

#endif
