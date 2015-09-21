//
//  MainController.h
//  Senbazuru
//
//  Created by Pierre Chatel on 30/08/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedParser.h"
#import "MyTabBarController.h"

@interface iPhoneMainController : MyTabBarController <MWFeedParserDelegate> {
    // Parsing
	MWFeedParser *feedParser;
    NSMutableArray *_parsedOrigamis;
}

- (void)parseFeed;

@property (nonatomic, readonly) NSArray *parsedOrigamis;

@end
