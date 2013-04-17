//
//  TwitterPollingConnector.h
//  WFSocialListener
//
//  Created by akihiro uehara on 2013/03/07.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFAccount.h"

typedef void(^WFConnectorHandler)(id jsonData, NSHTTPURLResponse *urlResponse, NSError *error);

@interface WFConnector : NSObject

@property (nonatomic, readonly) WFAccount    *account;
@property (nonatomic, readonly) NSString     *endpoint;
@property (nonatomic, readonly) NSDictionary *parameters;
@property (nonatomic, readonly) NSDate       *lastUpdatedAt;

- (id)initWithAccount:(WFAccount *)account endpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters;

- (NSURLRequest *)prepareURLRequest:(NSDictionary *)additionalParameters;
// parametersは初期化時の設定パラメータを上書きします。nilであればデフォルトパラメータが使われます。
- (void)fetch:(NSDictionary *)parameters handler:(WFConnectorHandler)handler;

@end
