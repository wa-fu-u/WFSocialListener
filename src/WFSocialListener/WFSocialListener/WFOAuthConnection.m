//
//  WFOAuthConnection.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/04/21.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFOAuthConnection.h"
#import "WFError.h"
#import "WFOAuthTypes.h"
#import "WFOAuthRequest.h"

@interface WFOAuthConnection () {
    SLRequestHandler _handler;
    
    NSURLConnection *_connection;
    NSHTTPURLResponse *_httpResponse;
}
@end

@implementation WFOAuthConnection
#pragma mark - Public method
+(WFOAuthConnection *)request:(WFOAuthCredential *)clientCredential
              tokenCredential:(WFOAuthCredential *)token
              oauthParameters:(NSDictionary *)oauthParams
                     endpoint:(NSURL *)endpoint
                   httpMethod:(WFOAuthHttpMethodType)httpMethod
              queryParameters:(NSDictionary *)p
                      handler:(SLRequestHandler)handler
{
    WFOAuthConnection *inst = [[WFOAuthConnection alloc]
                               initWithCredential:clientCredential
                               tokenCredential:token
                               oauthAdditionalParameters:oauthParams
                               endpoint:endpoint
                               httpMethod:httpMethod
                               queryParameters:p];
    inst->_handler = handler;
    
    NSURLRequest *req = [inst preparedURLRequest];
    inst->_connection = [[NSURLConnection alloc] initWithRequest:req delegate:inst];
    [inst->_connection start];
    
    return inst;
}

+(NSDictionary *)parseKeyValueData:(NSData *)data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableDictionary *kvp = [[NSMutableDictionary alloc] init];
    for (NSString *s in [str componentsSeparatedByString:@"&"]) {
        NSArray *kv = [s componentsSeparatedByString:@"="];
        if ([kv count] == 2) {
            kvp[[kv objectAtIndex:0]] = [kv objectAtIndex:1];
        }
    }
    return kvp;
}
#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _httpResponse = (NSHTTPURLResponse *)response;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    WFError *err = nil;
    NSInteger statusCode = _httpResponse.statusCode;
    if (statusCode != 200) {
        err = [WFError createError:kWFOAuthErrorDomain
                              code:WFOAuthHttpError
                  shortDescription:@"Unexpected status code."
                       description:[NSString stringWithFormat:@"Http status code was %d, not 200.", statusCode]
                        suggestion:nil];
    }
    // content-typeの確認
    /*
     NSString *expectedContentType = @"text/html";
     if (![_contentType isEqualToString:expectedContentType]) {
     err = [WFOAuthError createError:WFOAuthHttpError
     shortDescription:@"Unexpected content type."
     description:[NSString stringWithFormat:@"Content type was %@. expected:%@. Data:%@", _contentType, expectedContentType, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]
     suggestion:nil];
     }*/
    _handler(data, _httpResponse, err);
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _handler(nil, _httpResponse, error);
}
@end
