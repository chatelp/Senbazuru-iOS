//
//  MainController.h
//  Senbazuru
//
//  Created by Pierre Chatel on 30/08/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedParser.h"

@interface MainController : UITabBarController <MWFeedParserDelegate> {
    // Parsing
	MWFeedParser *feedParser;
    NSMutableArray *parsedOrigamis;
}

- (void)parseFeed;

@property (nonatomic, copy) NSArray *parsedOrigamis;

@end
