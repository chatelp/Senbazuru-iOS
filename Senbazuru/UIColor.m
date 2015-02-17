//
//  UIColor.m
//  Senbazuru
//
//  Created by Pierre Chatel on 12/02/15.
//  Copyright (c) 2015 Pierre Chatel. All rights reserved.
//

#import "UIColor.h"

@implementation UIColor (Extensions)

+ (UIColor *)senbazuruRedColor {
    return [UIColor colorWithRed:198/255.0f green:33/255.0f blue:39/255.0f alpha:1.0f];
}

+ (UIColor *)searchFieldGrey {
    return [UIColor colorWithRed:234/255.0f green:235/255.0f blue:237/255.0f alpha:1.0f];
}

+ (UIColor *)senbazuruPatternColor {
    UIImage *bgImage = [UIImage imageNamed:@"navbar_bg_waves_pattern"];
    return [UIColor colorWithPatternImage:bgImage];
}



@end
