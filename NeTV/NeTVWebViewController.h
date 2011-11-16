//
//  NeTVWebViewController.h
//  NeTV
//
//  Created by erain on 15/11/11.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NeTVWebViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    IBOutlet UITextField *addressBar;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UITextField *addressBar;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

-(id)initWithAddress:(NSString*)string;

-(IBAction)gotoAddress:(id)sender;

@end
