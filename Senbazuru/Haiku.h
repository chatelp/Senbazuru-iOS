//
//  Haiku.h
//  Senbazuru
//
//  Created by Pierre Chatel on 13/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Haiku : NSObject

-(Haiku *)initWithAuteur:(NSString *)auteurString
                   vers1:(NSString *)vers1String
                   vers2:(NSString *)vers2String
                   vers3:(NSString *)vers3String;

@property (nonatomic, copy) NSString *vers1;
@property (nonatomic, copy) NSString *vers2;
@property (nonatomic, copy) NSString *vers3;
@property (nonatomic, copy) NSString *auteur;

@end
