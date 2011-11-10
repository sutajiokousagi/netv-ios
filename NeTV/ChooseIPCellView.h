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
	UILabel *header;
	UILabel *subHeader;
    
    id<ChooseIPCellViewDelegate> delegate;
    
    int tag;	
}

@property (nonatomic, retain) IBOutlet UILabel *header;
@property (nonatomic, retain) IBOutlet UILabel *subHeader;
@property (nonatomic, assign) id delegate;

//UI Events
- (IBAction) onClick;

//Properties
- (int) getTag;
- (void) setTag:(int)tag;

@end
