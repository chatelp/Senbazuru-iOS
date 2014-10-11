//
//  AproposViewController.h
//  Senbazuru
//
//  Created by Pierre Chatel on 13/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AproposViewController : UIViewController {
    NSMutableArray *haikus;
}

@property (weak, nonatomic) IBOutlet UITextView *versionTextView;

// Only display haiky in "A propos" for iPhone
@property (weak, nonatomic) IBOutlet UILabel *vers1;
@property (weak, nonatomic) IBOutlet UILabel *vers2;
@property (weak, nonatomic) IBOutlet UILabel *vers3;
@property (weak, nonatomic) IBOutlet UILabel *auteur;

@end
