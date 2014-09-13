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

static NSString *const haikuXMLSource = @"http://senbazuru.fr/ios/haiku.xml";

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

    //NavigationBar additional buttons
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(shareOrigami:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.navigationItem.rightBarButtonItems.firstObject, shareButton, nil];
    
    //Defaults
    defaults = [NSUserDefaults standardUserDefaults];
    
    //If origami already assigned, display it (iPhone/segue case)
    [self configureView];
    
    //If iPad, display Haiku
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self parseHaikuXMLSource];
        [self randomizeDisplay];
    }
}

// Update user interface elements for assigned origami
- (void)configureView
{
    if (self.origami && self.isViewLoaded) {
        if(self.haikuView)
            [self.haikuView setHidden:YES];
        self.navigationItem.title = self.origami.title;
        [self.webView loadHTMLString:self.origami.parsedHTML baseURL:[NSURL URLWithString:@"http://domain.com"]];
        
        NSArray *favorites = [defaults arrayForKey:@"Favorites"];
        if(favorites) {
            if([favorites containsObject:self.origami.title]) {
                [_favoriteButton setImage:[UIImage imageNamed:@"like-50_selected"] forState:UIControlStateSelected];
                [_favoriteButton setSelected:YES];
            } else {
                [_favoriteButton setSelected:NO];
            }
        }
    }
}

- (void)parseHaikuXMLSource {
    haikus = [NSMutableArray array];
    
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
                    [haikus addObject:[[Haiku alloc] initWithAuteur:auteurString vers1:vers1String vers2:vers2String vers3:vers3String]];
            }
            
        }
    }
    
}

- (void)randomizeDisplay {
    int position = [self randomNumberBetween:0 notIncludingMaxNumber:haikus.count];
    Haiku *haiku = [haikus objectAtIndex:position];
    self.vers1.text = haiku.vers1;
    self.vers2.text = haiku.vers2;
    self.vers3.text = haiku.vers3;
    self.auteur.text = haiku.auteur;
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
    [self configureView];
}


#pragma mark -
#pragma mark Actions (buttons, ...)

- (IBAction)shareOrigami:(id)sender {
    NSString *message = @"Je viens de réaliser cet origami grâce à un tutoriel vidéo de Senbazuru.fr ^^";
    NSURL *videoURL = self.origami.videoURL;
    UIImage *imageToShare = self.origami.image;
    
    if(videoURL && imageToShare) {
    
        NSArray *postItems = @[message, imageToShare, videoURL];
    
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                                initWithActivityItems:postItems
                                                applicationActivities:nil];
    
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}


- (IBAction)favoriteOrigami:(id)sender {
    
    NSArray *favorites = [defaults arrayForKey:@"Favorites"];
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
        
        [sender setImage:[UIImage imageNamed:@"like-50_selected"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
    
    [defaults setObject:mutableFavorites forKey:@"Favorites"];
    [defaults synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChanged object:self];

}

- (IBAction)aboutSenbazuru:(id)sender {
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
