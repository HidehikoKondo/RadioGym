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


@interface ViewController : UIViewController<AVAudioPlayerDelegate,NADViewDelegate,GKLeaderboardViewControllerDelegate>{
   //nend用
   NADView *nadView_;

}

@end
