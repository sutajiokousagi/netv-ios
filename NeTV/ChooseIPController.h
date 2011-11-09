//
//  ChooseIPController.h
//  NeTV
//

#import <UIKit/UIKit.h>

@class ChooseIPController;

////////////////////////////////////////////////////////////////////////

@protocol ChooseIPControllerDelegate <NSObject>
@optional
- (void) chooseIPController:(ChooseIPController *)chooseIPController didSelect:(NSMutableDictionary*)selectedData;
@end

@interface ChooseIPController : UITableViewController

- (id)initWithDelegate:(id)theDelegate;
- (void)setData:(NSMutableDictionary *)dict;
- (void)clearData;

@end
