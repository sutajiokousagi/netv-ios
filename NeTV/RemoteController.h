/*
 
 File: RemoteController.h
 Abstract: This is the remote control UI. Handles simple remote control button presses and photo sharing
 
 For full documentation and source code, please visit: http://wiki.chumby.com/index.php/NeTV_developer_info
 */

#import "BaseController.h"

@interface RemoteController : BaseController
{
    
}
@property (nonatomic, retain) IBOutlet UIButton *btnNavbarBack;
@property (nonatomic, retain) IBOutlet UIImageView *imgCenterDeco;
@property (nonatomic, retain) IBOutlet UIButton *btnCamera;
@property (nonatomic, retain) IBOutlet UILabel *ipAddr;

// Custom Initialization
- (id)initWithIP:(NSString *)theIP;

// UI Events
- (IBAction)pressChumby:(id)sender;
- (IBAction)pressSettings:(id)sender;
- (IBAction)pressUp:(id)sender;
- (IBAction)pressDown:(id)sender;
- (IBAction)pressLeft:(id)sender;
- (IBAction)pressRight:(id)sender;
- (IBAction)pressCenter:(id)sender;
- (IBAction)pressBrowser:(id)sender;
- (IBAction)pressPhoto:(id)sender;
- (IBAction)pressCamera:(id)sender;

@end
