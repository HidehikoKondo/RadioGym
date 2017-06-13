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
@synthesize purchaseButton;
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
   [nadView_ setNendID:@"a6eca9dd074372c898dd1df549301f277c53f2b9"spotID:@"3172"];     //テスト用
   //[nadView_ setNendID:@"b9c5fc7a0e4f79443e35979d5663656596fccd4b"spotID:@"14503"];  //本番用
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
   
   if (![SKPaymentQueue canMakePayments]) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                      message:@"アプリ内課金が制限されています。"
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"OK", nil];
      [alert show];
      //      [alert release];
      return;
   }else {
      NSLog(@"課金できます");
      
      //net.udonko.radioGym.365DaysMode
      NSSet *set = [NSSet setWithObjects:@"net.udonko.radioGym.365DaysMode", nil];
      SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
      productsRequest.delegate = self;
      [productsRequest start];
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
   //   SystemSoundID soundID;
   //   NSURL* soundURL = [[NSBundle mainBundle] URLForResource:@"start"
   //                                             withExtension:@"mp3"];
   //   AudioServicesCreateSystemSoundID ((__bridge CFURLRef)soundURL, &soundID);
   //   AudioServicesPlaySystemSound (soundID);
   //   
   //   // 画面表示時に定期ロードを再開します
   //   NSLog(@"nadView resume");
   //   [nadView_ resume];
   
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
   [self setPurchaseButton:nil];
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
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/jp/app/yubienpitsu/id533103099?mt=8"]];
}

#pragma mark - 縦横設定
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)purchase365Mode:(id)sender {
   
   
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
   NSLog(@"課金処理無効チェック");
   
   // 無効なアイテムがないかチェック
   if ([response.invalidProductIdentifiers count] > 0) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                      message:@"アイテムIDが不正です。"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil, nil];
      [alert show];
      //      [alert release];
      return;
   }else {
      // 購入処理開始
      NSLog(@"課金処理開始");
      
      [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
      for (SKProduct *product in response.products) {
         SKPayment *payment = [SKPayment paymentWithProduct:product];
         [[SKPaymentQueue defaultQueue] addPayment:payment];
      }
   }
   
   
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
   NSLog(@"課金処理無効チェックでエラー");
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
   BOOL purchasing = YES;
   for (SKPaymentTransaction *transaction in transactions) {
      switch (transaction.transactionState) {
            // 購入中
         case SKPaymentTransactionStatePurchasing: {
            NSLog(@"Payment Transaction Purchasing");
            
            break;
         }
            // 購入成功
         case SKPaymentTransactionStatePurchased: {
            NSLog(@"Payment Transaction END Purchased: %@", transaction.transactionIdentifier);
            purchasing = NO;
            

            [self completeUpgradePlus];
            [queue finishTransaction:transaction];
            

            break;

         }
            // 購入失敗
         case SKPaymentTransactionStateFailed: {
            NSLog(@"Payment Transaction END Failed: %@ %@", transaction.transactionIdentifier, transaction.error);
            purchasing = NO;
            // ... アラートを表示 ...
            [queue finishTransaction:transaction];
            break;
         }
            // 購入履歴復元
         case SKPaymentTransactionStateRestored: {
            NSLog(@"Payment Transaction END Restored: %@", transaction.transactionIdentifier);
            // 本来ここに到達しない
            purchasing = NO;
            [queue finishTransaction:transaction];
            break;
         }
      }
   }
   
   if (purchasing == NO) {
      [(UIView *)[self.view.window viewWithTag:21] removeFromSuperview];
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   }
}
// 課金が行われた後、呼び出す
- (void)completeUpgradePlus {
   // アップグレード済みとする
//   [[ZConfig instance] setPlus:YES];
//   [self.tableView reloadData];
   
   //購入ボタンを消す
   purchaseButton.hidden = YES;
}
@end
