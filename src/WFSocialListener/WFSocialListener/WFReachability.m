//
//  Reachability.m
//  WFSocialListener
//
//  Created by akihiro uehara on 2013/03/06.
//  Copyright (c) 2013 Akihiro Uehara. All rights reserved.
//

#import "WFReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

@interface WFReachability() {
	SCNetworkReachabilityRef _inetReachabilityRef;
    SCNetworkReachabilityRef _wifiReachabilityRef;
}

@property (nonatomic) NetworkStatus status;
@property (nonatomic) BOOL isWatching;
@end

@implementation WFReachability
static WFReachability *_inst;
+(WFReachability *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inst = [[WFReachability alloc] init];
    });
    return _inst;
}
#pragma - mark Constructor
- (void)dealloc {
    [self stop];
}
#pragma - mark Callback
static void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
    WFReachability *inst = (__bridge WFReachability *)info;
    [inst updateWithFlag:flags];
}

#pragma mark - Private methods
- (BOOL)startWatchingForInetReachablity {
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    _inetReachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    
    // register a callback function
    BOOL retVal = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	if (SCNetworkReachabilitySetCallback(_inetReachabilityRef,reachabilityCallback, &context)) {
		if (SCNetworkReachabilityScheduleWithRunLoop(_inetReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)){
			retVal = YES;
		}
	}

    return retVal;
}
- (BOOL)startWatchingForWiFiReachablity {
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;
	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    _wifiReachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&localWifiAddress);

    // register a callback function
    BOOL retVal = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	if (SCNetworkReachabilitySetCallback(_wifiReachabilityRef, reachabilityCallback, &context)) {
		if (SCNetworkReachabilityScheduleWithRunLoop(_wifiReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))	{
			retVal = YES;
		}
	}
    
    return retVal;
}

- (void)updateWithFlag:(SCNetworkReachabilityFlags) flags {
    NetworkStatus s = NotReachable;
    if ((flags & kSCNetworkReachabilityFlagsReachable) != 0) {
        if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
            // if target host is reachable and no connection is required
            //  then we'll assume (for now) that your on Wi-Fi
            s = WiFiReachable;
        }
        
        if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
        {
            // ... and the connection is on-demand (or on-traffic) if the
            //     calling application is using the CFSocketStream or higher APIs
            if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
            {
                // ... and no [user] intervention is needed
                s = WiFiReachable;
            }
        }
        
        if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
        {
            // ... but WWAN connections are OK if the calling application
            //     is using the CFNetwork (CFSocketStream?) APIs.
            s = WWANReachable;
        }
    }
    
    if (self.status != s) {
        self.status = s;
    }

}
#pragma mark - Public methods
- (void)start
{
    if (self.isWatching) return;
    
    [self startWatchingForInetReachablity];
    [self startWatchingForWiFiReachablity];

    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_wifiReachabilityRef, &flags)) {
        [self updateWithFlag:flags];
    }
    if (SCNetworkReachabilityGetFlags(_inetReachabilityRef, &flags)) {
        [self updateWithFlag:flags];
    }

    self.isWatching = YES;
}

- (void)stop {
    if (! self.isWatching ) return;
    
	if (_inetReachabilityRef != NULL) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_inetReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		CFRelease(_inetReachabilityRef);
        _inetReachabilityRef = NULL;
	}
    if (_wifiReachabilityRef != NULL) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_wifiReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(_wifiReachabilityRef);
        _wifiReachabilityRef = NULL;
    }
    
    self.isWatching = NO;
}

@end