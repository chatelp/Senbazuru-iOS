//
//  AllOrigamiViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 23/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "AllOrigamiViewController.h"
#import "NSString+HTML.h"
#import "MainController.h"
#import "IconDownloader.h"
#import "Origami.h"

@implementation AllOrigamiViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup
	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
    origamisToDisplay = [NSArray array];
    
    // Style des cellules de la recherche
    [self.searchDisplayController.searchResultsTableView setRowHeight:self.tableView.rowHeight];
    
    //Au cas où la notification de fin de parsing serait déjà passée, avant même l'abonnement
    [self itemsParsed:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemsParsed:)
                                                 name:ItemsParsed
                                               object:nil];
    
    
}


#pragma mark -
#pragma mark Parsing

- (void)itemsParsed:(NSNotification *) notification {
    parsedOrigamis = ((MainController *)self.tabBarController).parsedOrigamis;
    [self updateTable];
}


- (void)updateTable {
	origamisToDisplay = [parsedOrigamis sortedArrayUsingDescriptors:
						   [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date"
																				 ascending:NO]]];
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
        return origamisToDisplay.count;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PrototypeCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
    
	// Configure the cell to display
	Origami *origami = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        origami = [searchResults objectAtIndex:indexPath.row];
    } else {
        origami = [origamisToDisplay objectAtIndex:indexPath.row];
    }
    
	if (origami) {
				
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
		cell.textLabel.text = origami.title;
		NSMutableString *subtitle = [NSMutableString string];
		if (origami.date)
            [subtitle appendFormat:@"%@: ", [formatter stringFromDate:origami.date]];
		[subtitle appendString:origami.summaryPlainText];
		cell.detailTextLabel.text = subtitle;

        
        cell.imageView.image = [origami iconWithBlock:^{
            cell.imageView.image = origami.icon;
        }];
	}
    return cell;
}

#pragma mark - Table cell image support


// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if ([origamisToDisplay count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            Origami *origami = [origamisToDisplay objectAtIndex:indexPath.row];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            if (!origami.icon)
                // Avoid icon download if already has an icon
            {
                cell.imageView.image = [origami iconWithBlock:^{
                    cell.imageView.image = origami.icon;
                }];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


#pragma mark -
#pragma mark Storyboard & selection handling

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MWFeedItem *item = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        item = [(Origami *)[searchResults objectAtIndex:indexPath.row] wrappedItem]; //TODO
    } else {
        item = [(Origami *)[origamisToDisplay objectAtIndex:indexPath.row] wrappedItem]; //TODO
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
    searchResults = [origamisToDisplay filteredArrayUsingPredicate:resultPredicate];
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
    
    // terminate all pending download connections
    for (Origami *origami in origamisToDisplay) {
        [origami.iconDownloader cancelDownload];
        origami.iconDownloader = nil;
    }
}

@end
