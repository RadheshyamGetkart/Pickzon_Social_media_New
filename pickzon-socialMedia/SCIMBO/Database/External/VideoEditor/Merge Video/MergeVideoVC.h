//
//  MergeVideoVC.h
//  EditorApp
//
//  Created by My Mac on 4/12/19.
//  Copyright © 2019 My Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StringConstants.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DPVideoMerger.h"
#import "HXPhotoView.h"
#import "BaseViewController.h"



static const CGFloat kPhotoViewMargin = 12.0;
static const CGFloat kPhotoViewSectionMargin = 20.0;
@protocol LFVideoMergedControllerDelegate;

@interface MergeVideoVC : BaseViewController<HXPhotoViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) HXPhotoView *onePhotoView;
@property (strong, nonatomic) HXPhotoManager *oneManager;
@property (strong, nonatomic) HXPhotoView *twoPhotoView;
@property (strong, nonatomic) HXPhotoManager *twoManager;
@property (strong, nonatomic) HXPhotoView *threePhotoView;
@property (strong, nonatomic) HXPhotoManager *threeManager;

- (IBAction)onClickBack:(id)sender;
- (IBAction)onClickDone:(id)sender;

@property (nonatomic,strong)IBOutlet UIView *headerView;

@property (nonatomic, strong)NSMutableArray *array_videoURL;
@property (nonatomic, strong)NSURL * mainVideoURL;
@property (nonatomic,strong)UIImage *image_final;
@property (nonatomic,strong)UIColor *maincolor;
@property (nonatomic,strong)UIColor *mainBackcolor;
@property (nonatomic, weak) id<LFVideoMergedControllerDelegate> delegate;

@end



@protocol LFVideoMergedControllerDelegate <NSObject>
- (void)lf_VideoMergedController:(MergeVideoVC *)videoVC didCancelVideoMerged:(NSURL *)url;
- (void)lf_VideoMergedController:(MergeVideoVC *)videoVC didFinishVideoMerged:(NSURL *)url;
@end
