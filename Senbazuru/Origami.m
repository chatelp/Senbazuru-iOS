//
//  Origami.m
//  Senbazuru
//
//  Created by Pierre Chatel on 09/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "Origami.h"
#import "NSString+HTML.h"
#import "IconDownloader.h"

@implementation Origami

@synthesize icon;

-(Origami *)initWithWrappedItem:(MWFeedItem *)item {
    self = [super init];
    
    self.wrappedItem = item;
    return self;
}


#pragma mark -
#pragma mark Wrapper accessors for feed item properties

-(NSDate *) date {
    if(self.wrappedItem)
        return self.wrappedItem.date;
    return nil;
}

-(NSString *) title {
    if(self.wrappedItem)
        return self.wrappedItem.title ? [self.wrappedItem.title stringByConvertingHTMLToPlainText] : @"[No Title]";
    return nil;
}

-(NSString *) summary {
    if(self.wrappedItem)
        return self.wrappedItem.summary ? self.wrappedItem.summary : @"[No Summary]";
    return nil;
}

-(NSString *) content {
    if(self.wrappedItem)
        return self.wrappedItem.content ? self.wrappedItem.content : @"[No Content]";
    return nil;
}

#pragma mark -
#pragma mark Accessor for dedicated origami properties

-(NSString *) summaryPlainText {
    if(self.wrappedItem)
        return self.wrappedItem.summary ? [self.wrappedItem.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";
    return nil;
}

-(NSString *) contentPlainText {
    if(self.wrappedItem)
        return self.wrappedItem.content ? [self.wrappedItem.content stringByConvertingHTMLToPlainText] : @"[No Content]";
    return nil;
}

-(UIImage *) iconWithBlock:(void (^)(void))completionHandler {
    if(icon == nil) {
        [self startIconDownloadWithBlock:completionHandler];
        return [UIImage imageNamed:@"picture-50"];
    }
    return icon;
}

- (void)startIconDownloadWithBlock:(void (^)(void))completionHandler {
    if (self.iconDownloader == nil) {
        self.iconDownloader = [[IconDownloader alloc] init];
        self.iconDownloader.origami = self;
        
        __unsafe_unretained typeof(self) weakSelf = self;
        [self.iconDownloader setCompletionHandler:^{
            
            // Execute external completion handler
            completionHandler();
            
            // This will result in IconDownloader being deallocated.
            weakSelf.iconDownloader = nil;
            
        }];
        
        [self.iconDownloader startDownload];
    }
}

@end
