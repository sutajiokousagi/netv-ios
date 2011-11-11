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
    IBOutlet UILabel *lblVersion;
    IBOutlet UILabel *lblStatus;
    IBOutlet UILabel *lblInstruction;
    IBOutlet UIImageView *imgLogo;
    IBOutlet UIImageView *imgNavbar;
    IBOutlet UIButton *btnNavbarBack;
    
    IBOutlet UIView *viewStatusBar;
    IBOutlet UILabel *lblStatusFull;
    IBOutlet UIImageView *imgStatusBar;
    UIAlertView *alertView;
    ChooseIPController *chooseIPController;
	
	//Bonjour stuff
	NSMutableArray *_services;
	NSNetServiceBrowser *_netServiceBrowser;
	NSNetService *_currentResolve;
    
    //Flag
    int _retryCounter;
    time_t _startDiscoveryTime;
    BOOL _checkedReachability;
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
- (void)showStatusBar:(NSString*)text;
- (void)showStatusBarError:(NSString*)text;
- (void)showStatusBarInfo:(NSString*)text;
- (void)hideStatusBar;
- (BOOL)isDeviceListVisible;
- (BOOL)isStatusBarVisible;
- (int)numberOfDevices;
- (void)restartInitSequenceWithDelay:(float)second;
- (void)showSimpleMessageDialog:(NSString*)message;
- (void)showSimpleMessageDialog:(NSString*)message withButton:(NSString*)btnName;

//Bonjour helper functions
- (BOOL)searchForServicesOfType:(NSString *)type inDomain:(NSString *)domain;

//Application logic
- (void)reset;
- (void)gotoRemoteControl:(NSMutableDictionary*)deviceData;
- (void)initializeSequence;

@end
