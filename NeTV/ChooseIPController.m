//
//  ChooseIPController.m
//  NeTV
//

#import "ChooseIPController.h"
#import "ChooseIPCellView.h"

// Private implementation
@interface ChooseIPController()

    @property (nonatomic, retain) NSMutableDictionary *tableData;
    @property (nonatomic, assign) id delegate;
    @property (nonatomic, assign) IBOutlet ChooseIPCellView *customCell;

    -(NSMutableDictionary*)getDataAtIndex:(int)index;
    
@end



@implementation ChooseIPController

@synthesize tableData;
@synthesize delegate;
@synthesize customCell;

NSString * const myUniqueChooseIPControllerKey = @"NeTV??????";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDelegate:(id)theDelegate;
{
    self = [super init];
    if (self)
    {
        self.delegate = theDelegate;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"NeTV";
    self.navigationItem.leftBarButtonItem.title = @"Back";
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    if (self.tableData == nil)
        self.tableData = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self clearData];
    self.tableData = nil;
    self.delegate = nil;
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data get/set

-(NSMutableDictionary*)getDataAtIndex:(int)index
{
    if (self.tableData == nil)
        return nil;
    
    int counter = 0;
    for (NSString *key in self.tableData)
    {
        if (counter != index) {
            counter++;
            continue;
        }
        
        NSMutableDictionary *dataObject = [self.tableData objectForKey:key];
        if (dataObject == nil)
            return nil;
        
        //Insert the key into dictionary
        //[dataObject setObject:key forKey:myUniqueChooseIPControllerKey];
        return dataObject;
    }
    return nil;
}

- (void)setData:(NSMutableDictionary *)dict
{
    if (self.tableData != nil)
        [self clearData];
    self.tableData = dict;
    [self.tableView reloadData];
}

- (void)clearData
{
    if (self.tableData == nil)
        return;
    [self.tableData removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.tableData == nil)
        return 0;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (self.tableData == nil)
        return 0;
    return [self.tableData count];
}

//
// Height for each row
//
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (customCell != nil)
        return customCell.frame.size.height;
    
    //This is bad
	return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChooseIPControllerCellIdentifier";
    
    //Reuse or load from Nib
    ChooseIPCellView *cell = (ChooseIPCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"ChooseIPCellView" owner:self options:nil];
        cell = customCell;
	}
    
    //Retrieve data for this cell
    NSMutableDictionary * cellData = [self getDataAtIndex:[indexPath row]];
    if (cellData == nil)
        return cell;
    
    //Assign data to UI
    NSString *ip = [cellData objectForKey:@"ip"];
    NSString *guid = [cellData objectForKey:@"guid"];
    NSString *devicename = [cellData objectForKey:@"devicename"];
    NSString *mac = [cellData objectForKey:@"mac"];
    NSString *fwver = [cellData objectForKey:@"fwver"];
    
    if (devicename != nil && [devicename length] > 0)   cell.header.text = devicename;
    else if (ip != nil && [ip length] > 0)              cell.header.text = ip;
    else if (guid != nil  && [guid length] > 0)         cell.header.text = guid;
    else                                                cell.header.text = @"Unactivated device";
    
    if (mac != nil  && [mac length] > 0)                cell.subHeader.text = [NSString stringWithFormat:@"%@ %@", ip, mac];
    else if (guid != nil  && [guid length] > 0)         cell.subHeader.text = [NSString stringWithFormat:@"%@ %@", ip, guid];
    else                                                cell.subHeader.text = @"";
    
    if (fwver != nil  && [fwver length] > 0)            cell.subHeader2.text = [NSString stringWithFormat:@"ver.%@", fwver];
    else                                                cell.subHeader2.text = @"";
       
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    
    //Remove white spaces
    cell.header.text = [cell.header.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.subHeader.text = [cell.subHeader.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate == nil || [self.delegate respondsToSelector:@selector(chooseIPController: didSelectIP:)])
        return;
    
    NSMutableDictionary * selectedData = [self getDataAtIndex:[indexPath row]];
    if (selectedData == nil)
        return;
    [self.delegate chooseIPController:self didSelect:selectedData];
}

@end
