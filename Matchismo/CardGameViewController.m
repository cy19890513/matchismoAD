//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Martin Mandl on 02.11.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "CardGameViewController.h"
#import "Deck.h"
#import "PlayingCardDeck.h"
#import "CardMatchingGame.h"

@interface CardGameViewController ()

@property (nonatomic, strong) CardMatchingGame *game;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSelector;
@property (strong, nonatomic) IBOutlet UIButton *playADButton;

@end

@implementation CardGameViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set VungleSDK Delegate
    [[VungleSDK sharedSDK] setDelegate:self];
    
}

- (void)dealloc
{
    [[VungleSDK sharedSDK] setDelegate:nil];
}


- (CardMatchingGame *)game
{
    if (!_game) {
        _game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
                                                  usingDeck:[self createDeck]];
        [self changeModeSelector:self.modeSelector];
    }
    return _game;
}

- (Deck *)createDeck
{
    return [[PlayingCardDeck alloc] init];
}
    
- (IBAction)touchDealButton:(UIButton *)sender {
    self.game = nil;
    [self updateUI];
}

- (IBAction)changeModeSelector:(UISegmentedControl *)sender {
    self.game.maxMatchingCards = [[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] integerValue];
}

- (IBAction)touchCardButton:(UIButton *)sender
{
    NSUInteger cardIndex = [self.cardButtons indexOfObject:sender];
    [self.game chooseCardAtIndex:cardIndex];
    [self updateUI];
}

- (void)updateUI
{
    for (UIButton *cardButton in self.cardButtons) {
        NSUInteger cardIndex = [self.cardButtons indexOfObject:cardButton];
        Card *card = [self.game cardAtIndex:cardIndex];
        [cardButton setTitle:[self titleForCard:card]
                    forState:UIControlStateNormal];
        [cardButton setBackgroundImage:[self backgroundImageForCard:card]
                              forState:UIControlStateNormal];
        cardButton.enabled = !card.matched;
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", (int)self.game.score];
}

- (NSString *)titleForCard:(Card *)card
{
    return card.chosen ? card.contents : @"";
}

- (UIImage *)backgroundImageForCard:(Card *)card
{
    return [UIImage imageNamed:card.chosen ? @"cardfront" : @"cardback"];
}

-(void) addPointsAlert: (int) point
{
    NSString *title =[NSString stringWithFormat:@"%d points added", point];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:@"You have succesfully watched an add. Points have added for you."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

    
}

- (IBAction)playAD:(id)sender {
    
    //if not watch prepare sdk and play ad, otherwise add points.
    if(self.game.ifplayAD == NO)
    {
    	VungleSDK* sdk = [VungleSDK sharedSDK];
    	NSError *error;
    	[sdk setLoggingEnabled:YES];
        
        // Dict to set custom ad options
        NSDictionary* options = @{VunglePlayAdOptionKeyUser: @"user",
                                  VunglePlayAdOptionKeyPlacement: @"StoreFront",
                                  // Use this to keep track of metrics about your users
                                  VunglePlayAdOptionKeyExtraInfoDictionary: @{VunglePlayAdOptionKeyExtra1: @"26",
                                                                              VunglePlayAdOptionKeyExtra2: @"Male"}};
   
    	[sdk playAd:self withOptions:options error:&error];
    	if (error) {
      	  NSLog(@"Error encountered playing ad: %@", error);
    	}
    }
    else
    {
        [self.game addPointsForAD];
        [self updateUI];
        [self addPointsAlert:20];
        self.game.ifplayAD = NO;
        
    }

}

#pragma mark - VungleSDK Delegate

- (void)vungleSDKAdPlayableChanged:(BOOL)isAdPlayable {
    
    VungleSDK* sdk = [VungleSDK sharedSDK];
    if (isAdPlayable) {
        NSLog(@"An ad is available for playback");
        self.playADButton.enabled = YES;
    } else {
        NSLog(@"No ads currently available for playback");
        self.playADButton.enabled = NO;
        
    }
    
    // check if it is muted
    if([sdk muted])
        NSLog(@"vungle ad is muted");
    else
        NSLog(@"vungle ad is not muted");
    
    //print user DATA
    if([sdk userData]!=nil && [[sdk userData]count]!=0)
    {
    	for(NSString * key in [[sdk userData] allKeys]) {
      	  NSLog(@"%@ : %@", key, [[[sdk userData] objectForKey:key] description]);
    	}
    }
    else
        NSLog(@"userdata is nil for now.");
    
}

- (void)vungleSDKwillShowAd {
    
    NSLog(@"An ad is about to be played!");
    NSLog(@"turn off sound and pause your game");
}

- (void) vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet {
    if (willPresentProductSheet) {
        //In this case we don't want to resume animations and sound, the user hasn't returned to the app yet
        NSLog(@"The ad presented was tapped and the user is now being shown the App Product Sheet");
        NSLog(@"ViewInfo Dictionary:");
        for(NSString * key in [viewInfo allKeys]) {
            NSLog(@"%@ : %@", key, [[viewInfo objectForKey:key] description]);
        }
        
        
    } else {
        //In this case the user has declined to download the advertised application and is now returning fully to the main app
        //Animations / Sound / Gameplay can be resumed now
        NSLog(@"The ad presented was not tapped - the user has returned to the app");
        NSLog(@"ViewInfo Dictionary:");
        for(NSString * key in [viewInfo allKeys]) {
            NSLog(@"%@ : %@", key, [[viewInfo objectForKey:key] description]);
        }
    }
    
    // if completed watch a video give 20 points.
    if([viewInfo valueForKey:@"completedView"])
    {
        NSLog(@"ad video completed. adding points to the score");
        self.game.ifplayAD = YES;
    }
    
    
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet {
    NSLog(@"The user has downloaded an advertised application and is now returning to the main app");
    //This method can be used to resume animations, sound, etc. if a user was presented a product sheet earlier
    NSLog(@"ah yeah! we sold an app");
}







@end
