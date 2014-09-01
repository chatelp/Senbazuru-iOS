//
//  FirstViewController.h
//  Senbazuru
//
//  Created by Pierre Chatel on 23/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedParser.h"

@interface FirstViewController : UITableViewController <MWFeedParserDelegate> {
    // Parsing
	MWFeedParser *feedParser;
	NSArray *parsedItems;
	
	// Displaying
	NSArray *itemsToDisplay;
	NSDateFormatter *formatter;
    
    // Search
    NSArray *searchResults;

}

@property (nonatomic, retain) NSArray *itemsToDisplay;

@end
