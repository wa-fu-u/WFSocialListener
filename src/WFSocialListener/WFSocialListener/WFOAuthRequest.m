//
//  WFOAuthRequest.m
//  WFSocialListener
//
//  Created by Akihiro Uehara on 2013/05/08.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFOAuthRequest.h"
#import <CommonCrypto/CommonHMAC.h>
#import "WFOAuthTypes.h"
#import "WFOAuthCredential.h"
#import "WFError.h"
#import "WFOAuthDefinitions.h"

// about oauth , http://openid-foundation-japan.github.io/draft-hammer-oauth-10.html

@interface WFOAuthRequest () {
    WFOAuthCredential *_client;
    WFOAuthCredential *_token;
    NSDictionary *_oauthParams;
    NSURL             *_endpoint;
    WFOAuthHttpMethodType _httpMethod;
    NSDictionary      *_queryParams;
}
@end

@implementation WFOAuthRequest
#pragma mark - Constructor
- (id)initWithCredential:(WFOAuthCredential *)clientCredential
        tokenCredential:(WFOAuthCredential *)token
oauthAdditionalParameters:(NSDictionary *)oauthParams
               endpoint:(NSURL *)endpoint
             httpMethod:(WFOAuthHttpMethodType)httpMethod
        queryParameters:(NSDictionary *)p {
    self = [super init];
    if (self) {
        _client      = clientCredential;
        _token       = token;
        _oauthParams = oauthParams;
        _endpoint    = endpoint;
        _httpMethod  = httpMethod;
        _queryParams = p;
    }
    return self;
}
#pragma mark - Private methods
- (NSString *)getHttpMethod:(WFOAuthHttpMethodType)httpType {
    switch (httpType) {
        case WFOAuthHttpGET:  return @"GET";
        case WFOAuthHttpPOST: return @"POST";
        default: return @"";
    }
}
// BASE64エンコードデータを、文字列に戻す
// a part of https://github.com/AFNetworking/AFOAuth1Client/blob/master/AFOAuth1Client/AFOAuth1Client.m
- (NSString *)encodeBase64WithData:(NSData *)data {
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

- (NSString *)percentEscape:(NSString *)str {
    static NSString * const kEscapeCharacters   = @":/?&=;+!@#$()~',";
    static NSString * const kUnescapeCharacters = @"[].";
    
	return (__bridge_transfer  NSString *)
    CFURLCreateStringByAddingPercentEscapes(
                                            kCFAllocatorDefault,
                                            (__bridge CFStringRef)str,
                                            (__bridge CFStringRef)kUnescapeCharacters,
                                            (__bridge CFStringRef)kEscapeCharacters,
                                            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

- (NSString *)signByCCHmacAlgSHA1:(NSString *)key text:(NSString *)text {
    NSData *keyData  = [key  dataUsingEncoding:NSUTF8StringEncoding];
    NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CCHmacContext cx;
    CCHmacInit(&cx, kCCHmacAlgSHA1, [keyData bytes], [keyData length]);
    CCHmacUpdate(&cx, [textData bytes], [textData length]);
    CCHmacFinal(&cx, digest);
    
    NSData *sigData = [[NSData alloc] initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    
    return [self encodeBase64WithData:sigData];
}

// key-valueをエンコード、ソートして、keyValueSeparatorで連結、ペアをdelimiterで連結します
- (NSString *)concatinateKeyValues:(NSDictionary *)parameters keyValueSeparator:(NSString *)separator parDelimiter:(NSString *)delimiter {
    // Key-Valueペアを連結
    NSMutableArray *ary = [[NSMutableArray alloc] init];
    for (NSString *key in [parameters allKeys]) {
        NSString *value = [parameters objectForKey:key];
        if (value == nil) {
            value = @"";
        }
        NSString *pair = [NSString stringWithFormat:@"%@%@%@", [self percentEscape:key], separator, [self percentEscape:value]];
        [ary addObject:pair];
    }
    
    // ソートして、ペアを連結
    NSArray *sortedAry = [ary sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableString *str = [[NSMutableString alloc] init];
    bool isFirstItem = YES;
    for (NSString *item in sortedAry) {
        if (! isFirstItem ) {
            [str appendString:delimiter];
        }
        isFirstItem = NO;
        [str appendString:item];
    }
    return str;
}

// 辞書のkey/valueを、URLエンコードして、"="で連結、ソートして、さらに"&"で連結します。
- (NSString *)buildSignalNormalizedParameter:(NSDictionary *)parameters {
    return [self concatinateKeyValues:parameters keyValueSeparator:@"=" parDelimiter:@"&"];
}

- (NSString *)createNonce {
    CFUUIDRef uuid = CFUUIDCreate(nil);
    CFStringRef s  = CFUUIDCreateString(nil, uuid);
    NSString *n    = CFBridgingRelease(s);
    CFRelease(uuid);
    
    return [n stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (NSString *)buildAuthorizationHeaderContent:(NSDictionary *)parameters {
    // key/valueを連結
    NSMutableArray *ary = [[NSMutableArray alloc] init];
    for (NSString *key in [parameters allKeys]) {
        NSString *value = [parameters objectForKey:key];
        if (value == nil) {
            value = @"";
        }
        NSString *pair = [NSString stringWithFormat:@"%@=\"%@\"", [self percentEscape:key], [self percentEscape:value]];
        [ary addObject:pair];
    }
    
    // ソートして連結
    NSArray *sortedAry = [ary sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendString:@"OAuth "];
    bool isFirstItem = YES;
    for (NSString *item in sortedAry) {
        if (! isFirstItem ) {
            [str appendString:@","];
        }
        isFirstItem = NO;
        [str appendString:item];
    }
    return str;
}

- (NSString *)calcSignature:(NSURLRequest *)request parameters:(NSDictionary *)parameters {
    NSString *clientSecret = _client.secret;
    NSString *tokenSecret  = (_token == nil) ? @"" : _token.secret;
    
    NSString *key = [NSString stringWithFormat:@"%@&%@", clientSecret, tokenSecret];
    
    NSString *httpMethod    = [request HTTPMethod];
    NSString *baseURI       = [[[[request URL] absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
    NSString *baseStringURI = [self percentEscape:baseURI];
    
    NSString *sigBaseStr = [self percentEscape:[self buildSignalNormalizedParameter:parameters]];
    NSString *text = [NSString stringWithFormat:@"%@&%@&%@",
                      httpMethod,
                      baseStringURI,
                      sigBaseStr];
    return [self signByCCHmacAlgSHA1:key text:text];
}

// OAuthパラメータを構築
- (NSMutableDictionary *)prepareParameters:(NSURLRequest *)req {
    NSMutableDictionary *params   = [[NSMutableDictionary alloc] initWithDictionary:_queryParams];
    if (_oauthParams != nil) {
        [params addEntriesFromDictionary:_oauthParams];
    }
    
    params[kOAuthConsumerKey]     = _client.token;
    if (_token != nil) {
        params[kOAuthToken] = _token.token;
    }
    params[kOAuthSignatureMethod] = @"HMAC-SHA1";
    params[kOAuthTimestamp]       = [[NSNumber numberWithInteger:floorf([[NSDate date] timeIntervalSince1970])] stringValue];
    params[kOAuthNonce]           = [self createNonce];
    params[kOAuthVersion]         = @"1.0";
    params[kOAuthSignature]       = [self calcSignature:req parameters:params];
    
    return params;
}

#pragma mark - Public methods
- (NSURLRequest *)preparedURLRequest {
    NSMutableURLRequest *request = nil;
    NSString *queryString = [self buildSignalNormalizedParameter:_queryParams];
    
    if (_httpMethod == WFOAuthHttpPOST) {
        request = [[NSMutableURLRequest alloc] initWithURL:_endpoint];
        [request addValue:@"application/x-www-form-urlencoded"forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    } else if (_httpMethod == WFOAuthHttpGET) {
        NSString *urlStr = [NSString stringWithFormat:@"%@?%@", [_endpoint absoluteString], queryString];
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    } else {
        return nil;
    }
    request.HTTPShouldHandleCookies = NO;
    request.HTTPMethod = [self getHttpMethod:_httpMethod];
    
    // Authorization header
    NSDictionary *params = [self prepareParameters:request];
    NSString *authContent = [self buildAuthorizationHeaderContent:params];
    [request addValue:authContent forHTTPHeaderField:@"Authorization"];
    
    return request;
}
@end
