//
//  AllOrigamiViewController.h
//  Senbazuru
//
//  Created by Pierre Chatel on 23/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedParser.h"

@interface AllOrigamiViewController : UITableViewController <UIScrollViewDelegate> {
    // Parsing
	NSArray *parsedItems;
	
	// Displaying
	NSArray *itemsToDisplay;
	NSDateFormatter *formatter;
    
    // Search
    NSArray *searchResults;
}

// the set of ImageDownloader objects for each app
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end
