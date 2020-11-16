//
//  CodeDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Carlos Linares on 10/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData

public class CoreDataFeedStore: FeedStore {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let modelName = "FeedCacheModel"
        let modelURL = Bundle(for: type(of: self)).url(forResource: modelName, withExtension: "momd")!
        let mom = NSManagedObjectModel(contentsOf: modelURL)!
        
        let persistentContainer = NSPersistentContainer(name: modelName, managedObjectModel: mom)
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { description, error in }
        return persistentContainer
    }()
    
    public init() { }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = persistentContainer.viewContext
        
        Cache.saveCache(feed, timestamp: timestamp, into: context)
        
        if let _ = try? context.save() {
            completion(nil)
        } else {
            completion(nil)
        }
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = persistentContainer.viewContext
        let cache: NSFetchRequest<Cache> = Cache.fetchRequest()
        
        if let cache = try? context.fetch(cache) {
        
            if let founded = cache.first {
                let feedMapped = (founded.feed?.array as! [FeedImage]).map {
                    LocalFeedImage(id: $0.id!, description: $0.information, location: $0.location, url: $0.url!.absoluteURL)
                }
                completion(.found(feed: feedMapped, timestamp: founded.timestamp!))
            } else {
                completion(.empty) 
            }
        } else {
            completion(.empty)
        }
    }
}

extension Cache {
    // TODO: Check this name
    static func saveCache(_ feed: [LocalFeedImage], timestamp: Date, into context: NSManagedObjectContext) {
        let cache = NSEntityDescription.insertNewObject(forEntityName: "Cache", into: context) as! Cache
        cache.setValue(timestamp, forKey: #keyPath(Cache.timestamp))
        
        let feedImages = NSMutableOrderedSet()
        
        feed.forEach { localFeedImage in
            let feedImage = FeedImage.saveFeedImage(localFeedImage, into: context)
            feedImages.add(feedImage)
        }
        
        cache.setValue(feedImages, forKey: #keyPath(Cache.feed))
    }
}

extension FeedImage {
    static func saveFeedImage(_ localFeed: LocalFeedImage, into context: NSManagedObjectContext) -> FeedImage {
        let feedImage = NSEntityDescription.insertNewObject(forEntityName: "FeedImage", into: context) as! FeedImage
        
        feedImage.setValue(localFeed.id, forKey: "id")
        feedImage.setValue(localFeed.description, forKey: #keyPath(FeedImage.information))
        feedImage.setValue(localFeed.location, forKey: #keyPath(FeedImage.location))
        feedImage.setValue(URL(string: localFeed.url.absoluteString), forKey: #keyPath(FeedImage.url))
        
        return feedImage
    }
}
