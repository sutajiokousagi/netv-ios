//
//  NeTVWebViewController.h
//  NeTV
//
//  Created by erain on 15/11/11.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface NeTVWebViewController : BaseController <UIWebViewDelegate, UIScrollViewDelegate>
{
    UIWebView* mWebView;
    UIToolbar* mToolbar;
    UIBarButtonItem* mBack;
    UIBarButtonItem* mForward;
    UIBarButtonItem* mRefresh;
    UIBarButtonItem* mStop;
    UITextField* mAddressField;
    
    UIScrollView* mScrollView;
}

@property (nonatomic, retain) IBOutlet UIWebView* webView;
@property (nonatomic, retain) IBOutlet UIToolbar* toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* back;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* forward;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* refresh;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* stop;
@property (nonatomic, retain) IBOutlet UITextField* addressField;
@property (nonatomic, retain) IBOutlet UIImageView* loadingBar;

@property (nonatomic, retain) UIScrollView* scrollView;

- (void)updateButtons;

- (void)loadAddress:(id)sender event:(UIEvent *)event;

- (void)updateAddress:(NSURLRequest*)request;

- (void)informError:(NSError*)error;

- (void)netvLoadURL:(NSString*)url;

- (void)netvScrollOffset:(int)offset;

- (UIScrollView*) addScrollViewListener;

@end
