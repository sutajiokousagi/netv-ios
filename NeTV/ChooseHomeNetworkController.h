//
//  ChooseHomeNetworkController.h
//  NeTV
//
//  Created by Sidwyn Koh on 28/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChooseHomeNetworkControllerDelegate;
@class NeTVViewController;
@interface ChooseHomeNetworkController : UITableViewController{
    NSArray *allHomeNetworks;
    NeTVViewController *delegate;
}
@property (nonatomic,assign) NeTVViewController *delegate;

@end


@protocol ChooseHomeNetworkControllerDelegate <NSObject>
@optional
- (void)userFinish;
@end