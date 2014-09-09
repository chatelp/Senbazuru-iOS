//
//  MainController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 30/08/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "MainController.h"

static NSString *const senbazuruRSSfeed = @"http://senbazuru.fr/files/feed.xml";

NSString * const ItemsParsed = @"ItemsParsed";


@interface MainController ()

@end

@implementation MainController


@synthesize parsedItems;

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
    // Do any additional setup after loading the view.
    [self parseFeed];
    
}

- (void)parseFeed {
    parsedItems = [NSMutableArray array];
    
    NSURL *feedURL = [NSURL URLWithString:senbazuruRSSfeed];
	
    feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
	feedParser.delegate = self;
	feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
	feedParser.connectionType = ConnectionTypeAsynchronously;
	[feedParser parse];
}

#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	NSLog(@"Started Parsing: %@", parser.url);
}


- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
	NSLog(@"Parsed Feed Item: “%@”", item.title);
	if (item) [parsedItems addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ItemsParsed object:self];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSLog(@"Finished Parsing With Error: %@", error);
    if (parsedItems.count == 0) {
        [self handleError:error];
    } else {
        // Failed but some items parsed, so show and inform of error
        NSString *errorMessage = [error localizedDescription];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tous les origami n'ont pu être chargés"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    //[self updateTableWithParsedItems]; TODO NOTIFICATION
}

#pragma mark -
#pragma mark Other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Impossible d'accéder au contenu de Senbazuru.fr"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
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

@end
