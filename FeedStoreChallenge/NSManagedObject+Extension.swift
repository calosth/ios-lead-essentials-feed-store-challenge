//
//  NSManagedObject+Extension.swift
//  FeedStoreChallenge
//
//  Created by Carlos Linares on 16/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData

extension NSManagedObject {
    static func fetchRequest<T>() -> NSFetchRequest<T> {
        NSFetchRequest(entityName:  NSStringFromClass(T.self))
    }
    
    static func entity<T: NSManagedObject>(into context: NSManagedObjectContext) -> T {
        NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(T.self), into: context) as! T
    }
}
