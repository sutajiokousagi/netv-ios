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
#define MULTICASTGROUP     @"225.0.0.37"
#define DEFAULTIP          @"192.168.100.1"

#define HELLO_MSG 01
#define HELLOSPAM_MSG 02

#define SETWIFI_MSG 11
#define GETWIFI_MSG 12

@implementation NeTVViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    sentWifiDetails = NO;
    currentlySpammingHello = NO;
    fullIPList = [[NSMutableArray alloc] init];
    
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi) {
        //Code to execute if WiFi is  enabled
        NSLog(@"On Wifi");
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

//swap of method names, please ignore
- (IBAction)wifiScan:(id)sender{

    //Send SSID Name and Pass to NeTV 
    mainComm = [[CommService alloc] initWithDelegate:self];
    
    [mainComm sendUDPCommand:@"Hello" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [[UIDevice currentDevice] platformString],@"type",
                                                     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"version", nil] andTag:HELLO_MSG];
    
    
    [mainComm sendUDPCommand:@"WifiScan" andParameters:nil andTag:5];
}
- (IBAction)sendData:(id)sender{
    
    // mainComm = [[CommService alloc] initWithDelegate:self];
    [mainComm sendUDPCommand:@"Hello" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [[UIDevice currentDevice] platformString],@"type",
                                                     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"version", nil] andTag:HELLO_MSG];
    
    
    statusLabel.text = @"Sending WiFi details";
    sentWifiDetails = YES;
    [self helloDone];
}

- (void)helloDone{
    
    NSString *selectedIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedHomeNetworkIndex"];
    NSDictionary *selectedNetworkDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:@"homeNetworkArray"] objectAtIndex:[selectedIndex intValue]];
    NSString *networkAuth = [[selectedNetworkDictionary objectForKey:@"auth"] objectForKey:@"text"];
    NSString *networkEncryption = [[selectedNetworkDictionary objectForKey:@"encryption"] objectForKey:@"text"];
    
    
    [mainComm sendUDPCommand:@"SetNetwork" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          SSIDName.text, @"wifi_ssid",
                                                          networkEncryption,@"wifi_encryption",
                                                          networkAuth,@"wifi_authentication",
                                                          SSIDPassword.text, @"wifi_password", nil] andTag:SETWIFI_MSG];
    //NeTV changes to access-point mode
    //iPhone disconnects and chooses home network
    
    [self performSelector:@selector(beginTimer) withObject:nil afterDelay:5];
}

- (void)beginTimer{
    NSLog(@"Going to start spamming hello now");
    currentlySpammingHello = YES;
    NSLog(@"currentlySpammingTheShit is  %s", currentlySpammingHello ? "true" : "false");
    numberOfSecondsSoFar = 0;
    mainTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                 target:self
                                               selector:@selector(spamHello)
                                               userInfo:nil
                                                repeats:YES];
}

- (IBAction)spamHelloIB:(id)sender{
    
    [mainComm sendUDPCommandWithBroadcast:@"Hello" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [[UIDevice currentDevice] platformString],@"type",
                                                                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"version", nil] andTag:HELLOSPAM_MSG];
}

- (void)spamHello{
    NSLog(@"Spamming hello");
    currentlySpammingHello = YES;
    [mainComm sendUDPCommandWithBroadcast:@"Hello" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [[UIDevice currentDevice] platformString],@"type",
                                                     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"version", nil] andTag:HELLOSPAM_MSG];
    
    numberOfSecondsSoFar+=2;
    
    statusLabel.text = [NSString stringWithFormat:@"Hello Spam TimeOut %i", numberOfSecondsSoFar];
    
    if (numberOfSecondsSoFar == 10){
        //Timeout, start from scratch
        if (fullIPList.count == 0){
            NSLog(@"Invalidating and setting bool to NO");
            currentlySpammingHello = NO;
            [mainTimer invalidate];
            statusLabel.text = [NSString stringWithFormat:@"Hello Spam Maxed Out %i", numberOfSecondsSoFar];
        }
        else{
            NSLog(@"Finished 10 seconds");
            currentlySpammingHello = NO;
            [mainTimer invalidate];
            ChooseIPController *cip = [[ChooseIPController alloc] initWithArray:fullIPList];
            [self.navigationController pushViewController:cip animated:YES];
        }
    }
}


//Received data while listening
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSString *theLine=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]; //Convert the UDP data to an NSString
    LOG_EXPR(theLine);
    NSLog(@"PARSING DATA");
    NSDictionary *tempParsedDict = [XMLReader dictionaryForXMLString:theLine error:nil];
    LOG_EXPR(tempParsedDict);
    /**
    if ([[[[tempParsedDict objectForKey:@"xml"] objectForKey:@"cmd"] objectForKey:@"text"] isEqualToString:@"WIFISCAN"]){

        NSMutableDictionary *tempMutDict = [NSMutableDictionary dictionaryWithDictionary:tempParsedDict];
        LOG_EXPR(tempMutDict);
        for (NSDictionary* eachWifi in [[tempMutDict objectForKey:@"xml"] objectForKey:@"data"]){
    //        for (id key in eachWifi) {
    //            
    //            NSLog(@"key: %@, value: %@", key, [eachWifi objectForKey:key]);
    //            
    //        }        
            NSMutableDictionary *eachWifiMut = [eachWifi mutableCopy];
            NSString *tempSSID = [eachWifiMut objectForKey:@"ssid"];
            NSString *trimmedSSID = [tempSSID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [eachWifiMut setObject:trimmedSSID forKey:@"ssid"];
        }
    }
//    LOG_EXPR(tempParsedDict);
    LOG_EXPR(tag);
    */
    if ([[[[tempParsedDict objectForKey:@"xml"] objectForKey:@"cmd"] objectForKey:@"text"] isEqualToString:@"WIFISCAN"]){
        NSLog(@"I'm in GetWifi Msg!");
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
     
    
    else{
        NSLog(@"Other data received");
        
        NSLog(@"currentlySpammignHello is %s", currentlySpammingHello ? "true" : "false");
        if (currentlySpammingHello){
            
            NSLog(@"Adding host %@ to IP List",host);
            [fullIPList addObject:host];
            
        }
    }

    
    [asyncSocket receiveWithTimeout:-1 tag:1]; //Listen for the next UDP packet to arrive...which will call this method again in turn.
    
    
    return YES; //Signal that we didn't ignore the packet.
}

//Listening timeout
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    if (tag == HELLO_MSG){
        UIAlertView *firstAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please ensure that you have connected to your NeTV network." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [firstAlert show];
    }
}

//Sending Timeout
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    //Open up settings, start from scratch
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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


//ChooseHomeNetworkController Delegate Methods
- (void)userFinish{
    [self dismissModalViewControllerAnimated:YES];
    NSString *selectedIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedHomeNetworkIndex"];
    NSDictionary *selectedNetworkDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:@"homeNetworkArray"] objectAtIndex:[selectedIndex intValue]];
    SSIDName.text = [[selectedNetworkDictionary objectForKey:@"ssid"] objectForKey:@"text"];
    statusLabel.text = @"Please enter password and hit Submit";
}

@end
