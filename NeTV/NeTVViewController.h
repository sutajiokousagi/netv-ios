//
//  NeTVViewController.h
//  NeTV
//
//  Created by Sidwyn Koh on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/NSNetServices.h>
#import "AsyncUdpSocket.h"
#import "CommService.h"
#import "ChooseIPController.h"
#import "ChooseHomeNetworkController.h"
#import "ASIHTTPRequest.h"


@interface NeTVViewController : UIViewController <AsyncUdpSocketDelegate, ChooseHomeNetworkControllerDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate, ChooseIPControllerDelegate>
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

    //Communication
    CommService *mainComm;
	
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
    NSMutableArray *_ipListForUI;
}

//UI Events
-(IBAction)onNavbarBack:(id)sender;

//Helpers
- (void)showDeviceListDialog;
- (void)showDeviceList;
- (void)hideDeviceList;
- (void)clearDeviceList;
- (void)setStatusText:(NSString*)text;
- (void)restartInitSequenceWithDelay:(float)second;
- (void)showSimpleMessageDialog:(NSString*)message;
- (void)showSimpleMessageDialog:(NSString*)message withButton:(NSString*)btnName;

//To be moved to a base class
- (void)sendHandshake;
- (void)sendNetworkConfig;
- (void)sendWifiScan;
- (NSString*)getGUIDDeviceName:(NSString*)guid;

//Bonjour helper functions
- (BOOL)searchForServicesOfType:(NSString *)type inDomain:(NSString *)domain;

//Copy from Android app
- (void)reset;
- (void)initializeSequence;

@end
