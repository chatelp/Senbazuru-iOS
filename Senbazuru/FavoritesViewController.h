//
//  FavoritesViewController.h
//  Senbazuru
//
//  Created by Pierre Chatel on 23/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrigamiDetailViewController.h"

@interface FavoritesViewController : UITableViewController <UIScrollViewDelegate> {
   	NSArray *parsedOrigamis;
    NSDateFormatter *formatter;
    NSMutableArray *origamisToDisplay;
    NSArray *searchResults;
    
    // Defaults
    NSUserDefaults *defaults;
    NSArray *favorites;
}

//iPad
@property (strong, nonatomic) OrigamiDetailViewController *detailViewController;

@end
