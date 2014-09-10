//
//  OrigamiDetailViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 25/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "OrigamiDetailViewController.h"
#import "DDXML+HTML.h"

NSString * const FavoritesChanged = @"FavoritesChanged";

@implementation OrigamiDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Init
    [self.webView setDelegate:self];
    self.navigationItem.title = self.item.title;
    
    //Senbazuru scrapping
    NSString *modifiedHTML = [self parseHTML:self.item.summary showVideoButton:YES];
    [self.webView loadHTMLString:modifiedHTML baseURL:[NSURL URLWithString:@"http://domain.com"]];
    
    //NavigationBar additional buttons
    UIBarButtonItem *shareButton         = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                             target:self
                                             action:@selector(shareOrigami:)];
    
  
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.navigationItem.rightBarButtonItems.firstObject, shareButton, nil];
    
    //Defaults
    defaults = [NSUserDefaults standardUserDefaults];
    NSArray *favorites = [defaults arrayForKey:@"Favorites"];
    if(favorites) {
        if([favorites containsObject:self.item.title]) {
            [_favoriteButton setImage:[UIImage imageNamed:@"like-50_selected"] forState:UIControlStateSelected];
            [_favoriteButton setSelected:YES];

        }
    }
    
}

- (IBAction)shareOrigami:(id)sender {
}


//Scrap content of Senbazuru for this page (through DOM)
-(NSString *)parseHTML:(NSString*)source showVideoButton:(BOOL)showVideoButton{
    NSError *error = nil;
    
    DDXMLDocument *htmlDocument = [[DDXMLDocument alloc]
                                   initWithHTMLString:source
                                   options:HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR
                                   error:&error];
    
    DDXMLElement *rootElement = [htmlDocument rootElement];
    
    //1 - change la taille des images
    NSArray *results = [rootElement nodesForXPath:@"//img" error:&error];
    for (DDXMLElement *img in results) {
        
        DDXMLNode *width = [img attributeForName:@"width"];
        DDXMLNode *height = [img attributeForName:@"height"];
        [height detach];
        [width setStringValue:@"300"];
    }
    
    //2 - supprime les <br> supperflus
    results = [rootElement nodesForXPath:@"//br" error:&error];
    for (DDXMLElement *breaks in results) {
        [breaks detach];
    }
    
    //3 - change la taille des videos youtubes OU remplace par des bouttons (CAS <iframe>)
    results = [rootElement nodesForXPath:@"//iframe" error:&error];
    for (DDXMLElement *iframe in results) {
        
        if(showVideoButton) {
        
            DDXMLNode *src = [iframe attributeForName:@"src"];
            NSString *videoURL = [src stringValue];
            NSString *newVideoURL = nil;
            NSLog(@"Video URL: %@", videoURL);
            
            NSString *regexSource = @".*embed/([-a-zA-Z0-9_]+)";
            //@"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
            
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression
                                          regularExpressionWithPattern:regexSource
                                          options:NSRegularExpressionCaseInsensitive
                                          error:&error];
            
            NSTextCheckingResult *match = [regex firstMatchInString:videoURL
                                                            options:0
                                                              range:NSMakeRange(0, [videoURL length])];
            if (match) {
                NSRange videoIDRange = [match rangeAtIndex:1];
                NSString *videoID = [videoURL substringWithRange:videoIDRange];
                NSLog(@"Video ID: %@", videoID);
                newVideoURL = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID];
                NSLog(@"New video URL: %@", newVideoURL);
            }
                                     
            NSString *initString = [NSString stringWithFormat:@"<a href=\"%@\"><img src=\"http://senbazuru.fr/ios/ios_play_video_button.jpg\" width=\"50\" border=\"0\"/></a>",
                                    newVideoURL?newVideoURL:videoURL];
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
    
    //4 - change la taille des videos youtubes OU remplace par des bouttons (CAS <embed>)
    if(results == nil || [results count] == 0) {
        results = [rootElement nodesForXPath:@"//embed" error:&error];
        
        for (DDXMLElement *iframe in results) {
            
            if(showVideoButton) {
                
                DDXMLNode *src = [iframe attributeForName:@"src"];
                NSString *videoURL = [src stringValue];
                NSString *newVideoURL = nil;
                NSLog(@"Video URL: %@", videoURL);
                
                NSString *regexSource = @"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
                //@".*embed/([-a-zA-Z0-9_]+)";
                
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression
                                              regularExpressionWithPattern:regexSource
                                              options:NSRegularExpressionCaseInsensitive
                                              error:&error];
                
                NSTextCheckingResult *match = [regex firstMatchInString:videoURL
                                                                options:0
                                                                  range:NSMakeRange(0, [videoURL length])];
                if (match) {
                    NSRange videoIDRange = [match rangeAtIndex:0];
                    NSString *videoID = [videoURL substringWithRange:videoIDRange];
                    NSLog(@"Video ID: %@", videoID);
                    newVideoURL = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID];
                    NSLog(@"New video URL: %@", newVideoURL);
                }
                
                NSString *initString = [NSString stringWithFormat:@"<a href=\"%@\"><img src=\"http://senbazuru.fr/ios/ios_play_video_button.jpg\" width=\"50\" border=\"0\"/></a>",
                                        newVideoURL?newVideoURL:videoURL];
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
    
    NSString *htmlString = [NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: %i\">%@</span>",
                  @"HelveticaNeue",
                  14,
                  [htmlDocument description]];

    return htmlString;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark Actions (buttons, ...)

- (IBAction)favoriteOrigami:(id)sender {
    
    NSArray *favorites = [defaults arrayForKey:@"Favorites"];
    NSMutableArray *mutableFavorites;
    if(favorites) {
        mutableFavorites = [NSMutableArray arrayWithArray:favorites];
    } else {
        mutableFavorites = [[NSMutableArray alloc] init];
    }
    
    if([mutableFavorites containsObject:self.item.title]) {
        //Remove favorite
        [mutableFavorites removeObject:self.item.title];
        
        [sender setSelected:NO];

    } else {
        //Add favorite
        [mutableFavorites addObject:self.item.title];
        
        [sender setImage:[UIImage imageNamed:@"like-50_selected"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
    
    [defaults setObject:mutableFavorites forKey:@"Favorites"];
    [defaults synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChanged object:self];

}

#pragma mark -
#pragma mark Web view delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

//Ouvrir les URLs à l'extérieur de la webView
-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark Other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
