//
//  NeTVViewController.h
//  NeTV
//
//  Created by Sidwyn Koh on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"
#import "CommService.h"
#import "ChooseHomeNetworkController.h"


@interface NeTVViewController : UIViewController <AsyncUdpSocketDelegate, ChooseHomeNetworkControllerDelegate>{
    IBOutlet UITextField *SSIDName;
    IBOutlet UITextField *SSIDPassword;
    AsyncUdpSocket *asyncSocket;
    CommService *mainComm;
    NSTimer *mainTimer;
    NSUInteger numberOfSecondsSoFar;
    IBOutlet UILabel *statusLabel;
    
    BOOL sentWifiDetails;
    BOOL currentlySpammingHello;
    
    NSMutableArray *fullIPList;
}

- (void)beginTimer;
- (IBAction)sendData:(id)sender;
- (void)helloDone;
- (void)spamHello;
- (IBAction)spamHelloIB:(id)sender;
- (IBAction)wifiScan:(id)sender;
@end
