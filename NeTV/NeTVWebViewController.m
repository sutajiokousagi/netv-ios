//
//  NeTVWebViewController.m
//  NeTV
//
//  Created by erain on 15/11/11.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NeTVWebViewController.h"

@implementation NeTVWebViewController

@synthesize webView, addressBar, activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (id)initWithAddress:(NSString *)string
//{
//    self = [super initWithNibName:nil bundle:[NSBundle mainBundle]];
//    
//    NSString *urlAddress = string;
//    
//    NSURL *url = [NSURL URLWithString:urlAddress];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];    
//    [webView loadRequest:requestObj];
//    
//    [addressBar setText:urlAddress];
//    [addressBar setKeyboardType:UIKeyboardTypeURL];
//    
//    return self;
//}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *urlAddress = @"http://www.google.com";
    
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];    
    [webView loadRequest:requestObj];
    
    [addressBar setText:urlAddress];
    [addressBar setKeyboardType:UIKeyboardTypeURL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

-(IBAction)gotoAddress:(id)sender 
{
    NSURL *url = [NSURL URLWithString:[addressBar text]];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:requestObj];
    [addressBar resignFirstResponder];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityIndicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (UIWebViewNavigationTypeLinkClicked == navigationType)
    {
        NSURL *URL = [request URL];
        if ([[URL scheme] isEqualToString:@"http"]) {
            [addressBar setText:[URL absoluteString]];
            [self gotoAddress:nil];
        }
        return NO;
    }
    return YES;
}

@end
