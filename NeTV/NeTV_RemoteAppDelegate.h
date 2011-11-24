//
//  NeTV_RemoteAppDelegate.h
//  NeTV
//

#import <UIKit/UIKit.h>

@class NeTVViewController;

@interface NeTV_RemoteAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet NeTVViewController *viewController;

@end
