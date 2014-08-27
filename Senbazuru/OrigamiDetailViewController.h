//
//  OrigamiDetailViewController.h
//  Senbazuru
//
//  Created by Pierre Chatel on 25/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedItem.h"
#import "DDXML.h"

@interface OrigamiDetailViewController : UIViewController {
    
}

@property (assign, nonatomic) MWFeedItem *item;
@property (assign, nonatomic) id delegate;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *testTextField;

@end
