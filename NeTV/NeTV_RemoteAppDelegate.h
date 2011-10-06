//
//  NeTV_RemoteAppDelegate.h
//  NeTV Remote
//
//  Created by Sidwyn Koh on 6/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NeTVViewController;

@interface NeTV_RemoteAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet NeTVViewController *viewController;

@end
