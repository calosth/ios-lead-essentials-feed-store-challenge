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
        
        let cache = NSEntityDescription.insertNewObject(forEntityName: "Cache", into: context) as! Cache
        cache.setValue(timestamp, forKey: #keyPath(Cache.timestamp))
        
        let images = NSMutableOrderedSet()
        feed.forEach { localFeedImage in
            let image = NSEntityDescription.insertNewObject(forEntityName: "FeedImage", into: context) as! FeedImage
            image.setValue(localFeedImage.id, forKey: "id")
            image.setValue(localFeedImage.description, forKey: #keyPath(FeedImage.information))
            image.setValue(localFeedImage.location, forKey: #keyPath(FeedImage.location))
            image.setValue(URL(string: localFeedImage.url.absoluteString), forKey: #keyPath(FeedImage.url))
            images.add(image)
        }
        
        cache.setValue(images, forKey: #keyPath(Cache.feed))
        
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
