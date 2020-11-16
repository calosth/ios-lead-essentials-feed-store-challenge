//
//  Cache.swift
//  FeedStoreChallenge
//
//  Created by Carlos Linares on 16/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData

extension Cache {
    static func insert(_ feed: [LocalFeedImage], timestamp: Date, into context: NSManagedObjectContext) {
        let cache: Cache = Cache.entity(into: context)

        let feedImage = FeedImage.insert(feed, into: context)
        
        cache.setValue(timestamp, forKey: #keyPath(Cache.timestamp))
        cache.setValue(feedImage, forKey: #keyPath(Cache.feed))
    }
}
