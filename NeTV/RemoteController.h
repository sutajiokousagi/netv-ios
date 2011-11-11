//
//  RemoteController.h
//  NeTV
//

#import "BaseController.h"

@interface RemoteController : BaseController
{

}
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

@end
