//
//  FavoritesViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 23/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "FavoritesViewController.h"
#import "NSString+HTML.h"
#import "MainController.h"
#import "OrigamiDetailViewController.h"
#import "IconDownloader.h"

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
	itemsToDisplay = [NSMutableArray array];

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
    parsedItems = ((MainController *)self.tabBarController).parsedItems;
    [self updateTable];
}

- (void)favoritesChanged:(NSNotification *) notification {
    [self updateTable];
}

- (void)updateTable {
    if(!sortedParsedItems)
        sortedParsedItems = [parsedItems sortedArrayUsingDescriptors:
                             [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date"
                                                                                  ascending:NO]]];
    favorites = [defaults arrayForKey:@"Favorites"];
    
    itemsToDisplay = [NSMutableArray array];
    for (MWFeedItem *item in sortedParsedItems) {
        if ([favorites containsObject:item.title]) {
            [itemsToDisplay addObject:item];
        }
    }
    
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return itemsToDisplay.count;
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
        
        // Lazy image loading
        // Only load cached images; defer new downloads until scrolling ends
        if (!item.icon)
        {
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startIconDownload:item forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            cell.imageView.image = [UIImage imageNamed:@"picture-50"];
        }
        else
        {
            cell.imageView.image = item.icon;
        }

		
	}
    return cell;
}

#pragma mark - Table cell image support

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(MWFeedItem *)item forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.item = item;
        [iconDownloader setCompletionHandler:^{
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.imageView.image = item.icon;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if ([itemsToDisplay count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            MWFeedItem *item = [itemsToDisplay objectAtIndex:indexPath.row];
            
            if (!item.icon)
                // Avoid icon download if already has an icon
            {
                [self startIconDownload:item forIndexPath:indexPath];
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
    item = [itemsToDisplay objectAtIndex:indexPath.row];
    
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
#pragma mark Other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
