//
//  IconDownloader.m
//  Senbazuru
//
//  Created by Pierre Chatel on 08/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "IconDownloader.h"
#import "DDXML+HTML.h"

#define kAppIconSize 48

@interface IconDownloader ()
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@end


@implementation IconDownloader

#pragma mark

//Scrap content of Senbazuru for this page (through DOM)
-(NSURL *)getImageURL:(NSString*)source {
    NSError *error = nil;
    
    DDXMLDocument *htmlDocument = [[DDXMLDocument alloc]
                                   initWithHTMLString:source
                                   options:HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR
                                   error:&error];
    
    DDXMLElement *rootElement = [htmlDocument rootElement];
    
    NSArray *results = [rootElement nodesForXPath:@"//img" error:&error];
    
    NSString *imageURL = @"http://www.senbazuru.fr/ios/logo_senbazuru_smallest.png";
    
    if ((results != nil) && [results count] > 0) {
        
        //Utiise la 1er image seulement
        DDXMLElement *img = [results objectAtIndex:0];
        DDXMLNode *src = [img attributeForName:@"src"];
        imageURL = [src stringValue];
    
    }
    
    return [NSURL URLWithString:imageURL];
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];

    NSURLRequest *request = [NSURLRequest requestWithURL:[self getImageURL:self.origami.summary]];
    
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    self.imageConnection = conn;
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    if (image.size.width != kAppIconSize || image.size.height != kAppIconSize)
	{
        CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
		UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		self.origami.icon = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
    }
    else
    {
        self.origami.icon = image;
    }
    
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
        
    // call our delegate and tell it that our icon is ready for display
    if (self.completionHandler)
        self.completionHandler();
}

@end

