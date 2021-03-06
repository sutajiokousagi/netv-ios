/*
 
 File: BaseController.h
 Abstract: An UIViewController subclass to handle all neccessary UDP & HTTP API used by the app.
 
 For full documentation and source code, please visit: http://wiki.chumby.com/index.php/NeTV_developer_info
 */

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"
#import "CommService.h"
#import "XMLReader.h"
#import "ASIHTTPRequest.h"

@interface BaseController : UIViewController <AsyncUdpSocketDelegate, ASIHTTPRequestDelegate>
{

}

@property (nonatomic, copy) NSString* appVersion;

//UI Helpers
- (void)showAlert:(NSString *)title message:(NSString *)message;

//UI Events
- (IBAction)onNavbarBack:(id)sender;
- (void)applicationDidEnterBackground:(NSNotification *)notification;

//UserPreferences
- (void)setDeviceIP:(NSString*)newIP;
- (NSString *)getDeviceIP;

//Reachability
- (BOOL)isReachableWifi;

//XML
- (NSDictionary*)convertXMLResponseToNSDictionary:(NSString*)xmlString;

//Basic UDP support
- (void)sendUDPCommandSimple:(NSString*)commandName withValue:(NSString*)value toIP:(NSString*)toIP andTag:(int)tag;
- (void)sendUDPCommandParams:(NSString*)commandName withParams:(NSDictionary*)params toIP:(NSString*)toIP andTag:(int)tag;
- (void)sendUDPCommandParamsBroadcast:(NSString*)commandName withParams:(NSDictionary*)params andTag:(int)tag;

//UDP API
- (void)sendHandshake;
- (void)sendNetworkConfig:(NSString*)toIP;
- (void)sendWifiScan:(NSString*)toIP;
- (void)sendRemoteControl:(NSString*)buttonName toIP:(NSString*)toIP;
- (void)sendMultitabCommandUDP:(NSString*)ip tabIndex:(int)tabIndex options:(NSString*)option param:(NSString*)param;
- (void)sendMultitabScrollF:(NSString*)ip tabIndex:(int)tabIndex scrollfX:(float)x scrollfY:(float)y;
- (void)sendMultitabScroll:(NSString*)ip tabIndex:(int)tabIndex scrollX:(int)x scrollY:(int)y;

//Basic HTTP support
- (NSString*)getGUIDDeviceName:(NSString*)guid;
- (void)sendSimpleHTTPCommand:(NSString*)ip command:(NSString*)command value:(NSString*)value;
- (void)sendComplexHTTPCommand:(NSString*)ip command:(NSString*)command parameters:(NSDictionary*)parameters;

//HTTP API
- (void)sendUnlinkCommand:(NSString*)ip path:(NSString*)path;
- (void)sendMultitabCommand:(NSString*)ip tabIndex:(int)tabIndex options:(NSString*)option param:(NSString*)param;
- (void)sendMultitabImageCommand:(NSString*)ip tabIndex:(int)tabIndex remotePath:(NSString*)remotePath;
- (void)sendMultitabCloseAll:(NSString*)ip;
- (int)uploadPhoto:(NSString*)ip withPath:(NSString*)path media:(NSDictionary*)media;

@end
