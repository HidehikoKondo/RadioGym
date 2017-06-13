//
//  GameViewController.m
//  RadioGymCard
//
//  Created by 近藤 秀彦 on 12/07/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
#import <QuartzCore/QuartzCore.h>

//カレンダーがスライドするアニメーションの時間
#define SLIDEINTERVAL 0.3f    
//ゲームの制限時間
#define TIMEUP 365.0f         
#define SUMMERMODE 0
#define YEARMODE 1

@interface GameViewController (){
    NSInteger buttonTag;    //タップしたボタンのタグを格納
    NSInteger month;        //現在表示しているカレンダーの月
    NSDate *startTime;      //タイマスタートの時間
    NSTimer *elapsedTimer;    //タイマ
    NSTimer *slideTimer;    //スライドするときのタイマー
    NSInteger monthEndDay;   // 〜月が30日までか31日までか28日までか・・・を代入。
    UIImage *calenderImage; //カレンダーの画像
    NSInteger endMonth;     //終わりの月が12月か8月か　夏休みか１年モードで変化
    CGFloat elapsedTime;    //経過時間保管用（リーダーボードに送信用）
}
@end

@implementation GameViewController

@synthesize gameOverView;
@synthesize handImageView;

@synthesize startView;
@synthesize stamp1;
@synthesize calender;
@synthesize day1;
@synthesize day2;
@synthesize monthLabel;
@synthesize timeLabel;
@synthesize calenderImageView;
@synthesize perfectLabel;
@synthesize modeFlg;      //0:夏休みモード　1:鬼の365日モード
@synthesize kaikinshouImageView;
@synthesize gameOverImage;
@synthesize resultLabel;

#pragma mark -　GameCenter関連

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



#pragma -mark 起動時初期化処理
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //広告関連
    nadView_ =[[NADView alloc] initWithFrame:
               CGRectMake(0,0, NAD_ADVIEW_SIZE_320x50.width, NAD_ADVIEW_SIZE_320x50.height )]; //NADView の作成
    //[nadView_ setNendID:@"a6eca9dd074372c898dd1df549301f277c53f2b9"spotID:@"3172"];            //テスト用  apiKey, spotId.
    [nadView_ setNendID:@"b9c5fc7a0e4f79443e35979d5663656596fccd4b"spotID:@"14503"];             //本番用  set apiKey, spotId.
    [nadView_ setRootViewController:self]; 
    [nadView_ setDelegate:self]; 
    [nadView_ load]; 
    [self.view addSubview:nadView_]; // 最初から表示する場合
    NSLog(@"add");
    
    
    if(modeFlg == 1){//１年モードなら0　夏休みモードな20日からスタート
        buttonTag = 0;                 //タップされたタグの初期化
    }else{
        buttonTag = 19;                //２０日からボタンが有効           
    }
    monthEndDay = 31;                 //最初の月（１月）は３１日まで
    
    NSLog(@"モード:%d",modeFlg);
    
    if(modeFlg == 0){
        month = 7;                                   //夏休みモードなら7月スタート 
        endMonth = 8;                                //８月で終わり
        calenderImage = [UIImage imageNamed:@"calender31summer.png"];        //7月２０日スタートの画像をセット
        [calenderImageView setImage:calenderImage];
    }else if(modeFlg == 1){
        month = 1;                                   //１年モードなら１月スタート  
        endMonth = 12;                               //１２月で終わり
    }else{
        month = 1;
        endMonth = 12;
    }   
    monthLabel.text = [NSString stringWithFormat:@"%d月",month];   
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [elapsedTimer invalidate];             //経過時間の停止   
    [self setStamp1:nil];
    [self setCalender:nil];
    [self setDay1:nil];
    [self setDay2:nil];
    [self setMonthLabel:nil];
    [self setTimeLabel:nil];
    [self setCalenderImageView:nil];
    [self setPerfectLabel:nil];
    [self setGameOverView:nil];
    [self setStartView:nil];
    [self setHandImageView:nil];
    [self setResultLabel:nil];
    [self setKaikinshouImageView:nil];
    [self setGameOverImage:nil];
    [super viewDidUnload];
}


#pragma -mark ボタンのタッチ処理
- (IBAction)pushStamp:(id)sender {    
    NSLog(@"スタンプ");
    //sender（UIButton）をとりあえず格納（senderに対してsetTranceformしたらエラった）
    UIButton *pushButton = sender;
    
    //手の画像の位置を決める（タップしたボタンの位置から算出）
    CGFloat x;
    CGFloat y;
    x = pushButton.frame.origin.x + 70;
    y = pushButton.frame.origin.y + 70;
    
    //タップしたら手画像を表示
    handImageView.hidden = NO;
    //アニメーション
    handImageView.center = CGPointMake(x,y+10);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
   handImageView.center = CGPointMake(x , y+50);
    [UIView commitAnimations];
    
    
    //押されたボタンのタグが前回押したボタンのタグに１を足した数字と同じだったら、buttonTagにタグを代入
    //つまり、１から順番じゃないと押せないようにする。
    //条件に合わなければ何もせずにリターン   
    if([pushButton tag] == (buttonTag+1)){
        buttonTag = [pushButton tag];
        //スタンプ音再生
        SystemSoundID soundID;
        NSURL* soundURL = [[NSBundle mainBundle] URLForResource:@"stamp"
                                                  withExtension:@"mp3"];
        AudioServicesCreateSystemSoundID ((__bridge CFURLRef)soundURL, &soundID);
        AudioServicesPlaySystemSound (soundID);
        
    }else {
        //ミス音再生
        SystemSoundID soundID;
        NSURL* soundURL = [[NSBundle mainBundle] URLForResource:@"miss"
                                                  withExtension:@"mp3"];
        AudioServicesCreateSystemSoundID ((__bridge CFURLRef)soundURL, &soundID);
        AudioServicesPlaySystemSound (soundID);
        return;
    }
    
    //角度とプラスマイナスのフラグを０に戻す
    NSInteger kakudo = 0;
    NSInteger plusminus = 0;
    
    //ランダムで角度とプラスマイナスのフラグを生成
    srand(time(nil));
    kakudo = rand()%30;
    plusminus = rand()%2;
    
    //プラスマイナスのフラグが０なら-1をかける（左方向に画像を傾ける）
    if(plusminus == 0){
        kakudo *= -1;
    }else {
        kakudo *= 1;
    }   
    NSLog(@"角度:%d   +-:%d",kakudo,plusminus);
    
    //親ビューからはみ出しを許可するかしないか
    [pushButton setClipsToBounds:YES];
    
    //出席スタンプの表示と角度の変更
    UIImage *image = [UIImage imageNamed:@"stamp.png"];
    [pushButton setImage:image forState:UIControlStateNormal];
    CGAffineTransform stamp = CGAffineTransformMakeRotation(kakudo * (M_PI / 180.0f));
    [pushButton setTransform:stamp];
    
    //タップ後、操作不可にする
    [sender setUserInteractionEnabled:NO];
    NSLog(@"%d",[sender tag]);
    
    
    //１ヶ月分出席したらカレンダーを次の月に変える
    //   if(buttonTag == 2){
    
    if(modeFlg == 1){                //１年モード
        if(buttonTag >=20 && buttonTag <= monthEndDay){
            
        }
    }else{                             //夏休みモード
        if(month ==7){                   //7月
        }else{                        //８月
        }
    }
    
    if(buttonTag == monthEndDay){
        //皆勤賞を表示
        [UIView beginAnimations:@"perfect" context:nil];
        //        perfectLabel.alpha = 1;
        kaikinshouImageView.alpha = 1;
        [UIView setAnimationDuration:0.7f];
        //        perfectLabel.alpha = 0;
        kaikinshouImageView.alpha = 0;
        [UIView commitAnimations];
        
        
        
        //指を隠す
        handImageView.hidden = YES;
        
        //カレンダーを左にスライド
        [self slideCalender:-160 yposition:307];
        
        //SLIDEINTERVAL(0.5秒)後にスタンプボタンのクリア
        slideTimer =[NSTimer scheduledTimerWithTimeInterval:SLIDEINTERVAL target:self selector:@selector(clearCalender:) userInfo:nil repeats:NO];
        //      [self clearCalender(timer)];
    }
}


#pragma -mark 月の変更処理
-(void)clearCalender:(NSTimer *)timer{
    NSLog(@"カレンダークリア");
    
    //次の月にインクリメント
    if(month < endMonth){
        month++;
        NSLog(@"%d月",month);
        monthLabel.text = [NSString stringWithFormat:@"%d月",month];
    }else{
        NSLog(@"終わり");
        if(modeFlg == 1){ //１年間モード
            [self gameOver:1];
        }else {// 夏休みモード
            [self gameOver:0];
        }
        
    }
    
    //31：1 3 5 7 8 10 12月  
    //30：4 6 9 11月
    //28：２月
    switch(month){
        case 1:
        case 3:
        case 5:
        case 7:         
        case 8:
        case 10:
        case 12:
            //３１日
            monthEndDay = 31;
            calenderImage = [UIImage imageNamed:@"calender31.png"];
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            //３０日
            monthEndDay = 30;
            calenderImage = [UIImage imageNamed:@"calender30.png"];
            break;
        case 2:
            //２８日（閏年じゃない）
            monthEndDay = 28;
            calenderImage = [UIImage imageNamed:@"calender28.png"];
            break;
        default:
            //該当なしだが、念のため31を入れる
            monthEndDay = 31;
            calenderImage = [UIImage imageNamed:@"calender31.png"];
            break;
    }
    //31,30,28日までのカレンダーを切り替え。
    [calenderImageView setImage:calenderImage];
    NSLog(@"月末:%d日",monthEndDay);
    
    //スタンプ画像を空っぽにする
    UIImage *image = [UIImage imageNamed:@""];
    
    //出席ボタン(tag1〜31)の画像を空っぽの画像に変更
    for(int tag=1; tag<=31; tag++){   
        //tagをキーにしてUIButton型の変数を作成して、画像を変更
        UIButton *calnderButton = (UIButton *)[[self view] viewWithTag:tag];
        [calnderButton setImage:image forState:UIControlStateNormal];
        //角度もまっすぐに戻す（透明だからどっちでもいいけど）
        CGAffineTransform stamp = CGAffineTransformMakeRotation(0 * (M_PI / 180.0f));
        [calnderButton setTransform:stamp];
        //タップ可能にする
        if([calnderButton tag] <= monthEndDay){
            [calnderButton setUserInteractionEnabled:YES];
        }else {
            [calnderButton setUserInteractionEnabled:NO];
        }
    }
    //画面右側にワープ
    calender.center = CGPointMake(480,307);
    //左にスライドするアニメーション
    [self slideCalender:160 yposition:307];
    //buttonTagを０にクリア（押したボタンのタグを記憶している変数）
    buttonTag = 0;
}


//カレンダービューを移動する
-(void)slideCalender:(CGFloat)xpos 
           yposition:(CGFloat)ypos{
    NSLog(@"カレンダースライド");
    //左にスライドするアニメーション
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:SLIDEINTERVAL];
    calender.center = CGPointMake(xpos,ypos);
    [UIView commitAnimations];
    
    //スタンプ音再生
    SystemSoundID soundID;
    NSURL* soundURL = [[NSBundle mainBundle] URLForResource:@"slide"
                                              withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)soundURL, &soundID);
    AudioServicesPlaySystemSound (soundID);
    
}

#pragma -mark 時間計測
- (void)timedisplay:(NSTimer *)timer
{
    NSDate *now=[NSDate date];    //現在の時間を取得   
    //開始時間と現在時間の差分を、少数点以下2桁で表示
    timeLabel.text=
    [NSString stringWithFormat:@"経過時間 : %.2f 秒",[now timeIntervalSinceDate:startTime]];
    
    //経過時間を変数に保管（リーダーボード送信用）
    elapsedTime = [now timeIntervalSinceDate:startTime];
    
    //時間切れでゲームオーバー
    if([now timeIntervalSinceDate:startTime]>TIMEUP){
        [self gameOver:2];
    }
}

#pragma -mark ゲームオーバー・ゲームスタート
//ゲームオーバー　引数はゲームオーバーのビューに表示するメッセージ
//引数 0:夏休み皆勤賞　1:１年間皆勤賞　2:タイムアップ
-(void)gameOver:(NSInteger)message {
    //まずタイマー停止
    [elapsedTimer invalidate];
    
    NSLog(@"%d",message);
    
    //メッセージ画像表示
    if(message == 0){   
        gameOverImage.image = [UIImage imageNamed:@"kaikinshouSummer.png"];
    }else if(message ==1){
        gameOverImage.image = [UIImage imageNamed:@"kaikinshouOneYear.png"];
    }else {
        //タムアップ
        gameOverImage.image = [UIImage imageNamed:@"timeup.png"];
    }
    
    
    
    //ゲームオーバービューを表示
    gameOverView.hidden = NO;
    gameOverView.layer.cornerRadius = 30;
    
    //ゲームオーバービューのアニメーション
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    gameOverView.center = CGPointMake(160,264);
    [UIView commitAnimations];
    
    //月を隠す
    monthLabel.hidden = YES;
    timeLabel.hidden = YES;
    
    //resultLabelに結果を表示
    resultLabel.text = timeLabel.text;
    
    //ゲームオーバー音再生
    SystemSoundID soundID;
    NSURL* soundURL = [[NSBundle mainBundle] URLForResource:@"gameover"
                                              withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)soundURL, &soundID);
    AudioServicesPlaySystemSound (soundID);
    
    
    //リーダーボードに値を送信
    
    if(modeFlg == YEARMODE){//365日モード
        GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"RadioGymTimeAttack"];
        NSLog(@"リーダーボードに送信する値：%d",(int)(elapsedTime*100));
        //      scoreReporter.value = 21;
        scoreReporter.value = (int)(elapsedTime*100);
        
        [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
            if (error != nil)
            {
                // 報告エラーの処理
                NSLog(@"error %@",error);
            }else{
                // リーダーボードに値を送信
                NSLog(@"リーダーボードに値を送信 ３６５モード");            
            }
        }];      
    }else{
        GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"RadioGymTimeAttackSummer"];
        NSLog(@"リーダーボードに送信する値：%d",(int)(elapsedTime*100));
        //   scoreReporter.value = 20;
        scoreReporter.value = (int)(elapsedTime*100);
        [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
            if (error != nil)
            {
                // 報告エラーの処理
                NSLog(@"error %@",error);
            }else{
                // リーダーボードに値を送信
                NSLog(@"リーダーボードに値を送信　夏休みモード");            
            }
        }];
    }
}

- (IBAction)backTop:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)startGame:(id)sender {
    startTime=[NSDate date];                              //スタート時間の取得
    handImageView.hidden = YES;                           //指を隠す
    elapsedTimer = [NSTimer
                    scheduledTimerWithTimeInterval:0.01
                    target:self 
                    selector:@selector(timedisplay:) 
                    userInfo:nil 
                    repeats:YES];                         //タイマー動作開始、0.01秒きざみに設定 
    startView.hidden=YES;                                 //スタート画面を隠す
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//↓広告関連ここから
// 画面遷移が発生するような構造で
// 各controllerごとにNADViewインスタンスを生成する場合には
// pause / resume メッセージを送信し
// 広告の定期受信のローテーションを 一時中断 / 再開 してください

#pragma mark - 広告関連 NADView delegate
-(void)viewWillAppear:(BOOL)animated{    
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

@end