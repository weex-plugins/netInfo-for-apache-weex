/**
 * Created by Weex.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the Apache Licence 2.0.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import <SystemConfiguration/SystemConfiguration.h>
#import "WXNetInfoModule.h"

static NSString *const WXReachabilityStateUnknown = @"unknown";
static NSString *const WXReachabilityStateNone = @"none";
static NSString *const WXReachabilityStateWifi = @"wifi";
static NSString *const WXReachabilityStateCell = @"cell";

@interface WXNetInfoModule()

@property(nonatomic,copy)WXModuleKeepAliveCallback monitorCallBack;

@end

@implementation WXNetInfoModule
{
    SCNetworkReachabilityRef _reachability;
    NSString *_status;
    NSString *_host;
}

WX_EXPORT_METHOD(@selector(fetch:callback:))
WX_EXPORT_METHOD(@selector(startMonitor:callback:))
WX_EXPORT_METHOD(@selector(stopMonitor:))

#pragma mark -
#pragma mark api
- (void)fetch:(NSDictionary *)options callback:(WXModuleCallback)callback
{
    NSString *status = [self currentReachabilityStatus:options];
    callback(@{ @"result": @"success", @"status": status });
}

- (void)startMonitor:(NSDictionary *)options callback:(WXModuleKeepAliveCallback)callback
{
    _host = [options objectForKey:@"url"];
//    WXAssertParam(_host);
//    WXAssert(![_host hasPrefix:@"http"], @"Host value should just contain the domain, not the URL scheme.");
    _status = WXReachabilityStateUnknown;
    _reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, _host.UTF8String ?: "apple.com");
    SCNetworkReachabilityContext context = { 0, ( __bridge void *)self, NULL, NULL, NULL };
    SCNetworkReachabilitySetCallback(_reachability, WXReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(_reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    self.monitorCallBack = callback;
}

- (void)stopMonitor:(WXModuleCallback)callback
{
    if (_reachability) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        CFRelease(_reachability);
    }
    NSDictionary *result = @{ @"result": @"success", @"data": @"stop" };
    callback(result);
}
#pragma mark -
#pragma mark method
static void WXReachabilityCallback(__unused SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
    WXNetInfoModule *self = (__bridge id)info;
    
    NSString *status = [self getNetStatus:flags];
    if (![status isEqualToString:self->_status]) {
        self->_status = status;
        NSDictionary *result = @{ @"result": @"success", @"status": self->_status };
        [self sendMonitorInfo:result];
    }
}

- (NSString *)getNetStatus:(SCNetworkReachabilityFlags)flags
{
    NSString *status = WXReachabilityStateUnknown;
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0 ||
        (flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0) {
        status = WXReachabilityStateNone;
    }
#if TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = WXReachabilityStateCell;
    }
#endif
    else {
        status = WXReachabilityStateWifi;
    }
    return status;
}

-(void)sendMonitorInfo:(NSDictionary *)info
{
    self.monitorCallBack(info,true);
}

- (NSString *)currentReachabilityStatus:(NSDictionary *)options
{
    _host = [options objectForKey:@"url"];
//    WXAssertParam(_host);
//    WXAssert(![_host hasPrefix:@"http"], @"Host value should just contain the domain, not the URL scheme.");
    _status = WXReachabilityStateUnknown;
    _reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, _host.UTF8String ?: "apple.com");
    NSAssert(_reachability != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    SCNetworkReachabilityFlags flags;
    NSString *status = WXReachabilityStateUnknown;
    
    if (SCNetworkReachabilityGetFlags(_reachability, &flags))
    {
        status = [self getNetStatus:flags];
    }
    return status;
}
@end
