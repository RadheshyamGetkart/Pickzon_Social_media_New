//
//  FeedSeenManager.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 24/10/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import Foundation

/*
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

*/

final class FeedSeenManager {

    static let shared = FeedSeenManager()

    private var seenSet = Set<String>()
    private var isUpdating = false

    private let queue = DispatchQueue(
        label: "com.app.feedSeenQueue",
        qos: .utility
    )

    private init() {}

    // MARK: - Public
    func addSeenFeedId(_ id: String) {
        queue.async {
            let inserted = self.seenSet.insert(id).inserted
            guard inserted else { return }

            if self.seenSet.count >= 10 {
                self.triggerUpdate()
            }
        }
    }

    private func triggerUpdate() {
        queue.async {
            guard !self.isUpdating else { return }
            self.isUpdating = true

            let feedsToSend = Array(self.seenSet)

            // 🔥 NETWORK CHECK + API MUST BE ON MAIN THREAD
            DispatchQueue.main.async {
                let params = ["seenFeeds": feedsToSend] as NSDictionary

                URLhandler.sharedinstance.makeCall(
                    url: Constant.sharedinstance.updateFeedSeenURL,
                    param: params
                ) { response, error in

                    self.queue.async {
                        if error == nil,
                           (response as? NSDictionary)?["status"] as? Int16 == 1 {
                            self.seenSet.subtract(feedsToSend)
                        }
                        self.isUpdating = false
                    }
                }
            }
        }
    }

    // MARK: - App Background / Terminate
    func flushOnAppTerminate() {
        queue.async {
            guard !self.seenSet.isEmpty, !self.isUpdating else { return }
            self.triggerUpdate()
        }
    }
}
