/*
 
 File: NeTVWebViewController.h
 Abstract: This is the browser UI, sending URLs to NeTV & scrolling of webpage
 
 For full documentation and source code, please visit: http://wiki.chumby.com/index.php/NeTV_developer_info
 */

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface NeTVWebViewController : BaseController
{   
    float pageLength;
}

@property (nonatomic, retain) IBOutlet UIWebView* webView;
@property (nonatomic, retain) IBOutlet UIButton* backward;
@property (nonatomic, retain) IBOutlet UIButton* forward;
@property (nonatomic, retain) IBOutlet UITextField* addressField;
@property (nonatomic, retain) IBOutlet UIImageView* loadingBar;
@property (nonatomic, retain) IBOutlet UILabel *lblStatus;
@property (nonatomic, retain) IBOutlet UIImageView *imgLoading;

- (IBAction)loadAddress:(id)sender;
- (IBAction)goBackward:(id)sender;
- (IBAction)goForward:(id)sender;

@end
