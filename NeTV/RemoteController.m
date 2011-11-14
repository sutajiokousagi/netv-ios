//
//  RemoteController.m
//  NeTV
//

#import "RemoteController.h"
#import "SVWebViewController.h"

@interface RemoteController()
    - (void)onRemoteControlButton:(NSString*) buttonName;
    - (void)onShowCenterDeco;
    - (void)onHideCenterDeco;
    @property (nonatomic, retain) NSString *theMainIP;
@end

@implementation RemoteController

@synthesize theMainIP;
@synthesize ipAddr;

#pragma mark - Custom Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (id)initWithIP:(NSString *)theIP{
    self = [super init];
    if (self)
    {
        self.theMainIP = theIP;
    }
    return self;
}


#pragma mark - Standard Initialization

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self onShowCenterDeco];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    //UI
    if (self.theMainIP != nil)
        ipAddr.text = [NSString stringWithFormat:@"Controlling %@", self.theMainIP];
    else
        ipAddr.text = @"";
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UI Events

- (IBAction)pressSettings:(id)sender{   [self onRemoteControlButton:@"cpanel"];  }
- (IBAction)pressChumby:(id)sender  {   [self onRemoteControlButton:@"widget"];  }
- (IBAction)pressUp:(id)sender      {   [self onRemoteControlButton:@"up"];      }
- (IBAction)pressDown:(id)sender    {   [self onRemoteControlButton:@"down"];    }
- (IBAction)pressLeft:(id)sender    {   [self onRemoteControlButton:@"left"];    }
- (IBAction)pressRight:(id)sender   {   [self onRemoteControlButton:@"right"];   }
- (IBAction)pressCenter:(id)sender  {   [self onRemoteControlButton:@"center"];  }

//Common function to handle all remote control button events
- (void)onRemoteControlButton:(NSString*) buttonName
{
    [self sendRemoteControl:buttonName toIP:self.theMainIP];
}

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


- (void)onShowCenterDeco
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:1.0];
    [UIView setAnimationDidStopSelector: @selector(onHideCenterDeco)];
    imgCenterDeco.alpha = 1;
	[UIView commitAnimations];
}
- (void)onHideCenterDeco
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:1.0];
    [UIView setAnimationDidStopSelector: @selector(onShowCenterDeco)];
    imgCenterDeco.alpha = 0;
	[UIView commitAnimations];
}


#pragma mark - AsyncUdpSocket delegate

//Received data while listening
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSString *theLine=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]; //Convert the UDP data to an NSString
    
    NSLog(@"RECEIVED SOMETHING IN REMOTECONTROLLER: %@", theLine);
    
    //NSDictionary *tempParsedDict = [XMLReader dictionaryForXMLString:theLine error:nil];
    
    return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    
}

@end
