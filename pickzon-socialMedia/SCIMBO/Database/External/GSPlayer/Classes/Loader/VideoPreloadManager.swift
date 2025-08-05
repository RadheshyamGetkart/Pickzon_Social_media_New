//
//  VideoPreloadManager.swift
//  GSPlayer
//
//  Created by Gesen on 2019/4/20.
//  Copyright © 2019 Gesen. All rights reserved.
//

import Foundation

public class VideoPreloadManager: NSObject {
    
    public static let shared = VideoPreloadManager()
    
    //public var preloadByteCount: Int = 1024 * 1024 // = 1M
    public var preloadByteCount: Int = 128 * 1024
    
    public var didStart: (() -> Void)?
    public var didPause: (() -> Void)?
    public var didFinish: ((Error?) -> Void)?
    
    private var downloader: VideoDownloader?
    private var isAutoStart: Bool = true
    private var waitingQueue: [URL] = []
    
    public func set(waiting: [URL]) {
        if (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected == true {
            //downloader = nil
            //waitingQueue = waiting
            waitingQueue.append(contentsOf: waiting)
            if isAutoStart { start() }
        }
        
       
    }
    
    func start() {
        guard downloader == nil, waitingQueue.count > 0 else {
            downloader?.resume()
            return
        }
        
        isAutoStart = true
        
        let url = waitingQueue.removeFirst()
        
        guard
            !VideoLoadManager.shared.loaderMap.keys.contains(url),
            let cacheHandler = try? VideoCacheHandler(url: url) else {
            return
        }
        
        downloader = VideoDownloader(url: url, cacheHandler: cacheHandler)
        downloader?.delegate = self
        downloader?.download(from: 0, length: preloadByteCount)
        
        if cacheHandler.configuration.downloadedByteCount < preloadByteCount {
            didStart?()
        }
    }
    
    func pause() {
        downloader?.suspend()
        didPause?()
        isAutoStart = false
    }
    
    func remove(url: URL) {
        if let index = waitingQueue.firstIndex(of: url) {
            waitingQueue.remove(at: index)
        }
        
        if downloader?.url == url {
            downloader = nil
        }
    }
    
   /*
    //
    public func startForUrl(url: URL, start:Int, length:Int) {
        guard
            !VideoLoadManager.shared.loaderMap.keys.contains(url),
            let cacheHandler = try? VideoCacheHandler(url: url) else {
            return
        }
        
        downloader = VideoDownloader(url: url, cacheHandler: cacheHandler)
        downloader?.delegate = self
        downloader?.download(from: start, length: length)
        
        //if cacheHandler.configuration.downloadedByteCount < preloadByteCount {
            didStart?()
        //}
    }*/
    
}

extension VideoPreloadManager: VideoDownloaderDelegate {
    
    public func downloader(_ downloader: VideoDownloader, didReceive response: URLResponse) {
        
    }
    
    public func downloader(_ downloader: VideoDownloader, didReceive data: Data) {
        
    }
    
    public func downloader(_ downloader: VideoDownloader, didFinished error: Error?) {
        self.downloader = nil
        start()
        didFinish?(error)
    }
    
}
