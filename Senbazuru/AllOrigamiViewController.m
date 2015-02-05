//
//  AllOrigamiViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 23/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "AllOrigamiViewController.h"
#import "NSString+HTML.h"
#import "iPhoneMainController.h"
#import "iPadMainController.h"
#import "IconDownloader.h"
#import "Origami.h"
#import "Constants.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@implementation AllOrigamiViewController

#pragma mark -
#pragma mark View lifecycle

- (void)awakeFromNib
{
    //self.clearsSelectionOnViewWillAppear = NO;
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Google Analytics tracking
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id tracker = [[GAI sharedInstance] defaultTracker];
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [tracker set:kGAIScreenName value:@"AllOrigamiView iPhone"];
    }
    else {
        [tracker set:kGAIScreenName value:@"AllOrigamiView iPad"];
    }
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    // Setup
	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
    origamisToDisplay = [NSArray array];
    
    // iPad (splitView)
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.detailViewController = (OrigamiDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        parsedOrigamis = ((iPadMainController *)self.splitViewController).parsedOrigamis;
    } else {
        parsedOrigamis = ((iPhoneMainController *)self.tabBarController).parsedOrigamis;
    }
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
    
	// Configure the cell to display
	Origami *origami = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        origami = [searchResults objectAtIndex:indexPath.row];
    } else {
        origami = [origamisToDisplay objectAtIndex:indexPath.row];
    }
    
	if (origami) {
    
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        
        //Cell Title
		cell.textLabel.text = origami.title;

        //Cell Subtitle
        NSMutableString *subtitle = [NSMutableString string];
        if (origami.date) {
            [subtitle appendString: [formatter stringFromDate:origami.date]];
        }
        if (origami.difficulty) {
            [subtitle appendFormat:@" - Difficulté: %@", origami.difficulty];
        }
		cell.detailTextLabel.text = subtitle;

        //Cell Image
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
    Origami *origami = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        origami = [searchResults objectAtIndex:indexPath.row];
    } else {
        origami = [origamisToDisplay objectAtIndex:indexPath.row];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //For iPad -> due to splitViewUsage can't rely on segue to pass data to OrigamiDetailViewController
        self.detailViewController.origami = origami;
    } else {
        //For iPhone -> use segue to pass data to OrigamiDetailViewController
        [self performSegueWithIdentifier:@"detailSegue" sender:origami];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Change back button (no text - only back arrow glyph)
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    //Prepare destination view
    UIViewController *destination = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"detailSegue"])
        [destination setValue:sender forKeyPath:@"origami"];
 
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
