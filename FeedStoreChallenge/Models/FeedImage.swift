//
//  FeedImage.swift
//  FeedStoreChallenge
//
//  Created by Carlos Linares on 16/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData

extension FeedImage {
    static func insert(_ feed: [LocalFeedImage], into context: NSManagedObjectContext) -> NSOrderedSet {
        let feedImages = NSMutableOrderedSet()
        
        feed.forEach { localFeedImage in
            let feedImage: FeedImage = FeedImage.entity(into: context)
            feedImage.setValue(localFeedImage.id, forKey: "id")
            feedImage.setValue(localFeedImage.description, forKey: #keyPath(FeedImage.information))
            feedImage.setValue(localFeedImage.location, forKey: #keyPath(FeedImage.location))
            feedImage.setValue(localFeedImage.url, forKey: #keyPath(FeedImage.url))
            feedImages.add(feedImage)
        }
                
        return feedImages
    }
}
