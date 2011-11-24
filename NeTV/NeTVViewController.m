//
//  NeTVViewController.m
//  NeTV
//

#import "NeTVViewController.h"
#import "RemoteController.h"
#import <QuartzCore/QuartzCore.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <netdb.h>

#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

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
    
    //Show app version number
    NSLog(@"Version %@", self.appVersion);
    lblVersion.text = self.appVersion;
       
    //Hide the custom navbar back button
    btnNavbarBack.alpha = 0;
    
    //Setup custom bottom bar
    CGRect statusBarRect;
    statusBarRect.origin.x = 0;
    statusBarRect.origin.y = self.view.frame.size.height;
    statusBarRect.size.width = self.view.frame.size.width;
    statusBarRect.size.height = viewStatusBar.frame.size.height;
    [self.view insertSubview:viewStatusBar aboveSubview:lblStatus];
    viewStatusBar.frame = statusBarRect;
        
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
    
    //Hide loading icon initially
    imgLoading.alpha = 0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
	//Bonjour stuff
    if (_services == nil)
        _services = [[NSMutableArray alloc] init];
    [self searchForServicesOfType:@"_netv._tcp." inDomain:@""];
    
    //Rescan
    [self reset];
}

- (void)viewDidAppear:(BOOL)animated
{   
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
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
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
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
    imgLoading.alpha = 0;
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
    lblStatusFull.text = text;
}

- (void)showStatusBar:(NSString*)text
{
    if (text != nil)
        [self setStatusText:text];
    
    CGRect statusBarRect;
    statusBarRect.origin.x = 0;
    statusBarRect.origin.y = self.view.frame.size.height - viewStatusBar.frame.size.height;
    statusBarRect.size.width = self.view.frame.size.width;
    statusBarRect.size.height = viewStatusBar.frame.size.height;
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3];
	viewStatusBar.frame = statusBarRect;
	[UIView commitAnimations];
}

- (void)showStatusBarError:(NSString*)text
{
    [imgStatusBar setImage:[UIImage imageNamed:@"bottombar_error.png"]];
    [self showStatusBar:text];
}

- (void)showStatusBarInfo:(NSString*)text
{
    [imgStatusBar setImage:[UIImage imageNamed:@"bottombar_info.png"]];
    [self showStatusBar:text];
}

- (void)hideStatusBar
{
    CGRect statusBarRect;
    statusBarRect.origin.x = 0;
    statusBarRect.origin.y = self.view.frame.size.height + 5;
    statusBarRect.size.width = self.view.frame.size.width;
    statusBarRect.size.height = viewStatusBar.frame.size.height;
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3];
	viewStatusBar.frame = statusBarRect;
	[UIView commitAnimations];
}

- (void)showLoadingIcon
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.7];
	[UIView setAnimationDelay:0.5];
	imgLoading.alpha = 0.5;
	[UIView commitAnimations];
    
    //Setup spining loading icon
    CATransform3D rotationTransform = CATransform3DMakeRotation(0.9999f * M_PI, 0, 0, 1.0);
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];    
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    rotationAnimation.duration = 1.25f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 999; 
    [imgLoading.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)hideLoadingIcon
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.5];
	imgLoading.alpha = 0;
	[UIView commitAnimations];
}

- (BOOL)isDeviceListVisible
{
    return (chooseIPController.view.frame.origin.y + chooseIPController.view.frame.size.height > 10) ? YES : NO;
}

- (BOOL)isStatusBarVisible
{
    return (viewStatusBar.frame.origin.y < self.view.frame.size.height) ? YES : NO;
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
                
                [self hideStatusBar];
                NSLog(@"Found %@ %@, %@", addressString, deviceName, guid);
            }
        }
    }
    /*
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
    */
    else
    {
        NSLog(@"Unknown command received");
    }

    //Listen for the next UDP packet to arrive...which will call this method again in turn
    [sock receiveWithTimeout:-1 tag:1];

    //Signal that we didn't ignore the packet
    return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{

}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    
}



#pragma mark - ChooseIPController delegate

- (void) chooseIPController:(ChooseIPController *)chooseIPController didSelect:(NSMutableDictionary*)selectedData
{   
    [self gotoRemoteControl:selectedData];
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

- (void)reset
{
    NSLog(@"NeTVViewController reseting...");
    _retryCounter = 0;
    _checkedReachability = NO;
    _startDiscoveryTime = (time_t)[[NSDate date] timeIntervalSince1970];
    _sentHandshake = NO;
    _receiveHandshake = NO;
    _hasMoreHandshake = NO;
    
    //UI
    if (_deviceList == nil)
        _deviceList = [[NSMutableDictionary alloc] initWithCapacity:10];
    [_deviceList removeAllObjects];
    [self hideStatusBar];
    [self showLoadingIcon];
    
    [self restartInitSequenceWithDelay:0.4];
}

- (void)restartInitSequenceWithDelay:(float)second
{
    [self performSelector:@selector(initializeSequence) withObject:nil afterDelay:second];
}

- (int)numberOfDevices
{
    if (_deviceList == nil)
        return 0;
    return [_deviceList count];
}

- (void)gotoRemoteControlSingleDevice
{
    NSMutableDictionary *deviceData = [[_deviceList allValues] objectAtIndex:0];
    [self gotoRemoteControl:deviceData];
}

- (void)gotoRemoteControl:(NSMutableDictionary*)deviceData
{
    NSString *ipString = [deviceData objectForKey:@"ip"];
    if (ipString == nil || [ipString length] < 7)
        return;
    
    //Not sure why there is a leading space character (due to XML parser?)
    ipString = [ipString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self setDeviceIP:ipString];
    
    [self hideDeviceList];
    
    RemoteController *remoteController = [[RemoteController alloc] initWithIP:ipString];
    [self.navigationController pushViewController:remoteController animated:YES];
}

- (void)initializeSequence
{
    //Stage 1
    //If Wifi is disabled, show a message and stop here
    if (!_checkedReachability)
    {
        _checkedReachability = YES;
        if (![self isReachableWifi])
        {
            [self showStatusBarError:@"Please turn on WiFi"];
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
        _sentHandshake = YES;
        [self setStatusText:@"Searching for NeTV..."];
        [self restartInitSequenceWithDelay: 2.0];
        return;
    }
    
    //Stage 3
    //Wait for more handshake messages to arrive
    if (_hasMoreHandshake)
    {
        _hasMoreHandshake = NO;
        [self restartInitSequenceWithDelay:1.0];
        return;
    }

    //Stage 4
    //If received some handshake messages already
    if (_receiveHandshake)
    {
        //Hide the current prompt (if any)
        if (alertView != nil)
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        
        //Found only 1 device
        if ([self numberOfDevices] == 1)
        {
            NSMutableDictionary *deviceData = [[_deviceList allValues] objectAtIndex:0];
            NSString * ipString = [deviceData objectForKey:@"ip"];
            ipString = [ipString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self showStatusBarInfo:ipString];
            [self hideLoadingIcon];
            
            [self performSelector:@selector(gotoRemoteControlSingleDevice) withObject:nil afterDelay:1.2];
            return;
        }
        
        //Display a list, stop device discovery
        [self showDeviceList];
        [self hideStatusBar];
        return;
    }
    
    //If too long without a response
    time_t secondLapsed = (time_t)[[NSDate date] timeIntervalSince1970] - _startDiscoveryTime;
    if (secondLapsed > 8 && secondLapsed < 11)
        [self showStatusBarError:@"No device found.\nPlease ensure your NeTV is powered up."];
    
    [self sendHandshake];
    [self restartInitSequenceWithDelay: 1.0];
}

@end
