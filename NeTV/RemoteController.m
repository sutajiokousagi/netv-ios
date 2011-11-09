//
//  RemoteController.m
//  NeTV
//
//  Created by Sidwyn Koh on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define UDP_TAG     1
#define HELLO_MSG   1

#import "RemoteController.h"
#import "UIDevice-Hardware.h"
#import "XMLReader.h"
#import "VTPG_Common.h"
#import "SVWebViewController.h"

@implementation RemoteController

@synthesize theMainIP;
@synthesize ipAddr;


#pragma mark - Custom Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithIP:(NSString *)theIP{
    self = [super init];
    if (self){
        self.theMainIP = theIP;
    }
    return self;
}


#pragma mark - Standard Initialization

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    //Init communication object
    if (mainComm == nil)
        mainComm = [[CommService alloc] initWithDelegate:self andIP:self.theMainIP];
    
    //Say hello
    [mainComm sendUDPCommand:@"Hello" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [[UIDevice currentDevice] platformString],@"type",
                                                     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"version", nil] andIP:self.theMainIP andTag:UDP_TAG];
    
    //UI
    ipAddr.text = [@"Controlling " stringByAppendingString:theMainIP];
	    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{   
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Buttons

- (IBAction)pressSettings:(id)sender{   [self sendRemoteControlCommand:@"cpanel"];  }
- (IBAction)pressChumby:(id)sender  {   [self sendRemoteControlCommand:@"widget"];  }
- (IBAction)pressUp:(id)sender      {   [self sendRemoteControlCommand:@"up"];      }
- (IBAction)pressDown:(id)sender    {   [self sendRemoteControlCommand:@"down"];    }
- (IBAction)pressLeft:(id)sender    {   [self sendRemoteControlCommand:@"left"];    }
- (IBAction)pressRight:(id)sender   {   [self sendRemoteControlCommand:@"right"];   }
- (IBAction)pressCenter:(id)sender  {   [self sendRemoteControlCommand:@"center"];  }

//Open a browser view to use iPhone control NeTV
- (IBAction)pressBrowser:(id)sender
{
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:@"http://google.com"];
    [self.navigationController pushViewController:webViewController animated:YES];
    [webViewController release];        
}

//Open a photo picker to send a photo to NeTV
- (IBAction)pressPhoto:(id)sender
{
    //TODO
}

//Common function to send a remote control button
- (void)sendRemoteControlCommand:(NSString*) buttonName
{
    [mainComm sendUDPCommand:@"RemoteControl" 
               andParameters:[NSDictionary dictionaryWithObjectsAndKeys:buttonName, @"value", nil] 
                       andIP:self.theMainIP 
                      andTag:UDP_TAG];
}


#pragma mark - AsyncUdpSocket delegate

//Received data while listening
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSString *theLine=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]; //Convert the UDP data to an NSString
    
    NSLog(@"RECEIVED SOMETHING IN REMOTECONTROLLER: %@", theLine);
    
    NSDictionary *tempParsedDict = [XMLReader dictionaryForXMLString:theLine error:nil];
    
    LOG_EXPR(tempParsedDict);
    
    return YES;
}

//Listening timeout
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"Timeout");
    
}

@end
