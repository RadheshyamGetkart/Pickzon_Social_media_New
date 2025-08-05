//
//  BaseViewController.m
//  GIF Master
//
//  Created by My Mac on 3/9/19.
//  Copyright © 2019 My Mac. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (SCREEN_HEIGHT == 812 || SCREEN_HEIGHT == 896) {
        self.mainBackView.frame=CGRectMake(0, 30, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    }
    
}


- (void)showProgressView {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark]; // Style
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat]; //Animation Type
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack]; // Mask Type
    [SVProgressHUD show];
}

- (void)hideProgressView {
    [SVProgressHUD dismiss];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
