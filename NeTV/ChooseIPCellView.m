//
//  ChooseIPCellView.m
//

#import "ChooseIPCellView.h"

@implementation ChooseIPCellView

@synthesize header, subHeader;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    tag = -1;
    if (self)
    {
    }
    return self;
}

- (int) getTag
{
    return tag;
}

- (void) setTag:(int)newTag
{
    tag = newTag;
}

- (IBAction) onClick
{
    if (self.delegate == nil || [self.delegate respondsToSelector:@selector(didClick:)])
        return;
	[delegate didClick:self];
}

- (void) viewDidUnload
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
        
    //Delegate is an 'assign' propety, we don't release it
    //But we have to remove reference from it
    self.delegate = nil;
    
    self.header = nil;
    self.subHeader = nil;
}

- (void)dealloc
{   
	[header release];
	[subHeader release];
    [super dealloc];
}

@end
