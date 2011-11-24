/*
 
 File: ChooseIPController.h
 Abstract: An UITableViewController subclass for device list/table UI
 
 For full documentation and source code, please visit: http://wiki.chumby.com/index.php/NeTV_developer_info
 */

#import <UIKit/UIKit.h>

@class ChooseIPController;

////////////////////////////////////////////////////////////////////////

@protocol ChooseIPControllerDelegate <NSObject>
@optional
- (void) chooseIPController:(ChooseIPController *)chooseIPController didSelect:(NSMutableDictionary*)selectedData;
@end

@interface ChooseIPController : UITableViewController
@property (nonatomic, assign) id delegate;

- (id)initWithDelegate:(id)theDelegate;
- (void)setData:(NSMutableDictionary *)dict;
- (void)clearData;

@end
