//
//  TwitterStreamingConnector.m
//  WFSocialListener
//
//  Created by akihiro uehara on 2013/03/07.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFTwitterStreamConnector.h"

typedef enum streamParseStatus {
    lookingForDelimiter_r   = 0,
    lookingForDelimiter_n,
    receivingData
} streamParserStatusType;

@interface WFTwitterStreamConnector() {
    __weak NSObject<WFTwitterStreamDelegate> *_delegate;
    WFConnector *_wfConnector;
    NSURLConnection *_connection;
    
    streamParserStatusType _parserStatus;
    int _expectedLength;
    int _receivedLength;
    NSMutableData *_receivedData;
}
@end

@implementation WFTwitterStreamConnector
#pragma mark - Constructor
- (id)initWithDelegate:(NSObject<WFTwitterStreamDelegate> *)delegate account:(WFAccount *)a endpoint:(NSString *)e parameters:(NSDictionary *)p {
    self = [super init];
    if (self) {
        _delegate   = delegate;
        _wfConnector = [[WFConnector alloc] initWithAccount:a endpoint:e parameters:p];
        _receivedData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self cancel];
}
#pragma mark - Private methods
- (void)parseReceivedData {
    id jsonData = [NSJSONSerialization JSONObjectWithData:_receivedData options:0 error:nil];
    [_delegate didReceivedJSONData:self jsonData:jsonData];
    [_receivedData setLength:0];
//DLog(@"%s %@", __func__, jsonData);
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//DLog(@"%s", __func__);
    _connection = nil;
    [_delegate didStreamDisconnected:self error:error];
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//DLog(@"%s", __func__);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode != 200) {
        [_delegate didReceivedErrorHttpResponse:self httpResponse:httpResponse];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
//DLog(@"%s", __func__);
    NSUInteger index = 0;
    const NSUInteger length = [d length];
    Byte *data = (Byte *)d.bytes;
    
    int i;
    while (index < length) {
        switch (_parserStatus) {
            case lookingForDelimiter_r:
                if(_receivedData.length > 0) {
                    [self parseReceivedData];
                }
                for (; index < length && data[index] != '\r'; index++);
                if (data[index] == '\r') {
                    _parserStatus = lookingForDelimiter_n;
                }
                break;
                
            case lookingForDelimiter_n:
                if (data[index++] == '\n') {
                    _parserStatus = receivingData;
                }
                break;
                
            case receivingData:
                i = index;
                for (i = index; i < length && data[i] != '\r'; i++);
                if(data[i] == '\r') {
                    _parserStatus = lookingForDelimiter_r;
                }
                [_receivedData appendBytes:&data[index] length:(i -index)];
                index = i;
                break;
            default:
                _parserStatus = lookingForDelimiter_r;
                break;
        }
    };
}


#pragma mark - Public methods
- (void)start {
    NSURLRequest *req = [_wfConnector prepareURLRequest:nil];
    _connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    [_connection start];
}

- (void)cancel {
    [_connection cancel];
    _connection = nil;
}
@end
