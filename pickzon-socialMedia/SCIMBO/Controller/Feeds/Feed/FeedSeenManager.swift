//
//  FeedSeenManager.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 24/10/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import Foundation


final class FeedSeenManager {
    static let shared = FeedSeenManager()
    
    private var seenArray: [String] = []
    private var isUpdatingFeedsSeen = false
    private let queue = DispatchQueue(label: "com.app.feedSeenQueue", qos: .background)

    private init() {}

    func addSeenFeedId(_ id: String) {
      //  print("✅ addSeenFeedId called with id = \(id)")
        
        queue.async { [weak self] in
           // print("🚀 Entered queue.async block")
            guard let self = self else { return }
            if !self.seenArray.contains(id) {
                self.seenArray.append(id)
              //  print("📌 Added id: \(id)")
            }
            if self.seenArray.count >= 10 {
              //  print("📬 Trigger update, count = \(self.seenArray.count)")
                self.triggerUpdate()
            }
        }
    }


    
    func triggerUpdate() {
        guard !isUpdatingFeedsSeen else { return }
        updateFeedsSeenArray()
    }

    func updateFeedsSeenArray() {
        queue.async {
            guard !self.isUpdatingFeedsSeen, !self.seenArray.isEmpty else { return }
            self.isUpdatingFeedsSeen = true

            let feedsToSend = self.seenArray
            let params = ["seenFeeds": feedsToSend] as NSDictionary
            
            URLhandler.sharedinstance.makeCall(url: Constant.sharedinstance.updateFeedSeenURL, param: params) { response, error in
                
                self.queue.async {
                    if error == nil,
                       (response as? NSDictionary)?["status"] as? Int16 == 1 {
                        self.seenArray.removeAll(where: { feedsToSend.contains($0) })
                    }
                    self.isUpdatingFeedsSeen = false
                }
            }
        }
    }
    
    func flushOnAppTerminate() {
        // Force immediate call without waiting for threshold
        updateFeedsSeenArray()
    }
}
