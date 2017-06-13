//
//  AppListViewController.h
//  RadioGymCard
//
//  Created by 近藤 秀彦 on 12/07/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppListViewController : UIViewController
- (IBAction)backButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *indicatorView;

@end
