/*
 
 File: NeTVViewController.h
 Abstract: This is the Splash screen UI, starting point of the app. Handles device discovery and device selection list
 
 For full documentation and source code, please visit: http://wiki.chumby.com/index.php/NeTV_developer_info
 */

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
    IBOutlet UIImageView *imgLoading;
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


//Helpers
- (void)showDeviceList;
- (void)hideDeviceList;
- (void)clearDeviceList;
- (void)setStatusText:(NSString*)text;
- (void)showStatusBar:(NSString*)text;
- (void)showStatusBarError:(NSString*)text;
- (void)showStatusBarInfo:(NSString*)text;
- (void)hideStatusBar;
- (void)showLoadingIcon;
- (void)hideLoadingIcon;
- (BOOL)isDeviceListVisible;
- (BOOL)isStatusBarVisible;
- (void)showSimpleMessageDialog:(NSString*)message;
- (void)showSimpleMessageDialog:(NSString*)message withButton:(NSString*)btnName;

//Bonjour helper functions
- (BOOL)searchForServicesOfType:(NSString *)type inDomain:(NSString *)domain;

//Application logic
- (void)reset;
- (void)restartInitSequenceWithDelay:(float)second;
- (int)numberOfDevices;
- (void)gotoRemoteControlSingleDevice;
- (void)gotoRemoteControl:(NSMutableDictionary*)deviceData;
- (void)gotoRemoteControlDemo;
- (void)initializeSequence;

//Enter the Demo Mode
- (IBAction)enterDemoMode:(id)sender;

@end
