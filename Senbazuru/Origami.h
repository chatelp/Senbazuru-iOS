//
//  Origami.h
//  Senbazuru
//
//  Created by Pierre Chatel on 09/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWFeedItem.h"


@interface Origami : NSObject

@property (nonatomic, strong) MWFeedItem *wrappedItem;

@property (nonatomic, copy) UIImage *icon;
@property (nonatomic, copy) NSString *imageURLString;
@property (nonatomic, copy) NSString *parsedHTML;

@end
