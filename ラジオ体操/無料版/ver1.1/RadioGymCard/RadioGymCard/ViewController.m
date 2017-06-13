//
//  ViewController.m
//  RadioGymCard
//
//  Created by 近藤 秀彦 on 12/07/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "GameViewController.h"

@interface ViewController ()
@end
@implementation ViewController


#pragma mark -　GameCenter関連
BOOL isGameCenterAPIAvailable()
{
    // GKLocalPlayerクラスが存在するかどうかをチェックする
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) !=
    nil;
    // デバイスはiOS 4.1以降で動作していなければならない
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion]; 
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    return (localPlayerClassAvailable && osVersionSupported);
}


#pragma mark - 起動時の処理
- (void)viewDidLoad
{
   [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
   
   //起動時に広告作成
   // (2) NADView の作成
   nadView_ =[[NADView alloc] initWithFrame:
              CGRectMake(0,0, NAD_ADVIEW_SIZE_320x50.width, NAD_ADVIEW_SIZE_320x50.height )];
   //[nadView_ setNendID:@"a6eca9dd074372c898dd1df549301f277c53f2b9"spotID:@"3172"];     //テスト用
   [nadView_ setNendID:@"35b307f850476a563a37c690b895be2f148a2daf"spotID:@"15483"];  //本番用
   [nadView_ setRootViewController:self]; 
   //(4) 
   [nadView_ setDelegate:self]; 
   //(5) 
   [nadView_ load]; 
   //(6)
   [self.view addSubview:nadView_]; // 最初から表示する場合
   NSLog(@"add");
   
   
   //ゲームセンター
   NSLog(@"ゲームセンター対応チェック%d",isGameCenterAPIAvailable());
   //ゲームセンター対応の有効なバージョンならログイン画面を出す
   if(isGameCenterAPIAvailable() == 1){
      [self authenticateLocalPlayer];
   }
   
   
   
}



//↓広告関連ここから
// 画面遷移が発生するような構造で
// 各controllerごとにNADViewインスタンスを生成する場合には
// pause / resume メッセージを送信し
// 広告の定期受信のローテーションを 一時中断 / 再開 してください

#pragma mark - 広告関連 NADView delegate
-(void)viewWillAppear:(BOOL)animated{
   //起動音再生
   SystemSoundID soundID;
   NSURL* soundURL = [[NSBundle mainBundle] URLForResource:@"start"
                                             withExtension:@"mp3"];
   AudioServicesCreateSystemSoundID ((__bridge CFURLRef)soundURL, &soundID);
   AudioServicesPlaySystemSound (soundID);
   
   // 画面表示時に定期ロードを再開します
   NSLog(@"nadView resume");
   [nadView_ resume];
   
}
// 画面が隠れたら定期ロードを中断します
-(void)viewWillDisappear:(BOOL)animated
{
   NSLog(@"nadView pause");
   [nadView_ pause];
}
-(void)dealloc
{
   // delegateにnilをセットしてリリース
   [nadView_ setDelegate:nil];
}


#pragma mark -  広告関連 NADView control
// NADViewのロードが成功した時に呼ばれる
- (void)nadViewDidFinishLoad:(NADView *)adView
{
   NSLog(@"delegate nadViewDidFinishLoad:");
}

// 広告受信成功
-(void)nadViewDidReceiveAd:(NADView *)adView
{
   NSLog(@"delegate nadViewDidReceiveAd:");
}

// 広告受信エラー
-(void)nadViewDidFailToReceiveAd:(NADView *)adView
{
   NSLog(@"delegate nadViewDidFailToLoad:");
}
//↑広告関連ここまで


- (void)viewDidUnload
{
   [super viewDidUnload];
   // Release any retained subviews of the main view.
}


#pragma mark - gamecenter
//viewDidLoadで呼び出ししている
- (void) authenticateLocalPlayer
{
   GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
   [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
      if (localPlayer.isAuthenticated)
      {
         // 認証済みプレーヤーの追加タスクを実行する
      }
   }];
}


//リーダーボードを立ち上げる
-(IBAction)showBord
{
   GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
   if (leaderboardController != nil)
   {
      leaderboardController.leaderboardDelegate = self;
      [self presentModalViewController: leaderboardController animated: YES];
   }
}


//リーダーボードで完了を押した時に呼ばれる
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
   [self dismissModalViewControllerAnimated:YES];
}




#pragma mark - 画面遷移

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
   if([[segue identifier] isEqualToString:@"SummerMode"]){
      GameViewController *gameView = (GameViewController *)
      [segue destinationViewController];
      gameView.modeFlg = 0;
   }else if([[segue identifier] isEqualToString:@"OneYearMode"]){
      GameViewController *gameView = (GameViewController *)
      [segue destinationViewController];
      gameView.modeFlg = 1;      
   }
}


-(IBAction)linkUdonkonetApps:(id)sender{
   //有料版DLへ
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/jp/app/rajio-ti-cao-inchikisutanpu/id543115513?mt=8&uo=4"]];
}

#pragma mark - 縦横設定
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
