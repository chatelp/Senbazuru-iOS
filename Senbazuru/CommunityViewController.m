//
//  CommunityViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 31/03/15.
//  Copyright (c) 2015 Pierre Chatel. All rights reserved.
//

#import "CommunityViewController.h"

@implementation CommunityViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Init
    [self.webView setDelegate:self];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://disqus.com/home/forum/senbazurusorigami-france/"]];
    [self.webView loadRequest:request];
    
}

@end
