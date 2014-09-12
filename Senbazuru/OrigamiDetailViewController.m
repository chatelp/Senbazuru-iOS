//
//  OrigamiDetailViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 25/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "OrigamiDetailViewController.h"
#import "Constants.h"

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

    //If origami already assigned, display it (iPhone/segue case)
    [self configureView];
    
    //NavigationBar additional buttons
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(shareOrigami:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.navigationItem.rightBarButtonItems.firstObject, shareButton, nil];
    
    //Defaults
    defaults = [NSUserDefaults standardUserDefaults];
    NSArray *favorites = [defaults arrayForKey:@"Favorites"];
    if(favorites) {
        if([favorites containsObject:self.origami.title]) {
            [_favoriteButton setImage:[UIImage imageNamed:@"like-50_selected"] forState:UIControlStateSelected];
            [_favoriteButton setSelected:YES];

        }
    }
    
}

// Update user interface elements for assigned origami
- (void)configureView
{
    if (self.origami && self.isViewLoaded) {
        self.navigationItem.title = self.origami.title;
        [self.webView loadHTMLString:self.origami.parsedHTML baseURL:[NSURL URLWithString:@"http://domain.com"]];
    }
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
