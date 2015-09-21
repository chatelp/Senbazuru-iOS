//
//  Haiku.m
//  Senbazuru
//
//  Created by Pierre Chatel on 13/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "Haiku.h"

@implementation Haiku

-(Haiku *)initWithAuteur:(NSString *)auteurString
                   vers1:(NSString *)vers1String
                   vers2:(NSString *)vers2String
                   vers3:(NSString *)vers3String
{
    
    if ((self = [super init])) {
        self.auteur = auteurString;
        self.vers1 = vers1String;
        self.vers2 = vers2String;
        self.vers3 = vers3String;
    }
    
    return self;
}
    
@end
