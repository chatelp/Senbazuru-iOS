//
//  CommunityViewController.h
//  Senbazuru
//
//  Created by Pierre Chatel on 31/03/15.
//  Copyright (c) 2015 Pierre Chatel. All rights reserved.
//

#import "GAITrackedViewController.h"

@interface CommunityViewController : GAITrackedViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeButtonItem;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarTitle;

- (IBAction)goToCommunityHome:(id)sender;

@end
