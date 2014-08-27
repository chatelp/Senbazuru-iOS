//
//  SenbazuruFeedItem.m
//  Senbazuru
//
//  Created by Pierre Chatel on 27/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "SenbazuruFeedItem.h"

@implementation SenbazuruFeedItem

-(DDXMLDocument *)getHtmlDOM {
    if (_htmlDOM == nil) {
        
        if(self.summary) {
            _htmlDOM = [[DDXMLDocument alloc] initWithXMLString:self.summary options:0 error:nil];
            NSArray *children = [_htmlDOM children];
        }
    }
    return _htmlDOM;
}

@end
