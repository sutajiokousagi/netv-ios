//
//  BaseController.h
//  NeTV
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"
#import "CommService.h"
#import "XMLReader.h"
#import "ASIHTTPRequest.h"

@interface BaseController : UIViewController <AsyncUdpSocketDelegate>
{

}

@property (nonatomic, copy) NSString* appVersion;

//SharedPreferences


//Reachability
- (BOOL)isReachableWifi;

//UDP
- (void)sendHandshake;
- (void)sendNetworkConfig;
- (void)sendWifiScan;
- (void)sendRemoteControl:(NSString*)buttonName;
- (void)sendUDPCommandSimple:(NSString*)commandName withValue:(NSString*)value toIP:(NSString*)toIP andTag:(int)tag;
- (void)sendUDPCommandParams:(NSString*)commandName withParams:(NSDictionary*)params toIP:(NSString*)toIP andTag:(int)tag;
- (void)sendUDPCommandParamsBroadcast:(NSString*)commandName withParams:(NSDictionary*)params andTag:(int)tag;

//HTTP
- (NSString*)getGUIDDeviceName:(NSString*)guid;

@end
