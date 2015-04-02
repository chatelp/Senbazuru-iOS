//
//  OrigamiDetailViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 25/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "OrigamiDetailViewController.h"
#import "Constants.h"
#import "DDXMLDocument+HTML.h"
#import "Haiku.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "UIColor.h"

static NSString *const haikuXMLSource = @"http://senbazuru.fr/ios/haiku.xml";

@interface OrigamiDetailViewController ()
@property (assign, nonatomic) id delegate;
@property (strong, nonatomic) NSMutableArray *rightBarButtonItems;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSMutableArray *haikus;
@property (strong, nonatomic) UIBarButtonItem *shareButtonItem;
@property (strong, nonatomic) UIBarButtonItem *backButtonItem;
@property (strong, nonatomic) NSString *baseURL;

@end

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
    
    //Change navigation bar elements tint color (for both iPhone and iPad - no segue needed)
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];

    //Configure NavBar ButtonItems
    self.shareButtonItem = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(shareOrigami:)];
    
    self.backButtonItem = [[UIBarButtonItem alloc]
                           initWithImage:[UIImage imageNamed:@"previous-navbarButton"]
                           style:UIBarButtonItemStylePlain
                           target:self
                           action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = self.backButtonItem;
    
    //Hide NavBar right buttons until origami is assigned
    self.rightBarButtonItems = [[NSMutableArray alloc] init];
    [self.navigationItem setRightBarButtonItems:self.rightBarButtonItems animated:NO];
    
    //Defaults
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    //If origami already assigned, display it (iPhone/segue case)
    [self configureViewForOrigami];
    
    //If iPad, display Haiku
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //Background pattern
        [self.view setBackgroundColor:[UIColor senbazuruRicePaper2Color]];
        //Hide webview to show pattern
        [self.webView setHidden:YES];
        
        [self parseHaikuXMLSource];
        [self randomizeDisplay];
    }
}


// Load HTML Content from Original Origami RSS Data
- (void)loadHTMLContent {
    [self.webView loadHTMLString:self.origami.parsedHTML baseURL:[NSURL URLWithString:@"http://domain.com"]];
}

// Load HTML Content using alternative method (senbazuru source article URL)
- (void)loadHTMLContentAlt {
    self.baseURL = self.origami.linkNoAnchor;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.baseURL]];
    [self.webView loadRequest:request];
}
    
// Update user interface elements for assigned origami
- (void)configureViewForOrigami
{
    if (self.origami && self.isViewLoaded) {
        
        //Hide haiku and display webview
        if(self.haikuView) {
            [self.haikuView setHidden:YES];
            [self.webView setHidden:NO];
        }

        //Load origami content
        self.navigationItem.title = self.origami.title;
        [self loadHTMLContentAlt];
        
        // Google Analytics tracking
        // May return nil if a tracker has not already been initialized with a
        // property ID.
        id tracker = [[GAI sharedInstance] defaultTracker];
        // This screen name value will remain set on the tracker and sent with
        // hits until it is set to a new value or to nil.
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"OrigamiDetailView iPhone: %@", self.origami.title]];
        }
        else {
            [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"OrigamiDetailView iPad: %@", self.origami.title]];
        }
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

        
        //configure navbar buttons
        if(![self.rightBarButtonItems containsObject:self.favoriteButtonItem]) {
            [self.rightBarButtonItems addObject:self.favoriteButtonItem];
        }
        if(!self.origami.videoURL) {
            [self.rightBarButtonItems removeObject:self.shareButtonItem];
        } else if(![self.rightBarButtonItems containsObject:self.shareButtonItem]) {
            [self.rightBarButtonItems addObject:self.shareButtonItem];
        }
        
        [self.navigationItem setRightBarButtonItems:self.rightBarButtonItems animated:YES];
        
        //check favorited status and toggle like button
        NSArray *favorites = [self.defaults arrayForKey:@"Favorites"];
        if(favorites) {
            if([favorites containsObject:self.origami.title]) {
                [_favoriteButton setImage:[UIImage imageNamed:@"like-red_selected"] forState:UIControlStateSelected];
                [_favoriteButton setSelected:YES];
            } else {
                [_favoriteButton setSelected:NO];
            }
        }
    }
}



- (void)parseHaikuXMLSource {
    self.haikus = [NSMutableArray array];
    
    NSURL *sourceURL = [NSURL URLWithString:haikuXMLSource];
    
    NSError *error = nil;
    NSData* data = [NSData dataWithContentsOfURL:sourceURL options:NSDataReadingUncached error:&error];
    if(!error) {
        DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
        if(!error) {
            DDXMLElement *rootElement = [xmlDocument rootElement];
            
            NSArray *results = [rootElement nodesForXPath:@"//haiku" error:&error];
            for (DDXMLElement *haiku in results) {
                NSString *auteurString, *vers1String, *vers2String, *vers3String;
                
                DDXMLNode *auteur = [haiku attributeForName:@"auteur"];
                if(auteur)
                    auteurString = [auteur stringValue];
                NSArray *vers1 = [haiku elementsForName:@"vers1"];
                if(vers1)
                    vers1String = ((DDXMLElement *)vers1.firstObject).stringValue;
                NSArray *vers2 = [haiku elementsForName:@"vers2"];
                if(vers2)
                    vers2String = ((DDXMLElement *)vers2.firstObject).stringValue;
                NSArray *vers3 = [haiku elementsForName:@"vers3"];
                if(vers3)
                    vers3String = ((DDXMLElement *)vers3.firstObject).stringValue;
                
                if(auteurString && vers1String && vers2String && vers3String)
                    [self.haikus addObject:[[Haiku alloc] initWithAuteur:auteurString vers1:vers1String vers2:vers2String vers3:vers3String]];
            }
            
        }
    }
    
}

- (void)randomizeDisplay {
    if(self.haikus && [self.haikus count] > 0) {
        int position = [self randomNumberBetween:0 notIncludingMaxNumber:self.haikus.count];
        Haiku *haiku = [self.haikus objectAtIndex:position];
        self.vers1.text = haiku.vers1;
        self.vers2.text = haiku.vers2;
        self.vers3.text = haiku.vers3;
        self.auteur.text = haiku.auteur;
    }
}

- (NSInteger)randomNumberBetween:(NSInteger)min notIncludingMaxNumber:(NSInteger)max
{
    return min + arc4random_uniform(max - min);
}


// Handle rotation in split view (iPad)
- (void)viewDidAppear:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

// Handle rotation in split view (iPad)
- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

// Update interface when origami is assigned
-(void) setOrigami:(Origami *)origami
{
    _origami = origami;
    [self configureViewForOrigami];
}


#pragma mark -
#pragma mark Actions (buttons, ...)

- (IBAction)shareOrigami:(id)sender {
    
    if(!self.origami)
        return;
    
    NSString *message = @"Je viens de réaliser cet origami grâce à un tutoriel vidéo de Senbazuru.fr ^^";
    NSURL *videoURL = self.origami.videoURL;
    UIImage *imageToShare = self.origami.image;
    
    if(videoURL && imageToShare) {
    
        NSArray *postItems = @[message, imageToShare, videoURL];
    
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                initWithActivityItems:postItems
                                                applicationActivities:nil];
        
        //Available in iOS 8.0 and later.
        if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {

            //Set anchor point (https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIPopoverPresentationController_class/index.html#//apple_ref/occ/instp/UIPopoverPresentationController/barButtonItem)
            activityViewController.popoverPresentationController.barButtonItem = self.shareButtonItem;
        }
        
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}


- (IBAction)favoriteOrigami:(id)sender {
    
    if(!self.origami)
        return;
    
    NSArray *favorites = [self.defaults arrayForKey:@"Favorites"];
    NSMutableArray *mutableFavorites;
    if(favorites) {
        mutableFavorites = [NSMutableArray arrayWithArray:favorites];
    } else {
        mutableFavorites = [[NSMutableArray alloc] init];
    }
    
    if([mutableFavorites containsObject:self.origami.title]) {
        //Remove favorite
        [mutableFavorites removeObject:self.origami.title];
        
        [sender setSelected:NO];

    } else {
        //Add favorite
        [mutableFavorites addObject:self.origami.title];
        
        [sender setImage:[UIImage imageNamed:@"like-red_selected"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
    
    [self.defaults setObject:mutableFavorites forKey:@"Favorites"];
    [self.defaults synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChanged object:self];

}

- (IBAction)aboutSenbazuru:(id)sender {
}

- (IBAction)back:(id)sender {    
    NSString *currentURL = [[self.webView.request URL] absoluteString];
    
    if(self.webView.canGoBack && ![currentURL isEqualToString:self.baseURL]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

#pragma mark -
#pragma mark Web view delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    //Finish Disqus Loging-in
    NSString *loadedURL = [[webView.request URL] absoluteString];
    //NSLog(@"+-+-> URL: %@", destinationURL);
    
    NSString *regexSource = @"^https://disqus.com/_ax/(?:twitter|google|facebook)/complete";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:regexSource
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    int matchNumber = [regex numberOfMatchesInString:loadedURL
                                             options:0
                                               range:NSMakeRange(0, [loadedURL length])];
    if (matchNumber > 0 || error) {
        [self loadHTMLContentAlt];
        return;
    }
    
    if(webView.canGoBack && ![loadedURL isEqualToString:self.baseURL]) {
        [self.backButtonItem setTintColor:[UIColor senbazuruRedColor]];
    } else {
        [self.backButtonItem setTintColor:[UIColor darkGrayColor]];
    }

}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    NSString *destinationURL = [[inRequest URL] absoluteString];
    //NSLog(@"--> URL: %@", destinationURL);
    
    NSString *regexSource = @"disqus.com/next/login-success/";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:regexSource
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    int matchNumber = [regex numberOfMatchesInString:destinationURL
                                             options:0
                                               range:NSMakeRange(0, [destinationURL length])];
    if (matchNumber > 0 || error) {
        [self loadHTMLContentAlt];
        return NO;
    }

//    open external app
//    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
//        [[UIApplication sharedApplication] openURL:[inRequest URL]];
//        return NO;
//    }
    
    return YES;
}


#pragma mark -
#pragma mark iPad UISplitView delegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}


#pragma mark -
#pragma mark Other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
