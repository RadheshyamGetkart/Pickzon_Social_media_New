//
//  MergeVideoVC.m
//  EditorApp
//
//  Created by My Mac on 4/12/19.
//  Copyright © 2019 My Mac. All rights reserved.
//

#import "MergeVideoVC.h"

@interface MergeVideoVC ()

@end

@protocol LFVideoMergedControllerDelegate;

@implementation MergeVideoVC


- (HXPhotoManager *)twoManager {
    if (!_twoManager) {
        _twoManager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypeVideo];
        _twoManager.configuration.videoMaximumDuration = 10.f;
        _twoManager.configuration.videoMaxNum = 10;
        _twoManager.configuration.maxNum = 10;
    }
    return _twoManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //THIS IS FOR IPHONE X SERIES TOP BACKGROUND HEADER COLOR
    if (SCREEN_HEIGHT == 812 || SCREEN_HEIGHT == 896) {
        UIView *view_header = [[UIView alloc]init];
        view_header.frame = CGRectMake(0, 0, SCREEN_WIDTH, 30);
        view_header.backgroundColor = self.maincolor;
        [self.view addSubview:view_header];
    }
    
    self.headerView.backgroundColor = self.maincolor;
    self.view.backgroundColor = self.mainBackcolor;
    
    self.array_videoURL = [[NSMutableArray alloc]init];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, self.mainBackView.frame.size.height-64-50)];
    self.scrollView.alwaysBounceVertical = YES;
    [self.mainBackView addSubview:self.scrollView];
    
    if (self.mainVideoURL != nil) {
        [self.twoManager addLocalVideo:[NSArray arrayWithObject:self.mainVideoURL] selected:true];
    }
    
    self.twoPhotoView = [[HXPhotoView alloc] initWithFrame:CGRectMake(kPhotoViewMargin, CGRectGetMaxY(self.onePhotoView.frame) + kPhotoViewSectionMargin, self.view.frame.size.width - kPhotoViewMargin * 2, 0) manager:self.twoManager];
    
   
    self.twoPhotoView.delegate = self;
    [self.twoPhotoView refreshView];
    
    [self.scrollView addSubview:self.twoPhotoView];
    [self.scrollView reloadInputViews];
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = true;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = false;
    [super viewWillDisappear:animated];
}

- (void)didCleanClick {
    [self.oneManager clearSelectedList];
    [self.twoManager clearSelectedList];
    [self.threeManager clearSelectedList];
    [self.onePhotoView refreshView];
    [self.twoPhotoView refreshView];
    [self.threePhotoView refreshView];
}

- (void)photoView:(HXPhotoView *)photoView changeComplete:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photos videos:(NSArray<HXPhotoModel *> *)videos original:(BOOL)isOriginal {
    if (self.twoPhotoView == photoView) {
        NSSLog(@"twoPhotoView - %@",allList);
        
        [self.array_videoURL removeAllObjects];
        
        for (int i=0; i<videos.count; i++) {
            HXPhotoModel *model = [videos objectAtIndex:i];
            [self.array_videoURL addObject:model.fileURL];
        }
    }
}

- (void)photoView:(HXPhotoView *)photoView updateFrame:(CGRect)frame {
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.twoPhotoView.frame) + kPhotoViewMargin);
}

- (IBAction)onClickDone:(id)sender {
    
    if (self.array_videoURL.count <2) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Oops!"
                                     message:@"Please select minimum 2 videos"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        
                                    }];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else
    {
        [self mergeVideo];
    }
    
}

#pragma mark - Merge Video Code




- (void)mergeVideo
{
    [self showProgressView];
    
    AVMutableVideoComposition *videoComposition = nil;
    AVMutableAudioMix *audioMix = nil;
    videoComposition = [AVMutableVideoComposition videoComposition];
    audioMix = [AVMutableAudioMix audioMix];
    
    NSUInteger listCount = self.array_videoURL.count;
    
    //Create File URL Array
    NSMutableArray *fileURLArray = [[NSMutableArray alloc]init];
    
    for(NSInteger i = 0; i<listCount; i++) {
        [fileURLArray addObject:[self.array_videoURL objectAtIndex:i]];
    }
    
    //Create Video Range Array
    NSMutableArray *clips = [[NSMutableArray alloc]init];
    NSMutableArray *clipTimeRanges = [[NSMutableArray alloc]init];
    CGSize videoSize = CGSizeZero;
        
    for (int i=0; i<fileURLArray.count; i++) {
        
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[fileURLArray objectAtIndex:i] options:options];
        [clips addObject:asset];
        
        [clipTimeRanges addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(0, 1000), CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration), 1000))]];
        
        AVAssetTrack *videoAsset = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        CGSize videoSizeCheck = videoAsset.naturalSize;
        
        UIInterfaceOrientation mode = [self checkVideoTrack:asset];
        
        if (mode == UIInterfaceOrientationPortrait)
        {
            if (videoSizeCheck.width>videoSizeCheck.height) {
                videoSizeCheck.width = videoAsset.naturalSize.height;
                videoSizeCheck.height = videoAsset.naturalSize.width;
            }
        }
        else if (mode == UIInterfaceOrientationLandscapeLeft)
        {
            if (videoSizeCheck.width<videoSizeCheck.height) {
                videoSizeCheck.width = videoAsset.naturalSize.height;
                videoSizeCheck.height = videoAsset.naturalSize.width;
            }
        }
        else if (mode == UIInterfaceOrientationLandscapeRight)
        {
            if (videoSizeCheck.width<videoSizeCheck.height) {
                videoSizeCheck.width = videoAsset.naturalSize.height;
                videoSizeCheck.height = videoAsset.naturalSize.width;
            }
        }
        else if (mode == UIInterfaceOrientationPortraitUpsideDown)
        {
            if (videoSizeCheck.width>videoSizeCheck.height) {
                videoSizeCheck.width = videoAsset.naturalSize.height;
                videoSizeCheck.height = videoAsset.naturalSize.width;
            }
        }
        
        
        if (CGSizeEqualToSize(videoSize, CGSizeZero)) {
            videoSize = videoSizeCheck;
        }
        if (videoSize.height < videoSizeCheck.height){
            videoSize.height = videoSizeCheck.height;
        }
        if (videoSize.width < videoSizeCheck.width){
            videoSize.width = videoSizeCheck.width;
        }
    }
    
    
    
    BOOL anyAudio = NO;
    
    for (int i=0; i<fileURLArray.count; i++) {
        
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[fileURLArray objectAtIndex:i] options:options];
        
        anyAudio = [asset tracksWithMediaType:AVMediaTypeAudio].count > 0;
        
        if (anyAudio) {
            break;
        }
    }
    
    
    CMTime nextClipStartTime = kCMTimeZero;
    NSInteger i;
    NSUInteger clipsCount = [clips count];
    
    
    
    CGSize videoSizeX = videoSize;
    
    // Make transitionDuration no greater than half the shortest clip duration.
    AVMutableComposition *composition = [AVMutableComposition composition];
    composition.naturalSize = videoSizeX;
    
    
    AVMutableCompositionTrack *compositionVideoTracks[2];
    compositionVideoTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionVideoTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    AVMutableCompositionTrack *b_compositionAudioTrack[2];
    
    if (anyAudio) {
        b_compositionAudioTrack[0] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        b_compositionAudioTrack[1] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    }
    
    
    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * clipsCount);
    CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * clipsCount);
    
    for (i = 0; i < clipsCount; i++ )
    {
        NSInteger    alternatingIndex = i % 2;
        AVURLAsset   *asset = [clips objectAtIndex:i];
        AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        NSValue     *clipTimeRange = [clipTimeRanges objectAtIndex:i];
        CMTimeRange  timeRangeInAsset= [clipTimeRange CMTimeRangeValue];
        
        [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
        // [compositionVideoTracks[alternatingIndex] setPreferredTransform:[[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
        
        
        if (anyAudio) {
            //Audio Add
            AVAssetTrack *audioAsset = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
            NSError *audioError;
            
            BOOL hasAudio = [asset tracksWithMediaType:AVMediaTypeAudio].count > 0;
            if (hasAudio) {
                [b_compositionAudioTrack[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:audioAsset atTime:nextClipStartTime error:&audioError];
            }
        }
        
        passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);
        
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
        transitionTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, kCMTimeZero);
    }
    
    
    
    NSMutableArray *instructions = [NSMutableArray array];
    
    for (i = 0; i < clipsCount; i++ ) {
        
        NSInteger alternatingIndex = i % 2;
        
        // Pass through clip i.
        AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        passThroughInstruction.timeRange = passThroughTimeRanges[i];
        AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
        
        AVURLAsset *asset = [clips objectAtIndex:i];
        AVAssetTrack *videoAsset = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        
        CGAffineTransform transformToApply = videoAsset.preferredTransform;
        CGSize videoSizeCheck = videoAsset.naturalSize;
        
        
        UIInterfaceOrientation mode = [self checkVideoTrack:asset];
        
        if (mode == UIInterfaceOrientationPortrait)
        {
            if (videoSizeCheck.width>videoSizeCheck.height) {
                videoSizeCheck.width = videoAsset.naturalSize.height;
                videoSizeCheck.height = videoAsset.naturalSize.width;
            }
        }
        else if (mode == UIInterfaceOrientationLandscapeLeft)
        {
            if (videoSizeCheck.width<videoSizeCheck.height) {
                videoSizeCheck.width = videoAsset.naturalSize.height;
                videoSizeCheck.height = videoAsset.naturalSize.width;
            }
        }
        else if (mode == UIInterfaceOrientationLandscapeRight)
        {
            if (videoSizeCheck.width<videoSizeCheck.height) {
                videoSizeCheck.width = videoAsset.naturalSize.height;
                videoSizeCheck.height = videoAsset.naturalSize.width;
            }
        }
        else if (mode == UIInterfaceOrientationPortraitUpsideDown)
        {
            if (videoSizeCheck.width>videoSizeCheck.height) {
                videoSizeCheck.width = videoAsset.naturalSize.height;
                videoSizeCheck.height = videoAsset.naturalSize.width;
            }
        }
        
        
        int tx = 0;
        if (videoSizeX.width-videoSizeCheck.width != 0)
        {
            tx = (videoSizeX.width-videoSizeCheck.width)/2;
        }
        int ty = 0;
        if (videoSizeX.height-videoSizeCheck.height != 0)
        {
            ty = (videoSizeX.height-videoSizeCheck.height)/2;
        }
        CGAffineTransform Scale = CGAffineTransformMakeScale(1,1);
        
        if (tx != 0 && ty!=0)
        {
            if (tx <= ty) {
                float factor = videoSizeX.width/videoSizeCheck.width;
                Scale = CGAffineTransformMakeScale(factor,factor);
                tx = 0;
                ty = (videoSizeX.height-videoSizeCheck.height*factor)/2;
            }
            if (tx > ty) {
                float factor = videoSizeX.height/ videoSizeCheck.height;
                Scale = CGAffineTransformMakeScale(factor,factor);
                ty = 0;
                tx = (videoSizeX.width-videoSizeCheck.width*factor)/2;
            }
        }
        
        CGAffineTransform Move = CGAffineTransformMakeTranslation(tx,ty);
        
        if([self orientationForTrack:videoAsset] == UIDeviceOrientationPortrait)
        {
            CGAffineTransform mixedTransform = CGAffineTransformConcat(transformToApply, Move);
            [passThroughLayer setTransform:mixedTransform atTime:kCMTimeZero];
            
        }
        else
        {
            [passThroughLayer setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
        }
        
        passThroughInstruction.layerInstructions = @[passThroughLayer];
        [instructions addObject:passThroughInstruction];
    }
    
    
    videoComposition.instructions = instructions;
    
    if (videoComposition) {
        // Every videoComposition needs these properties to be set:
        videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
        videoComposition.renderSize =  videoSizeX;
    }
    
    NSString* documentsDirectory= [self applicationDocumentsDirectory];
    NSString *myDocumentPath= [documentsDirectory stringByAppendingPathComponent:@"merge_video.mp4"];
    NSURL *urlVideoMain = [NSURL fileURLWithPath:myDocumentPath];
    NSURL *mergeVideoURL = [NSURL fileURLWithPath:myDocumentPath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:myDocumentPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myDocumentPath error:nil];
    }
    
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL =urlVideoMain;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = instructions;
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    mutableVideoComposition.renderSize =  videoSizeX;
    exportSession.videoComposition = mutableVideoComposition;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressView];
            //self.view.userInteractionEnabled = YES;
        });
        __weak typeof(self) weakSelf = self;
        
        switch ([exportSession status])
        {
            case AVAssetExportSessionStatusFailed:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"AVAssetExportSessionStatusFailed : %@",mergeVideoURL);
                    if ([weakSelf.delegate respondsToSelector:@selector(lf_VideoMergedController:didCancelVideoMerged:)]) {
                            [weakSelf.delegate lf_VideoMergedController:self didCancelVideoMerged:nil];
                        }
                        
                });
               
            }
                break;
                
            case AVAssetExportSessionStatusCancelled:
            {
                NSLog(@"AVAssetExportSessionStatusCancelled : %@",mergeVideoURL);
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"AVAssetExportSessionStatusFailed : %@",mergeVideoURL);
                    if ([weakSelf.delegate respondsToSelector:@selector(lf_VideoMergedController:didCancelVideoMerged:)]) {
                        [weakSelf.delegate lf_VideoMergedController:self didCancelVideoMerged:nil];
                    }
                    
                });
            }
                break;
                
            case AVAssetExportSessionStatusCompleted:
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"SUCCESSFULLY CREATE VIDEO : %@",mergeVideoURL);
                    
                    
                    if ([weakSelf.delegate respondsToSelector:@selector(lf_VideoMergedController:didFinishVideoMerged:)]) {
                            [weakSelf.delegate lf_VideoMergedController:self didFinishVideoMerged:mergeVideoURL];
                        }
                        
                    
                });
            }
                break;
                
            default:
                break;
        }
    }];
    
    
    
}

- (NSString*) applicationDocumentsDirectory {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


- (CGAffineTransform)getScaleAndMove:(AVAssetTrack *)videoAsset videoSize:(CGSize)videoSize {
    
    int tx = 0;
    
    if (videoSize.width-videoAsset.naturalSize.width != 0)
    {
        tx = (videoSize.width-videoAsset.naturalSize.width)/2;
    }
    int ty = 0;
    if (videoSize.height-videoAsset.naturalSize.height != 0)
    {
        ty = (videoSize.height-videoAsset.naturalSize.height)/2;
    }
    CGAffineTransform Scale = CGAffineTransformMakeScale(1,1);
    
    if (tx != 0 && ty!=0)
    {
        if (tx <= ty) {
            float factor = videoSize.width/videoAsset.naturalSize.width;
            Scale = CGAffineTransformMakeScale(factor,factor);
            tx = 0;
            ty = (videoSize.height-videoAsset.naturalSize.height*factor)/2;
        }
        if (tx > ty) {
            float factor = videoSize.height/ videoAsset.naturalSize.height;
            Scale = CGAffineTransformMakeScale(factor,factor);
            ty = 0;
            tx = (videoSize.width-videoAsset.naturalSize.width*factor)/2;
        }
    }
    
    CGAffineTransform Move = CGAffineTransformMakeTranslation(tx,ty);
    CGAffineTransform xc = CGAffineTransformConcat(Scale,Move);
    //
    if([self orientationForTrack:videoAsset] == UIDeviceOrientationPortrait)
    {
        CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI);
        CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation(videoSize.width, videoSize.height);
        CGAffineTransform mixedTransform = CGAffineTransformConcat(rotation, translateToCenter);
        CGAffineTransform xc = CGAffineTransformConcat(Scale,mixedTransform);
        return xc;
    }
    
    return xc;
}

// Checking orientation for track ....

- (UIInterfaceOrientation)orientationForTrack:(AVAssetTrack *)asset
{
    AVAssetTrack *videoTrack = asset;
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}




- (UIInterfaceOrientation)checkVideoTrack:(AVAsset *)asset {
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize videoSize = CGSizeZero;
    videoSize = videoTrack.naturalSize;
    CGRect videoRect = CGRectMake(0.0, 0.0, videoSize.width, videoSize.height);
    videoRect = CGRectApplyAffineTransform(videoRect, videoTrack.preferredTransform);
    
    if (videoRect.size.height > videoRect.size.width)
    {
        NSLog(@"Portrait mode");
        return UIInterfaceOrientationPortrait;
    }
    else if (videoRect.size.height < videoRect.size.width)
    {
        NSLog(@"Landscape mode");
        return UIInterfaceOrientationLandscapeLeft;
    }
    else
    {
        NSLog(@"Square mode");
        return UIInterfaceOrientationLandscapeLeft;
    }
}















- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
