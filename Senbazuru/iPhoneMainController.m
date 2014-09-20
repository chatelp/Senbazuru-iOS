//
//  MainController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 30/08/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "iPhoneMainController.h"
#import "Origami.h"
#import "Constants.h"

static NSString *const senbazuruRSSfeed = @"http://senbazuru.fr/files/feed.xml";

@implementation iPhoneMainController


@synthesize parsedOrigamis;

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
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestOrigamiSourceRefresh:)
                                                 name:RequestOrigamiSourceRefresh
                                               object:nil];
    
    
}

#pragma mark -
#pragma mark Parsing

- (void)requestOrigamiSourceRefresh:(NSNotification *) notification {
    [self parseFeed];
}

- (void)parseFeed {
    parsedOrigamis = [NSMutableArray array];
    
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
	NSLog(@"Started Parsing: %@", parser.url);
}


- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
	NSLog(@"Parsed Feed Item: “%@”", item.title);
	if (item) {
        [parsedOrigamis addObject:[[Origami alloc] initWithWrappedItem:item]];
    }
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
	NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ItemsParsed object:self];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"Finished Parsing With Error: %@", error);
    if (parsedOrigamis.count == 0) {
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
