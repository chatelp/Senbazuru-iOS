//
//  IconDownloader.h
//  Senbazuru
//
//  Created by Pierre Chatel on 08/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "Origami.h"

@interface IconDownloader : NSObject

@property (nonatomic, strong) Origami *origami;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload;
- (void)cancelDownload;

@end
