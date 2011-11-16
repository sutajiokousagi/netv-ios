//
//  NeTVWebViewController.h
//  NeTV
//
//  Created by erain on 15/11/11.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface NeTVWebViewController : BaseController <UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    IBOutlet UITextField *addressBar;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    IBOutlet UIButton *btnNavbarBack;

}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UITextField *addressBar;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIButton *btnNavbarBack;

// Custom Initialization
- (id)initWithAddress:(NSString *)string;

// UI Evants
- (IBAction)gotoAddress:(id)sender;


@end
