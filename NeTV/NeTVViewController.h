//
//  NeTVViewController.h
//  NeTV
//

#import <Foundation/NSNetServices.h>
#import "BaseController.h"
#import "ChooseIPController.h"

@interface NeTVViewController : BaseController <NSNetServiceBrowserDelegate, NSNetServiceDelegate, ChooseIPControllerDelegate>
{
    //UI
    IBOutlet UITextField *SSIDName;
    IBOutlet UITextField *SSIDPassword;
    IBOutlet UILabel *lblVersion;
    IBOutlet UILabel *lblStatus;
    IBOutlet UILabel *lblInstruction;
    IBOutlet UIImageView *imgLogo;
    IBOutlet UIImageView *imgNavbar;
    IBOutlet UIButton *btnNavbarBack;
    UIAlertView *alertView;
    ChooseIPController *chooseIPController;
	
	//Bonjour stuff
	NSMutableArray *_services;
	NSNetServiceBrowser *_netServiceBrowser;
	NSNetService *_currentResolve;
    
    //Flag
    BOOL _checkedReachability;
    int _retryCounter;
    BOOL _sentHandshake;
    BOOL _receiveHandshake;
    BOOL _hasMoreHandshake;
    
    //Multiple device
    NSMutableDictionary *_deviceList;
}

//UI Events
-(IBAction)onNavbarBack:(id)sender;

//Helpers
- (void)showDeviceList;
- (void)hideDeviceList;
- (void)clearDeviceList;
- (void)setStatusText:(NSString*)text;
- (void)restartInitSequenceWithDelay:(float)second;
- (void)showSimpleMessageDialog:(NSString*)message;
- (void)showSimpleMessageDialog:(NSString*)message withButton:(NSString*)btnName;

//Bonjour helper functions
- (BOOL)searchForServicesOfType:(NSString *)type inDomain:(NSString *)domain;

//Application logic
- (void)reset;
- (void)initializeSequence;

@end
