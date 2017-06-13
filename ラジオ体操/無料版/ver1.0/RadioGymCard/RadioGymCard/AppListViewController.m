//
//  AppListViewController.m
//  RadioGymCard
//
//  Created by 近藤 秀彦 on 12/07/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppListViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AppListViewController ()

@end

@implementation AppListViewController
@synthesize webView;
@synthesize indicatorView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

   indicatorView.layer.cornerRadius = 10;

   
   NSURL *url = [NSURL URLWithString:@"http://www.udonko.net/apps/applist.html"];
   NSURLRequest *request = [NSURLRequest requestWithURL:url];
   [webView loadRequest:request];
}

- (void)viewDidUnload
{
   [self setWebView:nil];
   [self setIndicatorView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)webViewDidFinishLoad:(UIWebView *)view {
   
   [UIView beginAnimations:nil context:nil];
   [UIView setAnimationDuration:0.7];
   indicatorView.alpha = 0;
   [UIView commitAnimations];   

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backButton:(id)sender {
   [self dismissModalViewControllerAnimated:YES];
}
@end
