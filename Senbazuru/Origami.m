//
//  Origami.m
//  Senbazuru
//
//  Created by Pierre Chatel on 09/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "Origami.h"

@implementation Origami

-(Origami *)initWithWrappedItem:(MWFeedItem *)item {
    self = [super init];
    
    self.wrappedItem = item;
    return self;
}

@end
