//
//  RemoteController.m
//  NeTV
//

#import "RemoteController.h"
#import "NeTVWebViewController.h"

@interface RemoteController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
    - (void)onRemoteControlButton:(NSString*) buttonName;
    - (void)onShowCenterDeco;
    - (void)onHideCenterDeco;
    - (void)launchImagePicker: (id)inView;
    - (void)launchCameraPicker: (id)inView;
    @property (nonatomic, copy) NSString *theMainIP;
@end

@implementation RemoteController

#define TMP_UPLOAD_PHOTO    @"/tmp/iphone_photo.jpg"

@synthesize btnNavbarBack;
@synthesize imgCenterDeco;
@synthesize btnCamera;
@synthesize ipAddr;
@synthesize theMainIP;

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
    
    //Hide Camera button if device doesn't have a camera
    btnCamera.hidden = ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.btnNavbarBack = nil;
    self.imgCenterDeco = nil;
    self.btnCamera = nil;
    self.ipAddr = nil;
    self.theMainIP = nil;
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

#pragma mark - UI Helpers

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

-(void)launchImagePicker: (id)inView
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        return;
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate: self];
    [self presentModalViewController:imagePicker animated:YES];
}

-(void)launchCameraPicker: (id)inView
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        return;
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType: UIImagePickerControllerSourceTypeCamera];
    [imagePicker setDelegate: self];
    [self presentModalViewController:imagePicker animated:YES];
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
    NeTVWebViewController *webViewController = [[NeTVWebViewController alloc] init];
    [self.navigationController pushViewController:webViewController animated:YES];
    [webViewController release];        
}

//Open a photo picker to send a photo to NeTV
- (IBAction)pressPhoto:(id)sender
{
    [self launchImagePicker:sender];
}

//Take a photo from camera & send to NeTV
- (IBAction)pressCamera:(id)sender
{
    [self launchCameraPicker:sender];
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



#pragma mark --
#pragma mark UIImagePickerControllerDelegate

// this get called when an image has been chosen from the library or taken from the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{      
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    //ignore videos
    if ( [mediaType isEqualToString:@"public.movie"] )
        return;    
    
    //Upload it to NeTV
    [self uploadPhoto:(self.theMainIP) withPath:TMP_UPLOAD_PHOTO media:info];
    
    //Get the image data & do something about it (show it in UI)
    //UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //picture taken from a camera
    if ( [info objectForKey:UIImagePickerControllerMediaMetadata] != nil ) {
        [self dismissModalViewControllerAnimated:YES];
        return;
    }
    
    //Note: we don't want to dismiss the picker for user might want to pick another image
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //Delete the temp file in NeTV
    [self sendUnlinkCommand:(self.theMainIP) path:TMP_UPLOAD_PHOTO];
    
    //Return to Control Panel tab
    [self sendMultitabCloseAll:(self.theMainIP)];

    //Cancel image picker
    [self dismissModalViewControllerAnimated:YES];
}



#pragma mark - ASIHTTPRequest delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //Sanity checks
    NSDictionary *returnDict = [self convertXMLResponseToNSDictionary:[request responseString]];
    if (returnDict == nil)
        return;
    
    //Most frequently used
    int returnStatus = [[returnDict objectForKey:@"status"] intValue];
    NSString* commandString = [returnDict objectForKey:@"cmd"];
    commandString = [commandString uppercaseString];
    //NSString* dataString = [returnDict objectForKey:@"value"];        //might be nil
    
    if ([commandString isEqualToString:@"UPLOADFILE"])
    {
        if (returnStatus != 1)
            return;
        NSString* remotePath = [returnDict objectForKey:@"path"];
        if (remotePath == nil || [remotePath length] < 3)
            return;
        
        //Show the just uploaded image
        NSMutableString *httpPath = [NSMutableString stringWithString:remotePath];
        [httpPath replaceOccurrencesOfString:@"/tmp" withString:@"http://localhost/tmp/netvserver" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [httpPath length])];
        NSLog(@"Showing photo: %@", httpPath);
        [self sendMultitabImageCommand:(self.theMainIP) tabIndex:1 remotePath:httpPath];
        return;
    }
    
    //[self handleResponseData: [request responseData]];
    NSLog(@"Finish: %@, %@", commandString, [request responseString]);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Failed: %@", [request responseString]);
    
    //Sanity checks
    NSDictionary *userInfo = [request userInfo];
    if (userInfo == nil || [userInfo objectForKey:@"cmd"] == nil)
        return;
    
    //Most frequently used
    NSString* commandString = [userInfo objectForKey:@"cmd"];
    commandString = [commandString uppercaseString];
    
    if ([commandString isEqualToString:@"UPLOADFILE"])
    {
        //retry?
    }
}


@end
