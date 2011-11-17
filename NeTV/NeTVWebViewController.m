//
//  NeTVWebViewController.m
//  NeTV
//
//  Created by erain on 15/11/11.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NeTVWebViewController.h"

static const CGFloat kNavBarHeight = 52.0f;
static const CGFloat kLabelHeight = 14.0f;
static const CGFloat kMargin = 10.0f;
static const CGFloat kSpacer = 2.0f;
static const CGFloat kLabelFontSize = 12.0f;
static const CGFloat kAddressHeight = 26.0f;

@implementation NeTVWebViewController

@synthesize webView = mWebView;
@synthesize toolbar = mToolbar;
@synthesize back = mBack;
@synthesize forward = mForward;
@synthesize refresh = mRefresh;
@synthesize stop = mStop;
//@synthesize pageTitle = mPageTitle;
@synthesize addressField = mAddressField;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Setting the address bar  
    self.addressField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.addressField.borderStyle = UITextBorderStyleRoundedRect;
    self.addressField.font = [UIFont systemFontOfSize:17];
    self.addressField.keyboardType = UIKeyboardTypeURL;
    self.addressField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.addressField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.addressField addTarget:self 
                action:@selector(loadAddress:event:) 
      forControlEvents:UIControlEventEditingDidEndOnExit];
    
    NSAssert(self.back, @"Unconnected IBOutlet 'back'.");
    NSAssert(self.forward, @"Unconnected IBOutlet 'forward'.");
    NSAssert(self.refresh, @"Unconnected IBOutlet 'refresh'.");
    NSAssert(self.stop, @"Unconnected IBOutlet 'stop'.");
    NSAssert(self.webView, @"Unconnected IBOutlet 'webView'.");
    NSAssert(self.addressField, @"Unconnected IBOutlet addressField");
    
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    
    NSURL* url = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self updateButtons];
}

- (void)dealloc
{
    [mWebView release];
    [mToolbar release];
    [mBack release];
    [mForward release];
    [mRefresh release];
    [mStop release];
    [mAddressField release];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

// MARK: -
// MARK: UIWebViewDelegate protocol
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self updateAddress:request];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
//    [self updateTitle:webView];
    NSURLRequest* request = [webView request];
    [self updateAddress:request];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
    [self informError:error];
}

// MARK: -
// MARK: Helper Functionsring 

- (void)updateButtons
{
    self.forward.enabled = self.webView.canGoBack;
    self.back.enabled = self.webView.canGoBack;
    self.stop.enabled = self.webView.loading;
}

- (void)loadAddress:(id)sender event:(UIEvent *)event
{
    NSString* urlString = self.addressField.text;
    NSURL* url = [NSURL URLWithString:urlString];
    if (!url.scheme) {
        NSString* modifiedURLString = [NSString stringWithFormat:@"http://%@",
                                       urlString];
        url = [NSURL URLWithString:modifiedURLString];
    }
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)updateAddress:(NSURLRequest *)request
{
    NSURL* url = [request mainDocumentURL];
    NSString* absoluteString = [url absoluteString];
    self.addressField.text = absoluteString;
}

- (void)informError:(NSError*)error
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

@end
