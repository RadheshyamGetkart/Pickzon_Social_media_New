//
//  VideoLoaderManager.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/20.
//  Copyright © 2019 Gesen. All rights reserved.
//

import AVFoundation

public class VideoLoadManager: NSObject {
    
    public static let shared = VideoLoadManager()
    
    public var reportError: ((Error) -> Void)?
    
    public var customHTTPHeaderFields: ((URL) -> [String: String]?)?
    
    private(set) var loaderMap: [URL: VideoLoader] = [:]
    
}

extension VideoLoadManager: AVAssetResourceLoaderDelegate {

    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
      
       
        
        guard let url = loadingRequest.url else {
            reportError?(NSError(
                domain: "me.gesen.player.loader",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unsupported load request (\(loadingRequest))"]
            ))
            return false
        }
        
        VideoPreloadManager.shared.remove(url: url)
        
        do {
            if let loader = loaderMap[url] {
                loader.append(request: loadingRequest)
            } else {
                let loader = try VideoLoader(url: url)
                loader.delegate = self
                loader.append(request: loadingRequest)
                loaderMap[url] = loader
            }
            return true
        } catch {
            if ISDEBUG == true {
                reportError?(error)
            }
            return false
        }
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        
        guard let url = loadingRequest.url, let loader = loaderMap[url] else {
            return
        }
        
        loader.remove(request: loadingRequest)
    }
    
}

extension VideoLoadManager: VideoLoaderDelegate {
    
    func loader(_ loader: VideoLoader, didFail error: Error) {
        if ISDEBUG == true {
            reportError?(error)
        }
        //commented as we are now downloading only a chunc of the video. in some cases like inernet connection lost it was creating problem in controlling the video download in chunc
        loaderMap.removeValue(forKey: loader.url)
    }
    
    func loaderDidFinish(_ loader: VideoLoader) {
        loaderMap.removeValue(forKey: loader.url)
    }
}
