//
//  FirstViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 23/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "FirstViewController.h"
#import "NSString+HTML.h"
#import "MainController.h"

@implementation FirstViewController

@synthesize itemsToDisplay;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup
	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	itemsToDisplay = [NSArray array];
    
    //Au cas où la notification serait déjà passée, avant même l'abonnement
    [self itemsParsed:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemsParsed:)
                                                 name:ItemsParsed
                                               object:nil];
}


#pragma mark -
#pragma mark Parsing

- (void)itemsParsed:(NSNotification *) notification {
    parsedItems = ((MainController *)self.tabBarController).parsedItems;
    [self updateTableWithParsedItems];
}


- (void)updateTableWithParsedItems {
	self.itemsToDisplay = [parsedItems sortedArrayUsingDescriptors:
						   [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date"
																				 ascending:NO]]];
    //self.title = @"Tous les origami";
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return itemsToDisplay.count;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	// Configure the cell to display
	MWFeedItem *item = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        item = [searchResults objectAtIndex:indexPath.row];
    } else {
        item = [itemsToDisplay objectAtIndex:indexPath.row];
    }
    
	if (item) {
		
		// Process
		NSString *itemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
		NSString *itemSummary = item.summary ? [item.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";
		
		// Set
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
		cell.textLabel.text = itemTitle;
		NSMutableString *subtitle = [NSMutableString string];
		if (item.date) [subtitle appendFormat:@"%@: ", [formatter stringFromDate:item.date]];
		[subtitle appendString:itemSummary];
		cell.detailTextLabel.text = subtitle;
		
	}
    return cell;
}


#pragma mark -
#pragma mark Storyboard & selection handling

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MWFeedItem *item = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        item = [searchResults objectAtIndex:indexPath.row];
    } else {
        item = [itemsToDisplay objectAtIndex:indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"detailSegue" sender:item];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destination = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"detailSegue"])
        [destination setValue:sender forKeyPath:@"item"];
    
    [destination setValue:self forKeyPath:@"delegate"];
}

#pragma mark -
#pragma mark Search handling

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    searchResults = [itemsToDisplay filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark -
#pragma mark Other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
