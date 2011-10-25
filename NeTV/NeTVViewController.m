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
#import "ChooseIPController.h"
#import "VTPG_Common.h"
#import "XMLReader.h"
#import "Reachability.h"

#define DEFAULTPORT         8082
#define MULTICASTGROUP      @"225.0.0.37"
#define DEFAULTIP           @"192.168.100.1"

#define HELLO_MSG           01
#define HELLOSPAM_MSG       02

#define SETWIFI_MSG         11
#define GETWIFI_MSG         12

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
    
    //Init communication object (should be a singleton class to be correct)
    mainComm = [[CommService alloc] initWithDelegate:self];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reset];
}

- (void)viewWillDisappear:(BOOL)animated
{
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
    [_deviceList removeAllObjects];
    
    [self initializeSequence];
}



#pragma mark - UI Events


#pragma mark - Helpers

- (void)showDeviceListDialog
{
    [self setStatusText:@"Select a device to control"];
    
    NSArray *keyArray = [_deviceList allKeys];
    for (int i=0; i< [keyArray count]; i++)
        [_ipListForUI addObject:[keyArray objectAtIndex:i]];
    
    ChooseIPController *listIP = [[ChooseIPController alloc] initWithArray:_ipListForUI];
    [self.navigationController pushViewController:listIP animated:YES];
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

    //LOG_EXPR(tempParsedDict);
    //------------------------------------------------------
        
    if ([commandString isEqualToString:@"HELLO"])
    {
        _hasMoreHandshake = YES;
        _receiveHandshake = YES;
        
        //Should also add device data dictionary to _deviceList as well
        [_deviceList setObject:rootDictionary forKey:addressString];
        
        //Status text
        NSString *statusString = [NSString stringWithFormat:@"%d device(s) found", [_deviceList count]];
        [self setStatusText:statusString];
        
        NSLog(@"Rx handshake: %@", addressString);
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
        [self restartInitSequenceWithDelay:0.3];
        return;
    }
    
    //Stage 2
    //Send handshake and wait a bit longer to receive all handshakes
    if (!_sentHandshake)
    {
        [self sendHandshake];
        [self setStatusText:@"Searching for NeTV..."];
        _retryCounter++;
        
        if (_retryCounter < 3)
        {
            //Send handshake 3 times & then set _sentHandshake flag
            [self sendHandshake];
            [self restartInitSequenceWithDelay: 0.3];
        }
        else
        {
            _sentHandshake = YES;
            [self restartInitSequenceWithDelay:0.6];
        }
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
        
        //Display a list, stop sending handshake
        [self showDeviceListDialog];
        return;
    }
    
    [self sendHandshake];
    [self restartInitSequenceWithDelay: 1.0];
}

@end
