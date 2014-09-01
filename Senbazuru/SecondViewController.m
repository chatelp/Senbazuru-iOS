//
//  SecondViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 23/07/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "SecondViewController.h"
#import "MainController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //Au cas où la notification serait déjà passée, avant même l'abonnement
    [self itemsParsed:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemsParsed:)
                                                 name:ItemsParsed
                                               object:nil];
}


#pragma mark -
#pragma mark Parsing

- (void)itemsParsed:(NSNotification *) notification {
    parsedItems = ((MainController *)self.tabBarController).parsedItems;
    NSLog(@"SecondViewController: notification received");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
