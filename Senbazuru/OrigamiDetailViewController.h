//
//  OrigamiDetailViewController.h
//  Senbazuru
//
//  Created by Pierre Chatel on 25/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Origami.h"

@interface OrigamiDetailViewController : UIViewController <UIWebViewDelegate> {
}

@property (assign, nonatomic) Origami *origami;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *favoriteButtonItem;
@property (strong, nonatomic) IBOutlet UIButton *favoriteButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *aboutButtonItem;

//iPad
@property (weak, nonatomic) IBOutlet UIView *haikuView;
@property (weak, nonatomic) IBOutlet UILabel *vers1;
@property (weak, nonatomic) IBOutlet UILabel *vers2;
@property (weak, nonatomic) IBOutlet UILabel *vers3;
@property (weak, nonatomic) IBOutlet UILabel *auteur;

@end
