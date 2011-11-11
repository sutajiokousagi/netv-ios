//
//  NeTVViewController.m
//  NeTV
//
//  Created by Sidwyn Koh on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NeTVViewController.h"
#import "RemoteController.h"
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

#define HELLO_MSG           01
#define HELLOSPAM_MSG       02

#define SETWIFI_MSG         11
#define GETWIFI_MSG         12

// Private extension
@interface NeTVViewController()
- (NSString *)addressHost4:(struct sockaddr_in *)pSockaddr4;
- (NSString *)addressHost6:(struct sockaddr_in6 *)pSockaddr6;
- (NSString *)addressHost:(struct sockaddr *)pSockaddr;
@end

@implementation NeTVViewController

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
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSLog(@"Version %@", versionStr);
    lblVersion.text = versionStr;
    
    //Clear background color
    self.view.backgroundColor = [UIColor clearColor];
    
    //Hide the default navbar
    self.navigationController.navigationBarHidden = YES;
    
    //Hide the custom navbar back button
    btnNavbarBack.alpha = 0;
        
    //Setup SearchResultTableView
    if (chooseIPController == nil)
    {      
        CGRect chooseIPRect;
        chooseIPRect.origin.x = 0;
        chooseIPRect.origin.y = - self.view.frame.size.height;
        chooseIPRect.size.width = self.view.frame.size.width;
        chooseIPRect.size.height = self.view.frame.size.height - imgNavbar.frame.size.height;
        
        //Add to current view, hidden away
        chooseIPController = [[ChooseIPController alloc] initWithNibName:@"ChooseIPController" bundle:[NSBundle mainBundle]];
        [chooseIPController.view setFrame:chooseIPRect];
        [self.view insertSubview:chooseIPController.view belowSubview:imgNavbar];
        chooseIPController.delegate = self;
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    //Init communication object (should be a singleton class to be correct)
    NSLog(@"mainComm object for NeTVViewController created");
    if (mainComm == nil)
        mainComm = [[CommService alloc] initWithDelegate:self];
	
	//Bonjour stuff
    if (_services == nil)
        _services = [[NSMutableArray alloc] init];
    [self searchForServicesOfType:@"_netv._tcp." inDomain:@""];
    
    //Rescan
    [self reset];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{   
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"mainComm object for NeTVViewController released");
    if (mainComm != nil)
        [mainComm release];
    mainComm = nil;

	[super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
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


#pragma mark - Initialization

- (void)reset
{
    _checkedReachability = NO;
    _retryCounter = 0;
    _sentHandshake = NO;
    _receiveHandshake = NO;
    _hasMoreHandshake = NO;

    if (_ipListForUI == nil)
        _ipListForUI = [[NSMutableArray alloc] init];
    [_ipListForUI removeAllObjects];
    
    if (_deviceList == nil)
        _deviceList = [[NSMutableDictionary alloc] initWithCapacity:10];
//    [_deviceList removeAllObjects];
    
    [self initializeSequence];
}



#pragma mark - UI Events

-(IBAction)onNavbarBack:(id)sender
{
    [self hideDeviceList];
    [self reset];
}



#pragma mark - Helpers

- (void)showDeviceList
{
    [chooseIPController setData:_deviceList];
    
    CGRect chooseIPRect;
    chooseIPRect.origin.x = 0;
    chooseIPRect.origin.y = imgNavbar.frame.size.height;
    chooseIPRect.size.width = self.view.frame.size.width;
    chooseIPRect.size.height = self.view.frame.size.height - imgNavbar.frame.size.height;
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.6];
    lblInstruction.alpha = 0;
    lblVersion.alpha = 0;
    lblStatus.alpha = 0;
    imgLogo.alpha = 0;
	[UIView commitAnimations];
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelay:0.2];
	[UIView setAnimationDuration:0.6];
    btnNavbarBack.alpha = 1;
	chooseIPController.view.frame = chooseIPRect;
	[UIView commitAnimations]; 
}

- (void)hideDeviceList
{
    CGRect chooseIPRect;
    chooseIPRect.origin.x = 0;
    chooseIPRect.origin.y = - self.view.frame.size.height;
    chooseIPRect.size.width = self.view.frame.size.width;

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.6];
    btnNavbarBack.alpha = 0;
	chooseIPController.view.frame = chooseIPRect;
	[UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.6];
    [UIView setAnimationDelay:0.2];
    [UIView setAnimationDidStopSelector: @selector(clearDeviceList)];
    lblInstruction.alpha = 1;
    lblVersion.alpha = 1;
    lblStatus.alpha = 1;
    imgLogo.alpha = 1;
	[UIView commitAnimations];
}

- (void)clearDeviceList
{
    [chooseIPController clearData];
}

- (void)setStatusText:(NSString *)text
{
    lblStatus.text = text;
}

- (void)restartInitSequenceWithDelay:(float)second
{
    [self performSelector:@selector(initializeSequence) withObject:nil afterDelay:second];
}

- (void)showSimpleMessageDialog:(NSString*)message
{
    [self showSimpleMessageDialog:message withButton:nil];
}

- (void)showSimpleMessageDialog:(NSString*)message withButton:(NSString*)btnName
{
    if (alertView != nil)
        [alertView release];
    alertView = nil;
    
    alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:btnName otherButtonTitles:@"", nil];
    [alertView show];
}

#pragma mark - DataComm Utilites (to be move to a base class)

- (void)sendHandshake
{
    if (mainComm == nil)    
        mainComm = [[CommService alloc] initWithDelegate:self];
    [mainComm sendUDPCommandWithBroadcast:@"Hello" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [[UIDevice currentDevice] platformString],@"type",
                                                                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"version",                                                                 nil] andTag:HELLOSPAM_MSG];
}

- (void)sendNetworkConfig
{
    
    NSString *selectedIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedHomeNetworkIndex"];
    NSDictionary *selectedNetworkDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:@"homeNetworkArray"] objectAtIndex:[selectedIndex intValue]];
    NSString *networkAuth = [[selectedNetworkDictionary objectForKey:@"auth"] objectForKey:@"text"];
    NSString *networkEncryption = [[selectedNetworkDictionary objectForKey:@"encryption"] objectForKey:@"text"];
    
    [mainComm sendUDPCommand:@"SetNetwork" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          SSIDName.text, @"wifi_ssid",
                                                          networkEncryption,@"wifi_encryption",
                                                          networkAuth,@"wifi_authentication",
                                                          SSIDPassword.text, @"wifi_password",
                                                          nil] andTag:SETWIFI_MSG];
    //NeTV wil change to Access Point mode after 500ms
    //iPhone disconnects and revert to home network
}

- (void)sendWifiScan
{
    if (mainComm == nil)
        mainComm = [[CommService alloc] initWithDelegate:self];
    [mainComm sendUDPCommand:@"WifiScan" andParameters:nil andTag:5];
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


#pragma mark - Bonjour helper functions

// Creates an NSNetServiceBrowser that searches for services of a particular type in a particular domain.
// If a service is currently being resolved, stop resolving it and stop the service browser from
// discovering other services.
- (BOOL)searchForServicesOfType:(NSString *)type inDomain:(NSString *)domain
{
	[_netServiceBrowser stop];
	[_services removeAllObjects];

    if (_netServiceBrowser != nil)
        [_netServiceBrowser release];
    
	_netServiceBrowser = [[NSNetServiceBrowser alloc] init];
	if(!_netServiceBrowser)
		return NO;

	_netServiceBrowser.delegate = self;
	[_netServiceBrowser searchForServicesOfType:type inDomain:domain];
	return YES;
}

- (NSString *)addressHost4:(struct sockaddr_in *)pSockaddr4
{
    char addrBuf[INET_ADDRSTRLEN];
    
    if(inet_ntop(AF_INET, &pSockaddr4->sin_addr, addrBuf, sizeof(addrBuf)) == NULL)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Cannot convert address to string."];
    }
    
    return [NSString stringWithCString:addrBuf encoding:NSASCIIStringEncoding];
}

- (NSString *)addressHost6:(struct sockaddr_in6 *)pSockaddr6
{
    char addrBuf[INET6_ADDRSTRLEN];
    
    if(inet_ntop(AF_INET6, &pSockaddr6->sin6_addr, addrBuf, sizeof(addrBuf)) == NULL)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Cannot convert address to string."];
    }
    
    return [NSString stringWithCString:addrBuf encoding:NSASCIIStringEncoding];
}

- (NSString *)addressHost:(struct sockaddr *)pSockaddr
{
    if(pSockaddr->sa_family == AF_INET)
    {
        return [self addressHost4:(struct sockaddr_in *)pSockaddr];
    }
    else
    {
        return [self addressHost6:(struct sockaddr_in6 *)pSockaddr];
    }
}

#pragma mark - AsyncUdpSocket delegate

//Received data while listening
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

    //------------------------------------------------------
        
    if ([commandString isEqualToString:@"HELLO"])
    {
        _hasMoreHandshake = YES;
        _receiveHandshake = YES;
        
        //Status text on UI
        NSString *statusString = [NSString stringWithFormat:@"%d device(s) found", [_deviceList count]];
        [self setStatusText:statusString];
        
        if ([_deviceList objectForKey:addressString] == nil)
        {                       
            //Clean up received data into a nice dictionary
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:10];
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
            
            //Check valid Hello return data
            NSString *guid = [dict objectForKey:@"guid"];
            if (guid != nil && [guid length] > 10)
            {
                //Get device name (from Internet)
                NSString * deviceName = [self getGUIDDeviceName:guid];
                if (deviceName != nil)
                    [dict setObject:deviceName forKey:@"devicename"];
                [_deviceList setObject:dict forKey:addressString];
                
                NSLog(@"Found %@ %@, %@", addressString, deviceName, guid);
            }
        }
    }
    else if ([commandString isEqualToString:@"WIFISCAN"])
    {
        NSMutableArray *homeNetworkArray = [[NSMutableArray alloc] init];
        for (NSDictionary *eachNetwork in [[[tempParsedDict objectForKey:@"xml"] objectForKey:@"data"] objectForKey:@"wifi"]){
            [homeNetworkArray addObject:eachNetwork];
        }
        
        if (homeNetworkArray.count > 0){
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:homeNetworkArray forKey:@"homeNetworkArray"];
            ChooseHomeNetworkController *chnc = [[ChooseHomeNetworkController alloc] init];
            chnc.delegate = self;
            [self presentModalViewController:chnc animated:YES];
        }
        else{
            UIAlertView *noHomeNetworks = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No home networks detected" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [noHomeNetworks show];
        }
    }
    else
    {
        NSLog(@"Unknown command received");
    }

    //Listen for the next UDP packet to arrive...which will call this method again in turn
    [sock receiveWithTimeout:-1 tag:1];

    //Signal that we didn't ignore the packet
    return YES;
}

//Listening timeout
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    if (tag == HELLO_MSG)
    {
        UIAlertView *firstAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please ensure that you have connected to your NeTV network." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [firstAlert show];
    }
}

//Sending Timeout
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    //Open up settings, start from scratch
}


#pragma mark - ChooseIPController delegate

- (void) chooseIPController:(ChooseIPController *)chooseIPController didSelect:(NSMutableDictionary*)selectedData
{   
    [self dismissModalViewControllerAnimated:YES];
    
    NSString *ipString = [selectedData objectForKey:@"ip"];
    if (ipString == nil || [ipString length] < 7)
        return;
    
    //Not sure why there is a leading space character (due to XML parser?)
    ipString = [ipString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self hideDeviceList];
    
    RemoteController *remoteController = [[RemoteController alloc] initWithIP:ipString];
    [self.navigationController pushViewController:remoteController animated:YES];
}


#pragma mark - ChooseHomeNetworkController delegate

- (void)userFinish
{   
    [self dismissModalViewControllerAnimated:YES];
    /*
    NSString *selectedIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedHomeNetworkIndex"];
    NSDictionary *selectedNetworkDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:@"homeNetworkArray"] objectAtIndex:[selectedIndex intValue]];
    SSIDName.text = [[selectedNetworkDictionary objectForKey:@"ssid"] objectForKey:@"text"];
    [self setStatusText:@"Please enter password"];
    */
    [self reset];
}


#pragma mark - NSNetServiceBrowser delegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
	//if (_currentResolve && [service isEqual:_currentResolve])
	//	[self stopCurrentResolve];
    [service setDelegate:nil];
	[_services removeObject:service];
	
	//if (moreComing)
	//	_hasMoreHandshake = YES;
}	

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
	[_services addObject:service];
    [service setDelegate: self];
    [service resolveWithTimeout: 5];

	if (!moreComing)
		_hasMoreHandshake = YES;
}	


#pragma mark - NSNetService delegate

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    
}

- (void)netServiceDidResolveAddress:(NSNetService *)service
{
    NSArray *addresses = [service addresses];
    if ([addresses count] <= 0) {
        [_services removeObject:service];
        return;
    }
    for (id object in addresses)
    {
        /*
        NSString * address = [self addressHost:object];
        if (address == nil)
            continue;
        NSLog(@"Bonjour a device: %@", address);
         */
    }
        
    //NSLog(@"Bonjour a device: %@", [service addresses]);
}

#pragma mark - Application Logic

- (void)initializeSequence
{
    //Stage 1
    //If Wifi is disabled, show a message and stop here
    if (!_checkedReachability)
    {
        _checkedReachability = YES;
        if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != ReachableViaWiFi)
        {
            [self setStatusText:@"Please turn on WiFi"];
            return;
        }
    }
    
    //Stage 2
    //Send handshake and wait to receive all handshakes
    if (!_sentHandshake)
    {
        [self sendHandshake];
        [self sendHandshake];
        [self sendHandshake];
        [self setStatusText:@"Searching for NeTV..."];
        _sentHandshake = YES;
        [self restartInitSequenceWithDelay: 2.0];
        return;
    }
    
    //Stage 3
    //Wait for more handshake messages to arrive
    if (_hasMoreHandshake)
    {
        _hasMoreHandshake = NO;
        [self restartInitSequenceWithDelay:0.6];
        return;
    }

    //Stage 4
    //If received some handshake messages already
    if (_receiveHandshake)
    {
        //Hide the current prompt (if any)
        if (alertView != nil)
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        
        //Display a list, stop device discovery
        [self showDeviceList];
        return;
    }
    
    [self sendHandshake];
    [self restartInitSequenceWithDelay: 1.0];
}

@end
