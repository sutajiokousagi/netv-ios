/*
 
 File: ChooseHomeNetworkController.h
 Abstract: Undone
 
 For full documentation and source code, please visit: http://wiki.chumby.com/index.php/NeTV_developer_info
 */

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