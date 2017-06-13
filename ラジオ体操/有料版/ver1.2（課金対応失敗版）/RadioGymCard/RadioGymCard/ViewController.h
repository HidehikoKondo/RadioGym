//
//  ViewController.h
//  RadioGymCard
//
//  Created by 近藤 秀彦 on 12/07/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import "NADView.h"  //nend用
#import <GameKit/GameKit.h>
#import <StoreKit/StoreKit.h>


@interface ViewController : UIViewController<
   AVAudioPlayerDelegate,
   NADViewDelegate,
   GKLeaderboardViewControllerDelegate,
   SKProductsRequestDelegate,
   SKPaymentTransactionObserver>
{
   //nend用
   NADView *nadView_;

}
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
- (IBAction)purchase365Mode:(id)sender;

@end
