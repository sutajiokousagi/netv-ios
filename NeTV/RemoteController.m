//
//  RemoteController.m
//  NeTV
//
//  Created by Sidwyn Koh on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define CHUMBYBUTTON 1
#define SETTINGSBUTTON 2
#define UPBUTTON 3
#define DOWNBUTTON 4
#define LEFTBUTTON 5
#define RIGHTBUTTON 6
#define CENTERBUTTON 7

#define HELLO_MSG 01

#import "RemoteController.h"
#import "UIDevice-Hardware.h"
#import "XMLReader.h"
#import "VTPG_Common.h"
@implementation RemoteController
@synthesize theMainIP;
@synthesize ipAddr;
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad{
    [super viewDidLoad];
    mainComm = [[CommService alloc] initWithDelegate:self andIP:self.theMainIP];
    
    [mainComm sendUDPCommand:@"Hello" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [[UIDevice currentDevice] platformString],@"type",
                                                     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"version", nil] andIP:self.theMainIP andTag:HELLO_MSG];
        
    ipAddr.text = theMainIP;
    
}
#pragma mark -
#pragma mark - Buttons


//Received data while listening
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSString *theLine=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]; //Convert the UDP data to an NSString
    
    NSLog(@"RECEIVED SOMETHING IN REMOTECONTROLLER: %@", theLine);
    
    NSDictionary *tempParsedDict = [XMLReader dictionaryForXMLString:theLine error:nil];
    
    LOG_EXPR(tempParsedDict);
    
    return YES;
}

- (IBAction)pressChumby:(id)sender{
    [mainComm sendUDPCommand:@"RemoteControl" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"cpanel",@"value", nil] andIP:self.theMainIP andTag:CHUMBYBUTTON];
}
- (IBAction)pressSettings:(id)sender{
    [mainComm sendUDPCommand:@"RemoteControl" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"widget",@"value", nil] andIP:self.theMainIP andTag:SETTINGSBUTTON];
}
- (IBAction)pressUp:(id)sender{
    [mainComm sendUDPCommand:@"RemoteControl" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"up",@"value", nil] andIP:self.theMainIP andTag:UPBUTTON];
}
- (IBAction)pressDown:(id)sender{
    [mainComm sendUDPCommand:@"RemoteControl" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"down",@"value", nil] andIP:self.theMainIP andTag:DOWNBUTTON];
}
- (IBAction)pressLeft:(id)sender{
    [mainComm sendUDPCommand:@"RemoteControl" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"left",@"value", nil] andIP:self.theMainIP andTag:LEFTBUTTON];
}
- (IBAction)pressRight:(id)sender{
    [mainComm sendUDPCommand:@"RemoteControl" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"right",@"value", nil] andIP:self.theMainIP andTag:RIGHTBUTTON];
}
- (IBAction)pressCenter:(id)sender{
    [mainComm sendUDPCommand:@"RemoteControl" andParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"center",@"value", nil] andIP:self.theMainIP andTag:CENTERBUTTON];
}

//Listening timeout
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"Timeout");
    
}

#pragma mark - View lifecycle


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
