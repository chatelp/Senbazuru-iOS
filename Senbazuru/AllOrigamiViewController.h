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
	NSArray *parsedOrigamis;
    NSDateFormatter *formatter;
    NSArray *origamisToDisplay;
    NSArray *searchResults;
}

@end
