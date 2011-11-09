//
//  RemoteController.h
//  NeTV
//
//  Created by Sidwyn Koh on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommService.h"

@interface RemoteController : UIViewController <AsyncUdpSocketDelegate>{
    CommService *mainComm;
}
@property (nonatomic, retain) NSString *theMainIP;

@property (nonatomic, retain) IBOutlet UILabel *ipAddr;

- (id)initWithIP:(NSString *)theIP;

- (IBAction)pressChumby:(id)sender;
- (IBAction)pressSettings:(id)sender;
- (IBAction)pressUp:(id)sender;
- (IBAction)pressDown:(id)sender;
- (IBAction)pressLeft:(id)sender;
- (IBAction)pressRight:(id)sender;
- (IBAction)pressCenter:(id)sender;
- (IBAction)pressBrowser:(id)sender;
- (IBAction)pressPhoto:(id)sender;

- (void)sendRemoteControlCommand:(NSString*) buttonName;

@end
