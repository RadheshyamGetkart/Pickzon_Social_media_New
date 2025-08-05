//
//  BaseViewController.h
//  GIF Master
//
//  Created by My Mac on 3/9/19.
//  Copyright © 2019 My Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StringConstants.h"


@interface BaseViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *mainBackView;


- (void)showProgressView;
- (void)hideProgressView;




@end
