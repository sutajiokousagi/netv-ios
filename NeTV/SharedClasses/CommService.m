//
//  CommService.m
//  NeTV
//
//  Created by Sidwyn Koh on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommService.h"
#import "VTPG_Common.h"
#define DEFAULTPORT         8082
#define MULTICASTGROUP     @"225.0.0.37"
#define DEFAULTIP          @"192.168.100.1"
#define WIFISETTINGS_MSG    0

@implementation CommService
@synthesize asyncSocket;

- (id)init
{
    self = [super init];
    if (self) {
        asyncSocket = [[AsyncUdpSocket alloc]initWithDelegate:self];
        [asyncSocket connectToHost:DEFAULTIP onPort:DEFAULTPORT error:nil];
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDelegate:(id)theClass
{
    self = [super init];
    if (self) {
        asyncSocket = [[AsyncUdpSocket alloc]initWithDelegate:theClass];
        NSError *e;
        [asyncSocket bindToPort:8082 error:&e];
        [asyncSocket connectToHost:@"192.168.100.1" onPort:8082 error:&e];

    
        
    }
    
    return self;
}

- (id)initWithDelegate:(id)theClass andIP:(NSString *)theIP{
    self = [super init];
    if (self) {
        asyncSocket = [[AsyncUdpSocket alloc]initWithDelegate:theClass];
        NSError *e;
  //      [asyncSocket bindToPort:8082 error:&e];
//        [asyncSocket connectToHost:@"192.168.100.1" onPort:8082 error:&e];
    
        [asyncSocket bindToAddress:theIP port:8082 error:&e];
        
        
    }
    
    return self;
}

- (void)sendUDPCommand:(NSString *)command andParameters:(NSDictionary *)parameterDictionary andTag:(long)theTag{
    [asyncSocket receiveWithTimeout:-1 tag:01];

    NSMutableString *overallString = [NSMutableString stringWithFormat:@"<xml><cmd>%@</cmd><data>",command];
    for (NSString *parameterName in [parameterDictionary allKeys]) {
        NSString *parameterValue = [parameterDictionary objectForKey:parameterName];
        [overallString appendFormat:@"<%@>%@</%@>",parameterName,parameterValue,parameterName];
    }
    [overallString appendString:@"</data></xml>"];
    
    NSLog(@"Sending this to 192.168.100.1 on port 8082 (METHOD 1): %@",overallString);
	NSData *wifiData = [overallString dataUsingEncoding:NSUTF8StringEncoding];
//	LOG_EXPR(wifiData);
    [asyncSocket sendData:wifiData toHost:@"192.168.100.1" port:8082 withTimeout:10 tag:theTag];
//    [asyncSocket receiveWithTimeout:10 tag:01];
}

- (void)sendUDPCommandWithBroadcast:(NSString *)command andParameters:(NSDictionary *)parameterDictionary andTag:(long)theTag{
    [asyncSocket receiveWithTimeout:-1 tag:01];
    NSError *e;
    
    [asyncSocket enableBroadcast:YES error:&e];

    NSMutableString *overallString = [NSMutableString stringWithFormat:@"<xml><cmd>%@</cmd><data>",command];
    for (NSString *parameterName in [parameterDictionary allKeys]) {
        NSString *parameterValue = [parameterDictionary objectForKey:parameterName];
        [overallString appendFormat:@"<%@>%@</%@>",parameterName,parameterValue,parameterName];
    }
    [overallString appendString:@"</data></xml>"];
    
    NSLog(@"Sending this to 255.255.255.255 on port 8082 (METHOD 2): %@",overallString);
	NSData *wifiData = [overallString dataUsingEncoding:NSUTF8StringEncoding];
    //	LOG_EXPR(wifiData);
    [asyncSocket sendData:wifiData toHost:@"255.255.255.255" port:8082 withTimeout:10 tag:theTag];

}

- (void)sendUDPCommand:(NSString *)command andParameters:(NSDictionary *)parameterDictionary andIP:(NSString *)theIP andTag:(long)theTag{
    [asyncSocket receiveWithTimeout:-1 tag:01];
    
    NSMutableString *overallString = [NSMutableString stringWithFormat:@"<xml><cmd>%@</cmd><data>",command];
    for (NSString *parameterName in [parameterDictionary allKeys]) {
        NSString *parameterValue = [parameterDictionary objectForKey:parameterName];
        [overallString appendFormat:@"<%@>%@</%@>",parameterName,parameterValue,parameterName];
    }
    [overallString appendString:@"</data></xml>"];
    
    NSLog(@"Sending this to IP %@ on port 8082: %@",theIP,overallString);
	NSData *wifiData = [overallString dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket sendData:wifiData toHost:theIP port:8082 withTimeout:10 tag:theTag];
}




@end
