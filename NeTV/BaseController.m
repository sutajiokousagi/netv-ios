//
//  BaseController.m
//  NeTV
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <netdb.h>

#import "BaseController.h"
#import "UIDevice-Hardware.h"
#import "VTPG_Common.h"
#import "XMLReader.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "UIImage+Resize.h"


#define DEFAULTPORT             8082
#define MULTICASTGROUP          @"225.0.0.37"
#define DEFAULTIP               @"192.168.100.1"

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
    if (self.commService == nil) {
        self.commService = [[CommService alloc] initWithDelegate:self];
        NSLog(@"commService object created");
    }
    
    //Observe app terminate event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{   
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Delete the commService
    NSLog(@"commService object released");
    if (self.commService != nil)
        [self.commService release];
    self.commService = nil;
    
    //Unregister app enter background event
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:[UIApplication sharedApplication]];

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


#pragma mark - UI Helpers

- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}



#pragma mark - UI Events

-(IBAction)onNavbarBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    NSLog(@"applicationDidEnterBackground in BaseController");
}



#pragma mark - User Preferences

- (void)setDeviceIP:(NSString*)newIP
{
    if (newIP == nil)   [prefs setValue:@"" forKey:PREFS_IP_ADDRESS];
    else                [prefs setValue:newIP forKey:PREFS_IP_ADDRESS];
}

- (NSString *)getDeviceIP
{
    return [prefs stringForKey:PREFS_IP_ADDRESS];
}


#pragma mark - Reachability

-(BOOL)isReachableWifi
{
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi);
}



#pragma mark - XML

- (NSDictionary*)convertXMLResponseToNSDictionary:(NSString*)xmlString
{
    //Convert the UDP data to an NSString
    NSDictionary* tempParsedDict = [XMLReader dictionaryForXMLString:xmlString error:nil];
        
    //Sanity check
    if ([tempParsedDict objectForKey:@"xml"] == nil)
        return nil;
    if ( ! [[tempParsedDict objectForKey:@"xml"] isKindOfClass:[NSDictionary class]])
        return nil;
    NSDictionary* rootDictionary = (NSDictionary*)[tempParsedDict objectForKey:@"xml"];
    
    //Extract status string
    NSString *statusString = [[rootDictionary objectForKey:@"status"] objectForKey:@"text"];
    if (statusString == nil)
        return nil;
    
    //Extract command string
    NSString *commandString = [[rootDictionary objectForKey:@"cmd"] objectForKey:@"text"];
    if (commandString == nil)
        return nil;
    commandString = [commandString uppercaseString];
        
    //Clean up received data into a nice dictionary
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:7];
    for (NSString *key in [rootDictionary objectForKey:@"data"])
    {
        id value = [[rootDictionary objectForKey:@"data"] objectForKey:key];
        if (![value isKindOfClass:[NSDictionary class]])
            continue;
        id text = [(NSDictionary*)value objectForKey:@"text"];
        if (text == nil)
            continue;
        [dict setObject:text forKey:key];
    }
    
    [dict setObject:statusString forKey:@"status"];
    [dict setObject:commandString forKey:@"cmd"];
    return dict;
}



#pragma mark - Basic UDP support

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


#pragma mark - UDP API

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

- (void)sendMultitabCommandUDP:(NSString*)ip tabIndex:(int)tabIndex options:(NSString*)option param:(NSString*)param
{
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",tabIndex], @"tab", option, @"options", param, @"param", nil];
    [self sendUDPCommandParams:@"Multitab" withParams:parameters toIP:ip andTag:MULTITAB_TAG];
}

- (void)sendMultitabScrollF:(NSString*)ip tabIndex:(int)tabIndex scrollfX:(float)x scrollfY:(float)y
{
    NSString *param = [NSString stringWithFormat:@"%f,%f", x, y];
    [self sendMultitabCommandUDP:ip tabIndex:tabIndex options:@"scrollf" param:param];
}

- (void)sendMultitabScroll:(NSString*)ip tabIndex:(int)tabIndex scrollX:(int)x scrollY:(int)y
{
    NSString *param = [NSString stringWithFormat:@"%d,%d", x, y];
    [self sendMultitabCommandUDP:ip tabIndex:tabIndex options:@"scroll" param:param];
}



#pragma mark - Basic HTTP support

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

- (void)sendSimpleHTTPCommand:(NSString*)ip command:(NSString*)command value:(NSString*)value
{
    NSString * targetIP = ip;
    if (targetIP == nil || [targetIP length] < 1)
        targetIP = [self getDeviceIP];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/bridge", targetIP]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:command forKey:@"cmd"];
    [request setPostValue:value forKey:@"value"];
    [request setDelegate:self];
    
    //To differentiate the delegates later on
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:command, @"cmd", value, @"value", nil];
    [request setUserInfo:userInfo];
    
    [request startAsynchronous];
}

- (void)sendComplexHTTPCommand:(NSString*)ip command:(NSString*)command parameters:(NSDictionary*)parameters
{
    NSString * targetIP = ip;
    if (targetIP == nil || [targetIP length] < 1)
        targetIP = [self getDeviceIP];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/bridge", targetIP]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:command forKey:@"cmd"];
    [request setDelegate:self];
    
    for (NSString* key in parameters)
    {
        id value = [parameters objectForKey:key];
        if ([value isKindOfClass:[NSString class]])
            [request setPostValue:(NSString*)value forKey:key];
    }

    //To differentiate the delegates later on
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [userInfo setObject:command forKey:@"cmd"];
    [request setUserInfo:userInfo];

    [request startAsynchronous];
}

#pragma mark - HTTP API

- (void)sendUnlinkCommand:(NSString*)ip path:(NSString*)path
{
    [self sendSimpleHTTPCommand:ip command:@"UnlinkFile" value:path];
}

- (void)sendMultitabCommand:(NSString*)ip tabIndex:(int)tabIndex options:(NSString*)option param:(NSString*)param
{
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",tabIndex], @"tab", option, @"options", param, @"param", nil];
    [self sendComplexHTTPCommand:ip command:@"Multitab" parameters:parameters];
}

- (void)sendMultitabImageCommand:(NSString*)ip tabIndex:(int)tabIndex remotePath:(NSString*)remotePath
{
    /*
    NSString* html = [NSString stringWithFormat:@"<html><script type='text/javascript'>function load() { center_img.height = window.innerHeight; }</script><body style='margin:0; overflow:hidden;' onLoad='load()' onresize='load()'><table width='100%' height='100%' cell-padding='0' cell-spacing='0'><tr><td width='100%' height='100%' align='center' valign='middle'><img id='center_img' height='window.innerHeight' src='%@' /></tr></td></table></body></html>", remotePath];
    [self sendMultitabCommand:ip tabIndex:tabIndex options:@"html" param:html];
     */
    [self sendMultitabCommand:ip tabIndex:tabIndex options:@"image" param:remotePath];
}

- (void)sendMultitabCloseAll:(NSString*)ip
{
    [self sendMultitabCommand:ip tabIndex:0 options:@"closeall" param:@"dontcare"];
}

- (int)uploadPhoto:(NSString*)ip withPath:(NSString*)path media:(NSDictionary*)mediaInfo
{
    //Ignore video
    if ([mediaInfo objectForKey:@"video"] != nil && [[mediaInfo objectForKey:@"video"] isKindOfClass:[NSURL class]])
        return 1;

    //Not photo
    UIImage* image = [mediaInfo objectForKey:UIImagePickerControllerOriginalImage];
    if (image == nil)
        return 2;
           
    //Using private extensions to resize image properly
    //Convert UIImage to JPEG (quality 0.9) and then to NSData object
    CGSize newSize = CGSizeMake(1280,720);
    UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:newSize interpolationQuality:kCGInterpolationHigh];        
    NSData *dataObj = UIImageJPEGRepresentation(resizedImage, 0.9);        //autorelease
    
    //Construct the HTTP request
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/bridge", ip]]];
    [request setData:dataObj withFileName:@"filedata" andContentType:@"image/jpeg" forKey:@"filedata"];
    
    //Extra parameters
    [request setPostValue:@"UploadFile" forKey:@"cmd"];
    [request setPostValue:path forKey:@"path"];
    
    //HTTP request parameters
    [request setShouldContinueWhenAppEntersBackground:NO];
    [request setShowAccurateProgress:YES];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request startAsynchronous];
    return 0;
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



#pragma mark - ASIHTTPRequest delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //[self handleResponseData: [request responseData]];
    NSLog(@"Finish: %@", [request responseString]);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	//[self failWithError:[request error]];
    NSLog(@"Failed: %@", [request responseString]);
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    if (bytes <= 0)
        return;
    static long long accumulate_bytes = 0;
    accumulate_bytes += bytes;
    NSLog(@"Progress: %lldKB", accumulate_bytes / 1024);
}

- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength
{
    if (newLength >= 0)
        NSLog(@"Progress: %lldKB", newLength / 1024);    
}

- (void)queueComplete:(ASINetworkQueue *)queue
{
    //[self handleResponseData:nil];
}


@end
