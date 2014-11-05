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
#import "DDXML+HTML.h"

@implementation Origami

@synthesize icon, image, videoURL, parsedHTML;

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
    if(icon == nil) { // Singleton
        [self startIconDownloadWithBlock:completionHandler];
        return [UIImage imageNamed:@"picture"];
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

-(NSString *) parsedHTML {
    if (parsedHTML) { // Singleton
        return parsedHTML;
    }
    
    parsedHTML = [self parseHTML:[self summary] showVideoButton:YES];
    return parsedHTML;
}

-(UIImage *)image {
    if(image) // Singleton
        return image;
    
    NSError *error = nil;
    
    DDXMLDocument *htmlDocument = [[DDXMLDocument alloc]
                                   initWithHTMLString:[self summary]
                                   options:HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR
                                   error:&error];
    
    DDXMLElement *rootElement = [htmlDocument rootElement];
    
    NSArray *results = [rootElement nodesForXPath:@"//img" error:&error];
    if(results && results.count > 0) {
        DDXMLElement *img = results.firstObject;
        DDXMLNode *src = [img attributeForName:@"src"];
        NSString *imageURL = [src stringValue];
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
    }
    
    return image;
}

-(NSURL *)videoURL {
    if(videoURL) // Singleton
        return videoURL;
    
    NSError *error = nil;
    
    DDXMLDocument *htmlDocument = [[DDXMLDocument alloc]
                                   initWithHTMLString:[self summary]
                                   options:HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR
                                   error:&error];
    
    DDXMLElement *rootElement = [htmlDocument rootElement];
    
    
    //1 - Cas iframe
    NSArray *results = [rootElement nodesForXPath:@"//iframe" error:&error];
    if(results && results.count > 0) {
        DDXMLElement *iframe = results.firstObject;
        DDXMLNode *src = [iframe attributeForName:@"src"];
        NSString *URL = [src stringValue];
        NSString *newURL = nil;
        NSLog(@"Video URL: %@", videoURL);
        
        NSString *regexSource = @".*embed/([-a-zA-Z0-9_]+)";
        //@"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:regexSource
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        
        NSTextCheckingResult *match = [regex firstMatchInString:URL
                                                        options:0
                                                          range:NSMakeRange(0, [URL length])];
        if (match) {
            NSRange videoIDRange = [match rangeAtIndex:1];
            NSString *videoID = [URL substringWithRange:videoIDRange];
            NSLog(@"Video ID: %@", videoID);
            newURL = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID];
            NSLog(@"New video URL: %@", newURL);
            videoURL = [NSURL URLWithString:newURL];
            return videoURL;
        }
    }
    
    //2 - Cas embed
    results = [rootElement nodesForXPath:@"//embed" error:&error];
    if(results && results.count > 0) {
        DDXMLElement *iframe = results.firstObject;
        DDXMLNode *src = [iframe attributeForName:@"src"];
        NSString *URL = [src stringValue];
        NSString *newURL = nil;
        NSLog(@"Video URL: %@", videoURL);
        
        NSString *regexSource = @"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
        //@".*embed/([-a-zA-Z0-9_]+)";
        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:regexSource
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        
        NSTextCheckingResult *match = [regex firstMatchInString:URL
                                                        options:0
                                                          range:NSMakeRange(0, [URL length])];
        if (match) {
            NSRange videoIDRange = [match rangeAtIndex:0];
            NSString *videoID = [URL substringWithRange:videoIDRange];
            NSLog(@"Video ID: %@", videoID);
            newURL = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID];
            NSLog(@"New video URL: %@", newURL);
            videoURL = [NSURL URLWithString:newURL];
            return videoURL;
        }
    }

    return videoURL;
}

-(NSString *) difficulty {
    if(!self.wrappedItem.categories || [self.wrappedItem.categories count] == 0)
        return NULL;
    
    for (NSString *category in self.wrappedItem.categories) {
        //attention à la méthode containsString qui n'existe qu'à partir d'iOS8
        if ([category rangeOfString:@"Difficulté"].location != NSNotFound ) {
            
            NSError *error = nil;
            NSString *pattern = @"([★]+)";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:&error];
            NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:category options:0 range:NSMakeRange(0, category.length)];
            NSString *stars = [category substringWithRange:rangeOfFirstMatch];
            NSString * emojiStars = [stars stringByReplacingOccurrencesOfString:@"★" withString:@"\U0001F338"];

            return emojiStars;
        }
    }
    
    return NULL;
}

#pragma mark -
#pragma mark Parsing

//Scrap content of Senbazuru for this page (through DOM)
-(NSString *)parseHTML:(NSString*)source showVideoButton:(BOOL)showVideoButton{
    NSError *error = nil;
    
    DDXMLDocument *htmlDocument = [[DDXMLDocument alloc]
                                   initWithHTMLString:source
                                   options:HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR
                                   error:&error];
    
    DDXMLElement *rootElement = [htmlDocument rootElement];
    
    //1 - Ajout d'un <head> pour redimensionnement auto en fonction de l'écran (rotation,...)
//    NSString *headString = @"<head><meta name=\"viewport\" content=\"width=device-width\" /></head>";
//    DDXMLElement *head = [[DDXMLElement alloc] initWithXMLString:headString error:&error];
//    [rootElement insertChild:head atIndex:0];
   
     //2 - change la police d'écriture et sa taille
    
    NSString *spanString = [NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: %i\"></span>",
                            @"HelveticaNeue",
                            14];
    DDXMLElement *span = [[DDXMLElement alloc] initWithXMLString:spanString error:&error];
    //[DDXMLElement elementWithName:@"span"];
    NSArray *results = [rootElement nodesForXPath:@"//body" error:&error];
    DDXMLElement *body = results.firstObject;
    NSArray *bodyChildren = body.children;
    for(DDXMLNode *node in bodyChildren) {
        [node detach];
    }
    [span setChildren:bodyChildren];
    [body addChild:span];
    
    //3 - change la taille des images
    results = [rootElement nodesForXPath:@"//img" error:&error];
    for (DDXMLElement *img in results) {
        
        DDXMLNode *width = [img attributeForName:@"width"];
        DDXMLNode *height = [img attributeForName:@"height"];
        [height detach];
        [width setStringValue:@"300"];
    }
    
    //4 - supprime les <br> supperflus
    //results = [rootElement nodesForXPath:@"//br" error:&error];
    //for (DDXMLElement *breaks in results) {
    //    [breaks detach];
    //}
    
    //5 - change la taille des videos youtubes OU remplace par des bouttons (CAS <iframe>)
    results = [rootElement nodesForXPath:@"//iframe" error:&error];
    
    for (DDXMLElement *iframe in results) {
        
        if(showVideoButton) {
            
            DDXMLNode *src = [iframe attributeForName:@"src"];
            NSString *URL = [src stringValue];
            NSString *newURL = nil;
            NSLog(@"Video URL: %@", URL);
            
            NSString *regexSource = @".*embed/([-a-zA-Z0-9_]+)";
            //@"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
            
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression
                                          regularExpressionWithPattern:regexSource
                                          options:NSRegularExpressionCaseInsensitive
                                          error:&error];
            
            NSTextCheckingResult *match = [regex firstMatchInString:URL
                                                            options:0
                                                              range:NSMakeRange(0, [URL length])];
            if (match) {
                NSRange videoIDRange = [match rangeAtIndex:1];
                NSString *videoID = [URL substringWithRange:videoIDRange];
                NSLog(@"Video ID: %@", videoID);
                newURL = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID];
                NSLog(@"New video URL: %@", newURL);
            }
            
            NSString *initString = [NSString stringWithFormat:@"<a href=\"%@\"><img src=\"http://senbazuru.fr/ios/ios_play_video_button.jpg\" width=\"150\" border=\"0\"/></a>",
                                    newURL?newURL:URL];
            DDXMLElement *ahref = [[DDXMLElement alloc] initWithXMLString:initString error:&error];
            DDXMLElement *p = (DDXMLElement *)[iframe parent];
            [iframe detach];
            [p addChild:ahref];
            
        } else {
            
            DDXMLNode *width = [iframe attributeForName:@"width"];
            DDXMLNode *height = [iframe attributeForName:@"height"];
            [height detach];
            [width setStringValue:@"300"];
            
        }
        
    }
    
    //6 - change la taille des videos youtubes OU remplace par des bouttons (CAS <embed>)
    if(results == nil || [results count] == 0) {
        results = [rootElement nodesForXPath:@"//embed" error:&error];
        
        for (DDXMLElement *iframe in results) {
            
            if(showVideoButton) {
                
                DDXMLNode *src = [iframe attributeForName:@"src"];
                NSString *URL = [src stringValue];
                NSString *newURL = nil;
                NSLog(@"Video URL: %@", URL);
                
                NSString *regexSource = @"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
                //@".*embed/([-a-zA-Z0-9_]+)";
                
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression
                                              regularExpressionWithPattern:regexSource
                                              options:NSRegularExpressionCaseInsensitive
                                              error:&error];
                
                NSTextCheckingResult *match = [regex firstMatchInString:URL
                                                                options:0
                                                                  range:NSMakeRange(0, [URL length])];
                if (match) {
                    NSRange videoIDRange = [match rangeAtIndex:0];
                    NSString *videoID = [URL substringWithRange:videoIDRange];
                    NSLog(@"Video ID: %@", videoID);
                    newURL = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID];
                    NSLog(@"New video URL: %@", newURL);
                }
                
                NSString *initString = [NSString stringWithFormat:@"<a href=\"%@\"><img src=\"http://senbazuru.fr/ios/ios_play_video_button.jpg\" width=\"150\" border=\"0\"/></a>",
                                        newURL?newURL:URL];
                DDXMLElement *ahref = [[DDXMLElement alloc] initWithXMLString:initString error:&error];
                DDXMLElement *p = (DDXMLElement *)[iframe parent];
                [iframe detach];
                [p addChild:ahref];
                
            } else {
                
                DDXMLNode *width = [iframe attributeForName:@"width"];
                DDXMLNode *height = [iframe attributeForName:@"height"];
                [height detach];
                [width setStringValue:@"300"];
                
            }
        }
    }
    
    
    return [htmlDocument description];
}

@end
