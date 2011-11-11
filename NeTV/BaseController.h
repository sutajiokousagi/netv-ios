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

//UI Events
- (IBAction)onNavbarBack:(id)sender;

//SharedPreferences


//Reachability
- (BOOL)isReachableWifi;

//UDP
- (void)sendHandshake;
- (void)sendNetworkConfig: (NSString*)toIP;
- (void)sendWifiScan: (NSString*)toIP;
- (void)sendRemoteControl:(NSString*)buttonName toIP:(NSString*)toIP;
- (void)sendUDPCommandSimple:(NSString*)commandName withValue:(NSString*)value toIP:(NSString*)toIP andTag:(int)tag;
- (void)sendUDPCommandParams:(NSString*)commandName withParams:(NSDictionary*)params toIP:(NSString*)toIP andTag:(int)tag;
- (void)sendUDPCommandParamsBroadcast:(NSString*)commandName withParams:(NSDictionary*)params andTag:(int)tag;

//HTTP
- (NSString*)getGUIDDeviceName:(NSString*)guid;

@end