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
#import "UIColor.h"

static NSString *const haikuXMLSource = @"http://senbazuru.fr/ios/haiku.xml";

@implementation AproposViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Google Analytics tracking
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.screenName = @"AproposView iPhone";
    }
    else {
        self.screenName = @"AproposView iPad";
    }
    
    // Display current version / build number
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [self.versionTextView setText:[NSString stringWithFormat:@"version %@ - build %@",
                                   version,
                                   buildNumber]];
    
    // Only display haiky in "A propos" for iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self parseHaikuXMLSource];
    }
    
    //Background pattern
    [self.view setBackgroundColor:[UIColor senbazuruRicePaper2Color]];
    
    //Click on logo setup
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTapOnLogo:)];
    [self.animationView addGestureRecognizer:singleFingerTap];

}

- (void)handleSingleTapOnLogo:(UITapGestureRecognizer *)recognizer {
    [self.animationView startCanvasAnimation];
}

- (void)viewDidAppear:(BOOL)animated {
    // Only display haiky in "A propos" for iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self randomizeDisplay];
    }
}

//Bug ios7 http://stackoverflow.com/questions/19440197/uiviews-ending-up-beneath-tab-bar
- (UIRectEdge)edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom;
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
    if(haikus && [haikus count] > 0) {
        int position = [self randomNumberBetween:0 notIncludingMaxNumber:haikus.count];
        Haiku *haiku = [haikus objectAtIndex:position];
        self.vers1.text = haiku.vers1;
        self.vers2.text = haiku.vers2;
        self.vers3.text = haiku.vers3;
        self.auteur.text = haiku.auteur;
    }
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
