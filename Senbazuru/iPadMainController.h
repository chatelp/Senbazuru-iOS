//
//  iPadMainController.h
//  Senbazuru
//
//  Created by Pierre Chatel on 11/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedParser.h"

@interface iPadMainController : UISplitViewController <MWFeedParserDelegate> {
    // Parsing
	MWFeedParser *feedParser;
    NSMutableArray *parsedOrigamis;
}

- (void)parseFeed;

@property (nonatomic, copy) NSArray *parsedOrigamis;

@end
