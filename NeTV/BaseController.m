//
//  BaseController.m
//  NeTV
//

#import "BaseController.h"
#import "UIDevice-Hardware.h"
#import "VTPG_Common.h"
#import "XMLReader.h"
#import "Reachability.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <netdb.h>

#define DEFAULTPORT         8082
#define MULTICASTGROUP      @"225.0.0.37"
#define DEFAULTIP           @"192.168.100.1"

#define UDP_TAG                 0
#define HELLO_TAG               1
#define WIFISCAN_TAG            2
#define REMOTECONTROL_TAG       5
#define UNLINKFILE_TAG          10
#define UPLOADFILE_TAG          11
#define MULTITAB_TAG            18

#define SETWIFI_MSG             51
#define GETWIFI_MSG             52

#define PREFS_IP_ADDRESS        @"ip_address"
#define PREFS_DEVICE_NAME       @"device_name"

// Private extension
@interface BaseController()
@property (nonatomic, retain) CommService *commService;
@property (nonatomic, retain) NSUserDefaults *prefs;
@end

@implementation BaseController

@synthesize appVersion;
@synthesize commService, prefs;

#pragma mark - Standard Initialization

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Get the version number
    self.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    //Clear background color
    self.view.backgroundColor = [UIColor clearColor];
    
    //Hide the default navbar
    self.navigationController.navigationBarHidden = YES;
    
    //SharePreferences
    self.prefs = [NSUserDefaults standardUserDefaults];
}

- (void)viewDidUnload
{
    self.commService = nil;
    self.prefs = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    //Init communication object
    if (self.commService == nil)
        self.commService = [[CommService alloc] initWithDelegate:self];

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{   
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"commService object for BaseController released");
    if (self.commService != nil)
        [self.commService release];
    self.commService = nil;

	[super viewWillDisappear:animated];    
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}



#pragma mark - UI Events

-(IBAction)onNavbarBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - Reachability

-(BOOL)isReachableWifi
{
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi);
}



#pragma mark - DataComm Utilites

- (void)sendHandshake
{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] platformString],@"type",
                             [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"version",                                                                 nil];
    [self sendUDPCommandParamsBroadcast:@"Hello" withParams:params andTag:HELLO_TAG];
}

- (void)sendWifiScan:(NSString*)toIP
{
    [self sendUDPCommandSimple:@"WifiScan" withValue:nil toIP:toIP andTag:WIFISCAN_TAG];
}

- (void)sendRemoteControl:(NSString*)buttonName toIP:(NSString*)toIP
{
    [self sendUDPCommandSimple:@"RemoteControl" withValue:buttonName toIP:toIP andTag:REMOTECONTROL_TAG];
}

- (void)sendNetworkConfig:(NSString*)toIP
{
    /*
    NSString *selectedIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedHomeNetworkIndex"];
    NSDictionary *selectedNetworkDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:@"homeNetworkArray"] objectAtIndex:[selectedIndex intValue]];
    NSString *networkAuth = [[selectedNetworkDictionary objectForKey:@"auth"] objectForKey:@"text"];
    NSString *networkEncryption = [[selectedNetworkDictionary objectForKey:@"encryption"] objectForKey:@"text"];
    
    [self.commService sendUDPCommand:@"SetNetwork" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          SSIDName.text, @"wifi_ssid",
                                                          networkEncryption,@"wifi_encryption",
                                                          networkAuth,@"wifi_authentication",
                                                          SSIDPassword.text, @"wifi_password",
                                                          nil] andTag:SETWIFI_MSG];
    //NeTV wil change to Access Point mode after 500ms
    //iPhone disconnects and revert to home network
     */
}

- (void)sendUDPCommandSimple:(NSString*)commandName withValue:(NSString*)value toIP:(NSString*)toIP andTag:(int)tag
{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:value, @"value", nil];
    
    [self sendUDPCommandParams:commandName withParams:params toIP:toIP andTag:tag];
}

- (void)sendUDPCommandParams:(NSString*)commandName withParams:(NSDictionary*)params toIP:(NSString*)toIP andTag:(int)tag
{
    if (self.commService == nil)    
        self.commService = [[CommService alloc] initWithDelegate:self];
    
    NSString * targetIP = toIP;
    if (targetIP == nil)
        targetIP = [prefs stringForKey:PREFS_IP_ADDRESS];
    
    [self.commService sendUDPCommand:commandName
                       andParameters:params
                               andIP:targetIP
                              andTag:tag];
}

- (void)sendUDPCommandParamsBroadcast:(NSString*)commandName withParams:(NSDictionary*)params andTag:(int)tag
{
    if (self.commService == nil)
        self.commService = [[CommService alloc] initWithDelegate:self];
    
    [self.commService sendUDPCommandWithBroadcast:commandName
                       andParameters:params
                              andTag:tag];
}

- (NSString*)getGUIDDeviceName:(NSString*)guid
{
    NSString * urlString = [NSString stringWithFormat:@"http://www.chumby.com/xapis/device/authorize/%@", guid];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startSynchronous];
    
    NSError * error = [request error];
    if (error)
        return nil;
    NSString * responseString = [request responseString];
    NSRange unauthRange = [responseString rangeOfString:@"unauthorized" options: NSCaseInsensitiveSearch];
    if (unauthRange.location > 0 && unauthRange.length > 0)
        return nil;
    
    NSRange range1 = [responseString rangeOfString:@"<name>" options: NSCaseInsensitiveSearch];
    NSRange range2 = [responseString rangeOfString:@"</name>" options: NSCaseInsensitiveSearch];
    if (range1.location <= 0 || range2.location <= 0)
        return nil;
    return [responseString substringWithRange:NSMakeRange(range1.location+6, range2.location-range1.location-6)];
}



#pragma mark - AsyncUdpSocket delegate

//Received data on UDP socket
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)addressString port:(UInt16)port
{
    //Convert the UDP data to an NSString
    NSString *udpDataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSDictionary* tempParsedDict = [XMLReader dictionaryForXMLString:udpDataString error:nil];
    
    //Ignore loopback (restart receiving & return)
    addressString = [addressString stringByReplacingOccurrencesOfString:@"::ffff:" withString:@""];
    NSString* myIP = [CommService getLocalIPAddress];
    if (myIP != nil && myIP.length > 5 && [myIP isEqualToString:addressString])
        return [sock receiveWithTimeout:-1 tag:1];
    
    //Sanity check (restart receiving & return)
    if ([tempParsedDict objectForKey:@"xml"] == nil)
        return [sock receiveWithTimeout:-1 tag:1];;
    if ( ! [[tempParsedDict objectForKey:@"xml"] isKindOfClass:[NSDictionary class]])
        return [sock receiveWithTimeout:-1 tag:1];
    NSDictionary* rootDictionary = (NSDictionary*)[tempParsedDict objectForKey:@"xml"];
    if ([rootDictionary objectForKey:@"cmd"] == nil)
        return [sock receiveWithTimeout:-1 tag:1];
    NSString *commandString = [[rootDictionary objectForKey:@"cmd"] objectForKey:@"text"];
    if (commandString == nil)
        return [sock receiveWithTimeout:-1 tag:1];
    commandString = [commandString uppercaseString];

    //To be override by subclass

    //Return YES if we didn't ignore the packet
    return YES;
}

//Listening timeout
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    //To be override by subclass
}

//Sending Timeout
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    //To be override by subclass
}

@end
