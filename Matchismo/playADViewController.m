//
//  playADViewController.m
//  Matchismo
//
//  Created by Yang Chen on 5/4/16.
//  Copyright © 2016 m2m server software gmbh. All rights reserved.
//

#import "playADViewController.h"

@interface playADViewController ()

@end

@implementation playADViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set VungleSDK Delegate
    [[VungleSDK sharedSDK] setDelegate:self];
    // Do any additional setup after loading the view.
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

- (IBAction)playAD:(id)sender {
    
    VungleSDK* sdk = [VungleSDK sharedSDK];
    NSError *error;
    [sdk playAd:self error:&error];
    if (error) {
        NSLog(@"Error encountered playing ad: %@", error);
    }
    
}

#pragma mark - VungleSDK Delegate

- (void)vungleSDKAdPlayableChanged:(BOOL)isAdPlayable {
    if (isAdPlayable) {
        NSLog(@"An ad is available for playback");
        //        if (!_showAdButton.enabled || !_showAdWithOptionsButton.enabled) {
        //            [self enableAdButtons:YES];
        //        }
    } else {
        NSLog(@"No ads currently available for playback");
        //        [self enableAdButtons:NO];
    }
}

- (void)vungleSDKwillShowAd {
    NSLog(@"An ad is about to be played!");
    //Use this delegate method to pause animations, sound, etc.
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
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet {
    NSLog(@"The user has downloaded an advertised application and is now returning to the main app");
    //This method can be used to resume animations, sound, etc. if a user was presented a product sheet earlier
}



@end
