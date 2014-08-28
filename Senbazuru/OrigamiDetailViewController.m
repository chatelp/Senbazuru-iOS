//
//  OrigamiDetailViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 25/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "OrigamiDetailViewController.h"

@interface OrigamiDetailViewController ()

@end

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
    // Do any additional setup after loading the view.
    
    [_webView setDelegate:self];
    
    NSString *modifiedHTML = [self parseHTMLKiss:_item.summary];
    
    [_webView loadHTMLString:modifiedHTML baseURL:[NSURL URLWithString:@"http://domain.com"]];

}

-(NSString *)parseHTMLKiss:(NSString*)source {
    NSError *error = nil;
    
    //NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"origami" ofType:@"xml"] encoding:NSUTF8StringEncoding error:&error];
    

    DDXMLDocument *htmlDocument = [[DDXMLDocument alloc]
                                   initWithHTMLString:source
                                   options:HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR
                                   error:&error];
   
    
    DDXMLElement *rootElement = [htmlDocument rootElement];
    
//    NSArray *children = [rootElement children];
//    for (DDXMLNode *child in children) {
//        NSLog([child description]);
//    }
    //NSArray *elements = [rootElement elementsForName:@"html"];
    //for (DDXMLElement *element in elements) {
    //    NSLog([element description]);
    //}
    
    NSArray *results = [rootElement nodesForXPath:@"//img" error:&error];
    for (DDXMLElement *img in results) {
        
        DDXMLNode *width = [img attributeForName:@"width"];
        DDXMLNode *height = [img attributeForName:@"height"];
        
        [width setStringValue:@"100"];
        [height setStringValue:@"100"];
    }
    
    NSString *result = [htmlDocument description];
    return result;
}

-(NSString *)parseHTML:(NSString*)source {

    NSData *htmlData = [source dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    
    //NSString* newStr = [NSString stringWithUTF8String:[theData bytes]];
    return source;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)favoriteOrigami:(id)sender {
}

#pragma mark -
#pragma mark Web view delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //[webView reload];
    //    if ([webView respondsToSelector:@selector(scrollView)])
    //    {
    //        UIScrollView *scroll=[webView scrollView];
    //
    //        float zoom=webView.bounds.size.width/scroll.contentSize.width;
    //        [scroll setZoomScale:zoom animated:YES];
    //    }
    
}

@end
