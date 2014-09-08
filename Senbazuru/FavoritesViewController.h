//
//  FavoritesViewController.h
//  Senbazuru
//
//  Created by Pierre Chatel on 23/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesViewController : UITableViewController {
    // Parsing
	NSArray *parsedItems;
    NSArray *sortedParsedItems;
	
	// Displaying
	NSMutableArray *itemsToDisplay;
	NSDateFormatter *formatter;
    
    // Search
    NSArray *searchResults;
    
    // Defaults
    NSUserDefaults *defaults;
    NSArray *favorites;
}

@end
