//
//  CommunityViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 31/03/15.
//  Copyright (c) 2015 Pierre Chatel. All rights reserved.
//

#import "CommunityViewController.h"
#import "Constants.h"
#import "UIColor.h"

@interface CommunityViewController ()

@property (strong, nonatomic) UIBarButtonItem *backButtonItem;
@property (strong, nonatomic) UIBarButtonItem *forwardButtonItem;
@property (strong, nonatomic) NSMutableArray *rightBarButtonItems;

@end

@implementation CommunityViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTintColor:[UIColor senbazuruRedColor]];

    self.backButtonItem = [[UIBarButtonItem alloc]
                              initWithImage:[UIImage imageNamed:@"webBack-navbarButton"]
                              style:UIBarButtonItemStylePlain
                              target:self
                              action:@selector(back:)];

    self.forwardButtonItem = [[UIBarButtonItem alloc]
                           initWithImage:[UIImage imageNamed:@"webForward-navbarButton"]
                           style:UIBarButtonItemStylePlain
                           target:self
                           action:@selector(forward:)];
    
    self.rightBarButtonItems = [[NSMutableArray alloc] init];
    [self.rightBarButtonItems addObject:self.forwardButtonItem];
    [self.rightBarButtonItems addObject:self.backButtonItem];
    [self.navigationItem setRightBarButtonItems:self.rightBarButtonItems animated:NO];

    [self.webView setDelegate:self];
    [self loadRequestFromString:SenbazuruCommunityURL];
    
}

#pragma mark - Buttons
- (IBAction)goToCommunityHome:(id)sender {
    [self loadRequestFromString:SenbazuruCommunityURL];
}

- (IBAction)back:(id)sender {
    [self.webView goBack];
}

- (IBAction)forward:(id)sender {
    [self.webView goForward];
}

#pragma mark - Loading URLs
- (void)loadRequestFromString:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    if(!url.scheme)
    {
        NSString* modifiedURLString = [NSString stringWithFormat:@"http://%@", urlString];
        url = [NSURL URLWithString:modifiedURLString];
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}

#pragma mark - Updating the UI

- (void)updateTitle:(UIWebView*)aWebView
{
    NSString* pageTitle = [aWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navBarTitle.title = pageTitle;
}

- (void)updateButtons
{
    self.forwardButtonItem.enabled = self.webView.canGoForward;
    self.backButtonItem.enabled = self.webView.canGoBack;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
    //[self updateTitle:webView];

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}


@end
