/*
 
 File: NeTVWebViewController.h
 Abstract: This is the browser UI, sending URLs to NeTV & scrolling of webpage
 
 For full documentation and source code, please visit: http://wiki.chumby.com/index.php/NeTV_developer_info
 */

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
    
    float pageLength;
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

- (void)netvScrollOffset:(float)offset;

- (UIScrollView*) addScrollViewListener;

@end
