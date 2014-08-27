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
    
    //NSError *error;
    //NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"origami" ofType:@"xml"] encoding:NSUTF8StringEncoding error:&error];
    //[self parseXML:content];


    //NSString *xmlDecl = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
    //NSString *xml = [xmlDecl stringByAppendingString:_item.summary];
    //[self parseXML:xml];
    
    [self parseXML:_item.summary];
}

-(void)parseXML:(NSString*)source {
    //NSError *error = nil;
    //DDXMLDocument *theDocument = [[DDXMLDocument alloc] initWithXMLString:source options:1 << 9 error:&error];
    //NSArray *results = [theDocument nodesForXPath:@"/bookstore/book[price>35]" error:&error];

    
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

@end
