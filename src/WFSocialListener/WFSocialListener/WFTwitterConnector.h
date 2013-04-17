//
//  WFTwitterConnector.h
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/09.
//  Copyright (c) 2013年 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFTwitterTypes.h"
#import "WFConnector.h"

typedef void(^didTwitterUpdatedHandler)(WFAccount *account, WFTwitterEventType eventType, id json);

@interface WFTwitterConnector : WFConnector

@property (nonatomic) NSString     *sinceID;
@property (nonatomic) NSDictionary *defaultParameters;

//フェッチして、sinceIDを更新します。以前のsinceIDよりも新しい投稿があった場合に、handlerに通知します。
- (void)fetchSincePrevious:(WFConnectorHandler)handler;
@end
