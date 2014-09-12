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
    NSUserDefaults *defaults;
}

@property (assign, nonatomic) Origami *origami;
@property (assign, nonatomic) id delegate;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favoriteButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@end
