//
//  ChooseIPCellView.h
//

#import <UIKit/UIKit.h>
@class ChooseIPCellView;

/////////////////////////////////////////////////////////////////////////////////////////

@protocol ChooseIPCellViewDelegate <NSObject>

@optional
- (void) didClick:(ChooseIPCellView *)cell;
@end

////////////////////////////////////////////Ï/////////////////////////////////////////////

@interface ChooseIPCellView : UITableViewCell
{   
    int tag;
}

@property (nonatomic, retain) IBOutlet UILabel *header;
@property (nonatomic, retain) IBOutlet UILabel *subHeader;
@property (nonatomic, retain) IBOutlet UILabel *subHeader2;
@property (nonatomic, assign) id delegate;

//UI Events
- (IBAction) onClick;

//Properties
- (int) getTag;
- (void) setTag:(int)tag;

@end
