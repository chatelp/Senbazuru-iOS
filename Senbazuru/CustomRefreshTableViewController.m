//
//  CustomRefreshTableViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 18/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "CustomRefreshTableViewController.h"
#import "Constants.h"

@interface CustomRefreshTableViewController ()

@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIImageView *refresh_spinner;
@property (assign) BOOL isRefreshIconsOverlap;
@property (assign) BOOL isRefreshAnimating;
@property (assign) NSUInteger currentAnimation;
@property (assign) BOOL headDown;

@end

@implementation CustomRefreshTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up the refresh control
    [self setupRefreshControl];
}

- (void)setupRefreshControl
{
    //Initial rotation animation style (for rotation first half)
    self.currentAnimation = UIViewAnimationOptionCurveEaseIn;
    
    //Is logo inversed in the view (due to rotation)
    self.headDown = NO;
    
    // Programmatically inserting a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    // Setup the loading view, which will hold the moving graphics
    self.refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshLoadingView.backgroundColor = [UIColor clearColor];
    self.refreshLoadingView.alpha = 0;
    
    
    // Create the graphic image views
    self.refresh_spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_spinner"]];

    // Add the graphics to the loading view
    [self.refreshLoadingView addSubview:self.refresh_spinner];
    
    // Clip so the graphics don't stick out
    self.refreshLoadingView.clipsToBounds = YES;
    
    // Hide the original spinner icon
    self.refreshControl.tintColor = [UIColor clearColor];
    
    // Add the loading and colors views to our refresh control
    [self.refreshControl addSubview:self.refreshLoadingView];
    
    // Initalize flags
    self.isRefreshIconsOverlap = NO;
    self.isRefreshAnimating = NO;
    
    // When activated, invoke our refresh function
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)refresh:(id)sender{

    // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
    // This is where you'll make requests to an API, reload data, or process information

    [[NSNotificationCenter defaultCenter] postNotificationName:RequestOrigamiSourceRefresh object:self];
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"DONE");
        
        // When done requesting/reloading/processing invoke endRefreshing, to close the control
        [self.refreshControl endRefreshing];
    });
    // -- FINISHED SOMETHING AWESOME, WOO! --
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Get the current size of the refresh controller
    CGRect refreshBounds = self.refreshControl.bounds;
    
    // Distance the table has been pulled >= 0
    CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
    
    // Half the width of the table
    CGFloat midX = self.tableView.frame.size.width / 2.0;
    
    // Calculate the width and height of our graphics
    CGFloat spinnerHeight = self.refresh_spinner.bounds.size.height;
    CGFloat spinnerHeightHalf = spinnerHeight / 2.0;
    
    CGFloat spinnerWidth = self.refresh_spinner.bounds.size.width;
    CGFloat spinnerWidthHalf = spinnerWidth / 2.0;
    
    // Calculate the pull ratio, between 0.0-1.0
    CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), 100.0) / 100.0;
    
    // Change alpha as view is being pulled, but not during animation
    if(!self.refreshControl.isRefreshing)
        self.refreshLoadingView.alpha = pullRatio; // <---
    
    // Set the Y coord of the graphics, based on pull distance
    //CGFloat spinnerY = pullDistance / 2.0 - spinnerHeightHalf;
    CGFloat spinnerY = (self.refreshControl.bounds.origin.y + spinnerHeightHalf);
    
    // Calculate the X coord of the graphics
    CGFloat spinnerX = midX - spinnerWidthHalf;
    
    
    // Set the graphic's frames
    CGRect spinnerFrame = self.refresh_spinner.frame;
    spinnerFrame.origin.x = spinnerX;
    spinnerFrame.origin.y = spinnerY;
    
    self.refresh_spinner.frame = spinnerFrame;
    
    // Set the encompassing view's frames
    refreshBounds.size.height = pullDistance;
    
    self.refreshLoadingView.frame = refreshBounds;
    
    // If we're refreshing and the animation is not playing, then play the animation
    if (self.refreshControl.isRefreshing && !self.isRefreshAnimating) {
        [self animateRefreshView];
    }
    
    NSLog(@"pullDistance: %.1f, pullRatio: %.1f, midX: %.1f, isRefreshing: %i", pullDistance, pullRatio, midX, self.refreshControl.isRefreshing);
}

- (void)animateRefreshView
{
    // Flag that we are animating
    self.isRefreshAnimating = YES;

    [UIView animateWithDuration:0.7
                          delay:0
                        options:self.currentAnimation
                     animations:^{
                         // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                         [self.refresh_spinner setTransform:CGAffineTransformRotate(self.refresh_spinner.transform, M_PI)];
        
                     }
                     completion:^(BOOL finished) {
                         self.headDown = ! self.headDown;
                         // If still refreshing or head still down, keep spinning, else reset
                         if (self.refreshControl.isRefreshing || self.headDown) {
                             if(self.currentAnimation == UIViewAnimationOptionCurveEaseIn)
                                 self.currentAnimation = UIViewAnimationOptionCurveEaseOut;
                             else
                                 self.currentAnimation = UIViewAnimationOptionCurveEaseIn;
                             [self animateRefreshView];
                         }else{
                             [self resetAnimation];
                         }
                     }];
}

- (void)resetAnimation
{
    // Reset our flags and background color
    self.isRefreshAnimating = NO;
    self.isRefreshIconsOverlap = NO;
    self.currentAnimation = UIViewAnimationOptionCurveEaseIn;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
