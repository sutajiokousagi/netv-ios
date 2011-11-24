//
//  NeTVWebViewController.m
//  NeTV
//

#import "NeTVWebViewController.h"


@interface NeTVWebViewController() <UIWebViewDelegate, UIScrollViewDelegate>
    - (void)updateWebButtons;
    - (void)updateAddress:(NSURLRequest*)request;
    - (void)showError:(NSError*)error;
    - (void)netvLoadURL:(NSString*)url;
    - (UIScrollView*) getScrollView;
    @property (nonatomic, retain) UIScrollView* scrollView;
    @property (nonatomic, copy) NSString *theMainIP;
@end

@implementation NeTVWebViewController

@synthesize webView;
@synthesize toolbar;
@synthesize back;
@synthesize forward;
@synthesize refresh;
@synthesize stop;
@synthesize addressField;
@synthesize loadingBar;

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
	
    NSAssert(self.back, @"Unconnected IBOutlet 'back'.");
    NSAssert(self.forward, @"Unconnected IBOutlet 'forward'.");
    NSAssert(self.refresh, @"Unconnected IBOutlet 'refresh'.");
    NSAssert(self.stop, @"Unconnected IBOutlet 'stop'.");
    NSAssert(self.webView, @"Unconnected IBOutlet 'webView'.");
    NSAssert(self.addressField, @"Unconnected IBOutlet addressField");
    
    self.scrollView = [self getScrollView];
    self.theMainIP = [self getDeviceIP];
    self.addressField.text = DEFAULT_URL;
    
    NSURL* url = [NSURL URLWithString:DEFAULT_URL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self updateWebButtons];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidUnload
{
    self.webView = nil;
    self.toolbar = nil;
    self.back = nil;
    self.forward = nil;
    self.refresh = nil;
    self.stop = nil;
    self.addressField = nil;
    
    self.theMainIP = nil;
    self.scrollView = nil;
        
    [super viewDidUnload];
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



#pragma mark - UIWebViewDelegate protocols

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webview
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateAddress:[webview request]];
    [self updateWebButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webview
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateAddress:[webview request]];
    [self updateWebButtons];
    
    // The following code determine the height of a web page. 
    CGSize fittingSize = [self.webView sizeThatFits:CGSizeZero];
    pageLength = fittingSize.height;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateWebButtons];
    [self showError:error];
}



#pragma mark - UIScrollViewDelegate protocols

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollview;                                               // any offset changes
{
    float offset = scrollview.contentOffset.y /pageLength;   
    [self sendMultitabScrollF:self.theMainIP tabIndex:1 scrollfX:0.0 scrollfY:offset];
}



#pragma mark - Implementation details

- (void)updateWebButtons
{
    self.forward.enabled = self.webView.canGoForward;
    self.back.enabled = self.webView.canGoBack;
    self.stop.enabled = self.webView.loading;
}

- (void)updateAddress:(NSURLRequest *)request
{
    NSURL* url = [request mainDocumentURL];
    NSString* absoluteString = [url absoluteString];
    if ([absoluteString length] < 3)
        return;
    self.addressField.text = absoluteString;
}

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
