//
//  AllOrigamiViewController.h
//  Senbazuru
//
//  Created by Pierre Chatel on 23/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrigamiDetailViewController.h"
#import "CustomRefreshTableViewController.h"

@interface AllOrigamiViewController : CustomRefreshTableViewController <UIScrollViewDelegate> {
	NSArray *parsedOrigamis;
    NSDateFormatter *formatter;
    NSArray *origamisToDisplay;
    NSArray *searchResults;
}

//@property (strong, nonatomic) UISearchDisplayController *searchDisplayController;

//iPad
@property (strong, nonatomic) OrigamiDetailViewController *detailViewController;


@end
