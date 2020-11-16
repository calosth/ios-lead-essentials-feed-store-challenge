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
    
    lazy var context: NSManagedObjectContext = { persistentContainer.newBackgroundContext() }()
    
    public init() { }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        Cache.insert(feed, timestamp: timestamp, into: context)
        
        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        
        do {
            if let cache = try fetchCache() {
                completion(.found(feed: cache.feed, timestamp: cache.timestamp))
            } else {
                completion(.empty)
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func fetchCache() throws -> (feed: [LocalFeedImage], timestamp: Date)? {
        let cacheModel: NSFetchRequest<Cache> = Cache.fetchRequest()
        let cache = try context.fetch(cacheModel)
        
        guard let feed = cache.first?.feed?.array as? [FeedImage], let timestamp = cache.first?.timestamp else {
            return nil
        }
        
        return (map(feed), timestamp)
    }
    
    private func map(_ feedImage: [FeedImage]) -> [LocalFeedImage] {
        return feedImage.map {
            LocalFeedImage(id: $0.id!, description: $0.information, location: $0.location, url: $0.url!.absoluteURL)
        }
    }
}

extension Cache {
    static func insert(_ feed: [LocalFeedImage], timestamp: Date, into context: NSManagedObjectContext) {
        let cache: Cache = Cache.entity(into: context)

        let feedImage = FeedImage.insert(feed, into: context)
        
        cache.setValue(timestamp, forKey: #keyPath(Cache.timestamp))
        cache.setValue(feedImage, forKey: #keyPath(Cache.feed))
    }
}

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
