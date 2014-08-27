//
//  SenbazuruFeedItem.h
//  Senbazuru
//
//  Created by Pierre Chatel on 27/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "MWFeedItem.h"
#import "DDXML.h"

@interface SenbazuruFeedItem : MWFeedItem {
    
}

#pragma mark Public Properties
@property (nonatomic, readonly) DDXMLDocument *htmlDOM;

@end
