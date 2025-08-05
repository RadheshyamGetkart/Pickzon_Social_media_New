//
//  CompressClass.h
//  SCIMBO
//
//  Created by Radheshyam Yadav on 5/8/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface CompressClass : NSObject
+  (void)compressVideoWithInputVideoUrl:(NSURL *)inputVideoUrl and:(AVAsset *)asset  completion:(void(^)(NSURL *result))callback;
@end

NS_ASSUME_NONNULL_END
