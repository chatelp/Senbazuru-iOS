//
//  AproposViewController.m
//  Senbazuru
//
//  Created by Pierre Chatel on 13/09/14.
//  Copyright (c) 2014 Pierre Chatel. All rights reserved.
//

#import "AproposViewController.h"
#import "DDXMLDocument+HTML.h"
#import "Haiku.h"

static NSString *const haikuXMLSource = @"http://senbazuru.fr/ios/haiku.xml";

@implementation AproposViewController

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
    
    //[self parseHaikuXMLSource];
}

- (void)viewDidAppear:(BOOL)animated {
    //[self randomizeDisplay];
}

- (void)parseHaikuXMLSource {
    haikus = [NSMutableArray array];

    NSURL *sourceURL = [NSURL URLWithString:haikuXMLSource];
    
    NSError *error = nil;
    NSData* data = [NSData dataWithContentsOfURL:sourceURL options:NSDataReadingUncached error:&error];
    if(!error) {
        DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
        if(!error) {
            DDXMLElement *rootElement = [xmlDocument rootElement];
            
            NSArray *results = [rootElement nodesForXPath:@"//haiku" error:&error];
            for (DDXMLElement *haiku in results) {
                NSString *auteurString, *vers1String, *vers2String, *vers3String;
                
                DDXMLNode *auteur = [haiku attributeForName:@"auteur"];
                if(auteur)
                    auteurString = [auteur stringValue];
                NSArray *vers1 = [haiku elementsForName:@"vers1"];
                if(vers1)
                    vers1String = ((DDXMLElement *)vers1.firstObject).stringValue;
                NSArray *vers2 = [haiku elementsForName:@"vers2"];
                if(vers2)
                    vers2String = ((DDXMLElement *)vers2.firstObject).stringValue;
                NSArray *vers3 = [haiku elementsForName:@"vers3"];
                if(vers3)
                    vers3String = ((DDXMLElement *)vers3.firstObject).stringValue;
                
                if(auteurString && vers1String && vers2String && vers3String)
                    [haikus addObject:[[Haiku alloc] initWithAuteur:auteurString vers1:vers1String vers2:vers2String vers3:vers3String]];
            }

        }
    }

}

- (void)randomizeDisplay {
    int position = [self randomNumberBetween:0 notIncludingMaxNumber:haikus.count];
    Haiku *haiku = [haikus objectAtIndex:position];
    self.vers1.text = haiku.vers1;
    self.vers2.text = haiku.vers2;
    self.vers3.text = haiku.vers3;
    self.auteur.text = haiku.auteur;
}

- (NSInteger)randomNumberBetween:(NSInteger)min notIncludingMaxNumber:(NSInteger)max
{
    return min + arc4random_uniform(max - min);
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
