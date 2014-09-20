//
//  FavoritesViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 23/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "FavoritesViewController.h"
#import "NSString+HTML.h"
#import "iPhoneMainController.h"
#import "iPadMainController.h"
#import "OrigamiDetailViewController.h"
#import "IconDownloader.h"
#import "Constants.h"

@implementation FavoritesViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup
	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	origamisToDisplay = [NSMutableArray array];

    // iPad (splitView)
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.detailViewController = (OrigamiDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    
    //Defaults
    defaults = [NSUserDefaults standardUserDefaults];

    
    //Au cas où la notification serait déjà passée, avant même l'abonnement
    [self itemsParsed:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemsParsed:)
                                                 name:ItemsParsed
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favoritesChanged:)
                                                 name:FavoritesChanged
                                               object:nil];
}


#pragma mark -
#pragma mark Parsing and updating

- (void)itemsParsed:(NSNotification *) notification {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        parsedOrigamis = ((iPadMainController *)self.splitViewController).parsedOrigamis;
    } else {
        parsedOrigamis = ((iPhoneMainController *)self.tabBarController).parsedOrigamis;
    }
    [self updateTable];
}

- (void)favoritesChanged:(NSNotification *) notification {
    [self updateTable];
}

- (void)updateTable {
    NSArray *sortedParsedOrigamis = [parsedOrigamis sortedArrayUsingDescriptors:
                         [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date"
                                                                              ascending:NO]]];
    favorites = [defaults arrayForKey:@"Favorites"];
    
    origamisToDisplay = [NSMutableArray array];
    for (Origami *origami in sortedParsedOrigamis) {
        if ([favorites containsObject:origami.title]) {
            [origamisToDisplay addObject:origami];
        }
    }
    
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return origamisToDisplay.count;
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
	Origami *origami = [origamisToDisplay objectAtIndex:indexPath.row];
    
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
    Origami *origami = [origamisToDisplay objectAtIndex:indexPath.row];
    
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
    UIViewController *destination = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"detailSegue"])
        [destination setValue:sender forKeyPath:@"origami"];
    
    [destination setValue:self forKeyPath:@"delegate"];
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
