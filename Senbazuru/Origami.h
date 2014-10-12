//
//  Origami.h
//  Senbazuru
//
//  Created by Pierre Chatel on 09/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWFeedItem.h"

@class IconDownloader;

@interface Origami : NSObject


-(Origami *)initWithWrappedItem:(MWFeedItem *)item;

@property (nonatomic, strong) MWFeedItem *wrappedItem;

@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *summary;
@property (nonatomic, readonly) NSString *content;

@property (nonatomic, readonly) NSString *summaryPlainText;
@property (nonatomic, readonly) NSString *contentPlainText;
@property (nonatomic, copy) UIImage *icon;
@property (nonatomic, readonly) NSString *parsedHTML;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) NSURL *videoURL;
@property (nonatomic, readonly) NSString *difficulty;


@property (nonatomic, strong) IconDownloader *iconDownloader;

-(UIImage *) iconWithBlock:(void (^)(void))completionHandler;

@end
