//
//  NeTVWebViewController.m
//  NeTV
//

#import "NeTVWebViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface NeTVWebViewController() <UIWebViewDelegate, UIScrollViewDelegate>
    - (UIScrollView*) getScrollView;
    - (void)showLoadingIcon;
    - (void)hideLoadingIcon;
    - (void)updateWebButtons;
    - (void)updateAddress:(NSURLRequest*)request;
    - (void)showError:(NSError*)error;
    - (void)netvLoadURL:(NSString*)url;
    @property (nonatomic, retain) UIScrollView* scrollView;
    @property (nonatomic, copy) NSString *theMainIP;
@end

@implementation NeTVWebViewController

@synthesize webView;
@synthesize backward;
@synthesize forward;
@synthesize addressField;
@synthesize loadingBar;
@synthesize lblStatus;
@synthesize imgLoading;

@synthesize scrollView;
@synthesize theMainIP;

#define DEFAULT_URL @"http://www.chumby.com"

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSAssert(self.backward, @"Unconnected IBOutlet 'backward'.");
    NSAssert(self.forward, @"Unconnected IBOutlet 'forward'.");
    NSAssert(self.webView, @"Unconnected IBOutlet 'webView'.");
    NSAssert(self.addressField, @"Unconnected IBOutlet addressField");
    NSAssert(self.lblStatus, @"Unconnected IBOutlet lblStatus");
    NSAssert(self.imgLoading, @"Unconnected IBOutlet imgLoading");
        
    self.scrollView = [self getScrollView];
    self.theMainIP = [self getDeviceIP];
    self.addressField.text = DEFAULT_URL;
    
    NSURL* url = [NSURL URLWithString:DEFAULT_URL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self updateWebButtons];
    
    //[self netvLoadURL:DEFAULT_URL];
    // No need to send url to netv here
    // Sending url to netv all using the function updateAddress
    // This also make the forward and backward work. 
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidUnload
{
    self.webView = nil;
    self.backward = nil;
    self.forward = nil;
    self.addressField = nil;
    self.lblStatus = nil;
    
    self.theMainIP = nil;
    self.scrollView = nil;
        
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //UI
    if (self.theMainIP != nil && [self.theMainIP isEqualToString:@"127.0.0.2"])
        lblStatus.text = @"Demo Mode";
    if (self.theMainIP != nil)
        lblStatus.text = [NSString stringWithFormat:@"Controlling %@", self.theMainIP];
    else
        lblStatus.text = @"";
    
    //Hide loading icon initially
    imgLoading.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"hahaha!");
    
    [self sendMultitabCloseAll:self.theMainIP];
    
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

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self sendMultitabCloseAll:(self.theMainIP)];
}


#pragma mark - UIWebViewDelegate protocols

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webview
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //[self updateAddress:[webview request]];
    [self updateWebButtons];
    [self showLoadingIcon];
}

- (void)webViewDidFinishLoad:(UIWebView *)webview
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateAddress:[webview request]];
    [self updateWebButtons];
    [self hideLoadingIcon];
    
    // The following code determine the height of a web page. 
    CGSize fittingSize = [self.webView sizeThatFits:CGSizeZero];
    pageLength = fittingSize.height;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateWebButtons];
    [self hideLoadingIcon];
    [self showError:error];
}



#pragma mark - UIScrollViewDelegate protocols

- (void)scrollViewDidScroll:(UIScrollView *)scrollview
{
    float offset = scrollview.contentOffset.y /pageLength;   
    [self sendMultitabScrollF:self.theMainIP tabIndex:1 scrollfX:0.0 scrollfY:offset];
}



#pragma mark - UI Events

- (IBAction)loadAddress:(id)sender
{
    NSString* urlString = self.addressField.text;
    NSURL* url = [NSURL URLWithString:urlString];
    
    if (!url.scheme)
    {
        NSString* modifiedURLString = [NSString stringWithFormat:@"http://%@", urlString];
        urlString = modifiedURLString;
        url = [NSURL URLWithString:modifiedURLString];
    }
    
    [self netvLoadURL:urlString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.addressField.text = urlString;
}

- (IBAction)goBackward:(id)sender
{
    [self.webView goBack];
}
- (IBAction)goForward:(id)sender
{
    [self.webView goForward];
}



#pragma mark - Helpers

// This function get the scrollView out of the UIWebView
- (UIScrollView*) getScrollView
{
    UIScrollView* currentScrollView;
    for (UIView* subView in self.webView.subviews) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            currentScrollView = (UIScrollView*)subView;
            currentScrollView.delegate = self;
        }
    }
    return currentScrollView;
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

- (void)updateWebButtons
{
    self.forward.enabled = self.webView.canGoForward;
    self.forward.alpha = self.webView.canGoForward ? 1.0 : 0.2;
    self.backward.enabled = self.webView.canGoBack;
    self.backward.alpha = self.webView.canGoBack ? 1.0 : 0.2;
}

- (void)updateAddress:(NSURLRequest *)request
{
    NSURL* url = [request mainDocumentURL];
    NSString* absoluteString = [url absoluteString];
    if ([absoluteString length] < 3)
        return;
    self.addressField.text = absoluteString;
    [self netvLoadURL:absoluteString];
}

- (void)showError:(NSError*)error
{
    NSString* localizedDescription = [error localizedDescription];
    UIAlertView* alertView = [[UIAlertView alloc]
                              initWithTitle:@"Error" 
                              message:localizedDescription 
                              delegate:nil 
                              cancelButtonTitle:@"OK" 
                              otherButtonTitles: nil];
    [alertView show];
    [alertView release];
}

- (void)netvLoadURL:(NSString*)url
{
    [self sendMultitabCommand:self.theMainIP tabIndex:1 options:@"load" param:url];
}

@end
