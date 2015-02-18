//
//  iPhoneNavigationController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 02/02/15.
//  Copyright (c) 2015 Pierre Chatel. All rights reserved.
//

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "PatternNavigationController.h"
#import "UIColor.h"

@interface PatternNavigationController ()

@end

@implementation PatternNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Change navbar background image
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self.navigationBar setBarTintColor:[UIColor senbazuruPatternColor]];
    } else {
        UIImage *bgImage = [UIImage imageNamed:@"navbar_bg_waves_pattern_transparent"];
        [self.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsLandscapePhone];

    }
        
    //Change font
    [self.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Ubuntu" size:18.0],
      NSFontAttributeName,
      nil]];
}

//- (void)updateConstraintsForTraitCollection:(UITraitCollection *)collection
//{
//    UIImage *bgImage;
//    
//    if (collection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
//        bgImage = nil;
//        
//        if(IS_IPHONE_6){
//            //bgImage = [UIImage imageNamed:@"navbar_background_iPhone6"];
//        }
//        else if(IS_IPHONE_6_PLUS) {
//            //bgImage = [UIImage imageNamed:@"navbar_background_iPhone6Plus"];
//        }
//        else {
//            bgImage = [UIImage imageNamed:@"navbar_background_landscape_iOS8"];
//        }
//        
//    } else {
//        if(IS_IPHONE_6){
//            bgImage = [UIImage imageNamed:@"navbar_background_iPhone6"];
//        }
//        else if(IS_IPHONE_6_PLUS) {
//            bgImage = [UIImage imageNamed:@"navbar_background_iPhone6Plus"];
//        }
//        else {
//            bgImage = [UIImage imageNamed:@"navbar_background"];
//        }
//    }
//    
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,bgImage.size.height - 1,bgImage.size.width - 1)];
//    
//    [self.navigationBar setBackgroundImage:bgImage
//                             forBarMetrics:UIBarMetricsDefault];
//}
//
//- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
//{
//    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
//    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
//        [self updateConstraintsForTraitCollection:newCollection];
//        [self.view setNeedsLayout];
//    } completion:nil];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
