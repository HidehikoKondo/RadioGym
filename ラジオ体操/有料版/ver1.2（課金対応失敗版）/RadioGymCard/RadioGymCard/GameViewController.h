//
//  GameViewController.h
//  RadioGymCard
//
//  Created by 近藤 秀彦 on 12/07/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <GameKit/GameKit.h>
#import "NADView.h"  //nend用


@interface GameViewController : UIViewController<AVAudioPlayerDelegate,GKLeaderboardViewControllerDelegate,NADViewDelegate>{

    //nend用
    NADView *nadView_;
}
@property (weak, nonatomic) IBOutlet UIButton *stamp1;
@property (weak, nonatomic) IBOutlet UIView *calender;
@property (weak, nonatomic) IBOutlet UIButton *day1;
@property (weak, nonatomic) IBOutlet UIButton *day2;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *calenderImageView;
@property (weak, nonatomic) IBOutlet UILabel *perfectLabel;
@property (weak, nonatomic) IBOutlet UIView *gameOverView;
@property (weak, nonatomic) IBOutlet UIImageView *handImageView;
@property (weak, nonatomic) IBOutlet UIView *startView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (assign,nonatomic) NSInteger modeFlg;
@property (weak, nonatomic) IBOutlet UIImageView *kaikinshouImageView;
@property (weak, nonatomic) IBOutlet UIImageView *gameOverImage;

- (IBAction)backTop:(id)sender;
- (IBAction)startGame:(id)sender;




@end
