//
//  CompressClass.m
//  SCIMBO
//
//  Created by Radheshyam Yadav on 5/8/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

#import "CompressClass.h"
#import "SDAVAssetExportSession.h"

@implementation CompressClass

int const  MIN_BITRATE = 2000000;
int const  MIN_HEIGHT = 640;
int const  MIN_WIDTH = 360;

+  (void)compressVideoWithInputVideoUrl:(NSURL *)inputVideoUrl and:(AVAsset *)asset  completion:(void(^)(NSURL *result))callback {
    /* Create Output File Url */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSTimeInterval seconds = [NSDate timeIntervalSinceReferenceDate];
    double milliseconds = seconds*1000;
    
    NSString *finalVideoURLString = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.mp4", milliseconds]];
    NSURL *outputVideoUrl = ([[NSURL URLWithString:finalVideoURLString] isFileURL] == 1)?([NSURL URLWithString:finalVideoURLString]):([NSURL fileURLWithPath:finalVideoURLString]); // Url Should be a file Url, so here we check and convert it into a file Url
    
    NSURL *fileURL = [NSURL fileURLWithPath:inputVideoUrl.path];
    NSNumber *fileSizeValue = nil;
    [fileURL getResourceValue:&fileSizeValue
                       forKey:NSURLFileSizeKey
                        error:nil];
    if (fileSizeValue) {
        NSLog(@"SIZE BEFORE COMPRESSION== value for %@ is %@", fileURL, fileSizeValue);
        
    }
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    if (track != nil)
    {
        CGSize naturalSize = [track naturalSize];
        naturalSize = CGSizeApplyAffineTransform(naturalSize, track.preferredTransform);
        
        width = naturalSize.width;
        height = naturalSize.height;
        if (width < 0) {
            width = width * -1;
        }
        
        if (height < 0) {
            height = height * -1;
        }
        NSLog(@"Resolution : %f x %f", width, height);
    }
    //https://elaziz-shehadeh.medium.com/video-compression-library-for-android-e473a1b89877
  
    CGFloat newWidth = 0.0;
    CGFloat newHeight = 0.0;
    
    if (width >= 1920 || height >= 1920) {
        newWidth = (((width * 0.5) / 16) * 16);
        newHeight = (((height * 0.5) / 16) * 16);
    }else if (width >= 1280 || height >= 1280){
        newWidth = (((width * 0.75) / 16)* 16);
        newHeight = (((height * 0.75) / 16) * 16);
    }else if (width >= 960 || height >= 960) {
        
        if(width > height){
            newWidth = (MIN_HEIGHT * 0.95 / 16) * 16;
            newHeight = (MIN_WIDTH * 0.95 / 16) * 16;
        } else {
            newWidth = (MIN_WIDTH * 0.95 / 16) * 16;
            newHeight = (MIN_HEIGHT * 0.95 / 16) * 16;
        }
    } else{
        newWidth = (((width * 0.9) / 16) * 16);
        newHeight = (((height * 0.9) / 16)* 16);
    }
    
    
    /*if (width  > 720 || height  > 720)  {
     if (width > 720) {
     newWidth = 720;
     newHeight = height * 720.0 / width;
     }else if (height > 720.0) {
     newWidth = width * 720.0 / height;
     newHeight = 720.0;
     }else {
     newWidth = width;
     newHeight = height;
     }
     }else {
     newWidth = width;
     newHeight = height;
     }*/
    
    SDAVAssetExportSession *compressionEncoder = [SDAVAssetExportSession.alloc initWithAsset:[AVAsset assetWithURL:inputVideoUrl]]; // provide inputVideo Url Here
    compressionEncoder.outputFileType = AVFileTypeMPEG4;
    compressionEncoder.outputURL = outputVideoUrl; //Provide output video Url here
    compressionEncoder.shouldOptimizeForNetworkUse = true;
    compressionEncoder.videoSettings = @
    {
    AVVideoCodecKey: AVVideoCodecTypeH264,
    AVVideoWidthKey: [NSNumber numberWithFloat:newWidth] ,// @800,   //Set your resolution width here
    AVVideoHeightKey: [NSNumber numberWithFloat:newHeight], // @600,  //set your resolution height here
    AVVideoCompressionPropertiesKey: @
        {
        //AVVideoAverageBitRateKey: @45000, // Give your bitrate here for lower size give low values
        AVVideoAverageBitRateKey: @500000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        },
    };
    compressionEncoder.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @2,
    AVSampleRateKey: @44100,
    AVEncoderBitRateKey: @128000,
    };
    
    [compressionEncoder exportAsynchronouslyWithCompletionHandler:^
     {
        if (compressionEncoder.status == AVAssetExportSessionStatusCompleted)
        {
            NSLog(@"Compression Export Completed Successfully");
            callback(outputVideoUrl);
        }
        else if (compressionEncoder.status == AVAssetExportSessionStatusCancelled)
        {
            callback(outputVideoUrl);
            
            NSLog(@"Compression Export Canceled");
        }
        else
        {
            callback(outputVideoUrl);
            NSLog(@"Compression Failed");
            
        }
    }];
    
}


@end

/*
 
 
 
 
 CompressClass.compressVideo(withInputVideoUrl: videoURL, and: self.requestConvertAVAsset(asset: asset)!) {   url in
     DispatchQueue.main.async {
         if url.absoluteString.length > 0{
             print("file size After compression in MB: %f ", url.sizePerMB())
             self.delegate?.libraryViewFinishedLoading()
             let video = YPMediaVideo(thumbnail: thumbnailFromVideoPath(url),
                                      videoURL: url, asset: asset)
             videoCallback(video)
         }
     }
    
 }
 
 */
