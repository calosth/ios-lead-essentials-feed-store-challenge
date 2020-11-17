//
//  CodeDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Carlos Linares on 10/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData

public enum StoreType {
    case persistent, inMemory
}

public class CoreDataFeedStore: FeedStore {
    
    private let storeType: StoreType
    
    lazy var persistentContainer: NSPersistentContainer = {
        let modelName = "FeedCacheModel"
        let modelURL = Bundle(for: type(of: self)).url(forResource: modelName, withExtension: "momd")!
        let mom = NSManagedObjectModel(contentsOf: modelURL)!
        
        let persistentContainer = NSPersistentContainer(name: modelName, managedObjectModel: mom)
        if storeType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            persistentContainer.persistentStoreDescriptions = [description]
        }
        persistentContainer.loadPersistentStores { description, error in }
        return persistentContainer
    }()
    
    lazy var context: NSManagedObjectContext = { persistentContainer.newBackgroundContext() }()
    
    public init(storeType: StoreType = .persistent) {
        self.storeType = storeType
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        do {
            try deleteCache(in: context)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        do {
            try deleteCache(in: context)
            Cache.insert(feed, timestamp: timestamp, into: context)
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
    
    private func deleteCache(in: NSManagedObjectContext) throws {
        let cacheModel: NSFetchRequest<Cache> = Cache.fetchRequest()
        let cache = try context.fetch(cacheModel)
        cache.forEach { context.delete($0) }
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
            LocalFeedImage(id: $0.id!, description: $0.information, location: $0.location, url: $0.url!)
        }
    }
}
