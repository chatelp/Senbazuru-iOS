//
//  iPadDetailViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 11/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "iPadDetailViewController.h"
#import "iPadMainController.h"
#import "Constants.h"

@implementation iPadDetailViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemsParsed:)
                                                 name:ItemsParsed
                                               object:nil];
}


- (void)itemsParsed:(NSNotification *) notification {
    NSArray *parsedOrigamis = ((iPadMainController *)self.splitViewController).parsedOrigamis;
    if(parsedOrigamis && parsedOrigamis.count > 0)
        self.origami = parsedOrigamis.firstObject;

}


- (void)setOrigami:(Origami *)origami {
    [self.viewControllers.firstObject setValue:origami forKeyPath:@"origami"];
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

@end
