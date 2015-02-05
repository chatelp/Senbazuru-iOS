//
//  MyTabBarController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 05/02/15.
//  Copyright (c) 2015 Pierre Chatel. All rights reserved.
//

#import "MyTabBarController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Change elements tint
    UIColor *senbazuruRed = [UIColor colorWithRed:198/255.0f green:33/255.0f blue:39/255.0f alpha:1.0f];
    [self.tabBar setTintColor:senbazuruRed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
