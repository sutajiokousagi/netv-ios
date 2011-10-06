//
//  ChooseIPController.h
//  NeTV
//
//  Created by Sidwyn Koh on 16/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommService.h"
@interface ChooseIPController : UITableViewController

@property (nonatomic, retain) NSMutableArray *ipArray;
- (id)initWithArray:(NSMutableArray *)theArray;

@end
