//
//  CommService.m
//  NeTV
//

#import "CommService.h"
#import "VTPG_Common.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

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
    }
    
    return self;
}

- (id)initWithDelegate:(id)theClass andIP:(NSString *)theIP{
    self = [super init];
    if (self) {
        asyncSocket = [[AsyncUdpSocket alloc]initWithDelegate:theClass];
        NSError *e;
        [asyncSocket bindToPort:8082 error:&e];
//      [asyncSocket bindToAddress:theIP port:8082 error:&e];
    }
    
    return self;
}

- (void)dealloc
{
    //Important!!
    asyncSocket.delegate = nil;
    
    [super dealloc];
}

- (void)sendUDPCommand:(NSString *)command andParameters:(NSDictionary *)parameterDictionary andTag:(long)theTag
{
    [asyncSocket receiveWithTimeout:-1 tag:01];

    NSMutableString *overallString = [NSMutableString stringWithFormat:@"<xml><cmd>%@</cmd><data>",command];
    for (NSString *parameterName in [parameterDictionary allKeys]) {
        NSString *parameterValue = [parameterDictionary objectForKey:parameterName];
        [overallString appendFormat:@"<%@>%@</%@>",parameterName,parameterValue,parameterName];
    }
    [overallString appendString:@"</data></xml>"];
    
    //NSLog(@"Sending this to 192.168.100.1 on port 8082 (METHOD 1): %@",overallString);
    
	NSData *wifiData = [overallString dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket sendData:wifiData toHost:@"192.168.100.1" port:8082 withTimeout:10 tag:theTag];
}

- (void)sendUDPCommandWithBroadcast:(NSString *)command andParameters:(NSDictionary *)parameterDictionary andTag:(long)theTag
{
    [asyncSocket receiveWithTimeout:-1 tag:01];
    NSError *e;
    
    [asyncSocket enableBroadcast:YES error:&e];

    NSMutableString *overallString = [NSMutableString stringWithFormat:@"<xml><cmd>%@</cmd><data>",command];
    for (NSString *parameterName in [parameterDictionary allKeys]) {
        NSString *parameterValue = [parameterDictionary objectForKey:parameterName];
        [overallString appendFormat:@"<%@>%@</%@>",parameterName,parameterValue,parameterName];
    }
    [overallString appendString:@"</data></xml>"];
    
    //NSLog(@"Sending this to 255.255.255.255 on port 8082 (METHOD 2): %@", overallString);

	NSData *wifiData = [overallString dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket sendData:wifiData toHost:@"255.255.255.255" port:8082 withTimeout:10 tag:theTag];

}

- (void)sendUDPCommand:(NSString *)command andParameters:(NSDictionary *)parameterDictionary andIP:(NSString *)theIP andTag:(long)theTag
{
    [asyncSocket receiveWithTimeout:-1 tag:01];
    
    NSMutableString *overallString = [NSMutableString stringWithFormat:@"<xml><cmd>%@</cmd><data>",command];
    for (NSString *parameterName in [parameterDictionary allKeys]) {
        NSString *parameterValue = [parameterDictionary objectForKey:parameterName];
        [overallString appendFormat:@"<%@>%@</%@>",parameterName,parameterValue,parameterName];
    }
    [overallString appendString:@"</data></xml>"];
    
    //NSLog(@"Sending this to IP %@ on port 8082: %@",theIP,overallString);
    
	NSData *wifiData = [overallString dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket sendData:wifiData toHost:theIP port:8082 withTimeout:10 tag:theTag];
}


+ (NSString *)getLocalIPAddress
{
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];               
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
} 

@end
