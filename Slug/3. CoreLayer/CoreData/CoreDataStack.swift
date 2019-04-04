//
//  CoreDataStack.swift
//  Talks
//
//  Created by Denis Garifyanov on 20/03/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import CoreData

enum ContextType {
    case saveContext, mainContext
}

class CoreDataStack {

    private var storeUrl: URL {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsUrl.appendingPathComponent("MyStore.sqlite")
    }

    private let dataModelName = "Slug"
    private let dataModelExtension = "momd"

    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.dataModelName, withExtension: self.dataModelExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    private lazy var persitentSotreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: self.storeUrl,
                                               options: nil)
        } catch {
            assert(false, "Error adding store: \(error)")
        }
        return coordinator
    }()

    lazy private var masterContext: NSManagedObjectContext? = {
        var masterContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        masterContext.persistentStoreCoordinator = self.persitentSotreCoordinator
        masterContext.mergePolicy = NSMergePolicy.overwrite
        return masterContext
    }()

    lazy private var mainContext: NSManagedObjectContext? = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = self.masterContext
        context.mergePolicy = NSMergePolicy.overwrite
        return context

    }()
    lazy private var saveContext: NSManagedObjectContext? = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.mainContext
        context.mergePolicy = NSMergePolicy.overwrite
        context.undoManager = nil
        return context
    }()

    typealias SaveComplition = () -> Void
    func performSave(with context: NSManagedObjectContext, complition: SaveComplition? = nil) {
        context.perform {
            guard context.hasChanges else {
                complition?()
                return
            }
            do {
                try context.save()
            } catch {
                print("Context save error: \(error)")
            }
            if let parentContext = context.parent {
                self.performSave(with: parentContext, complition: complition)
            } else {
                complition?()
            }
        }
    }
    
    func contex(contextType: ContextType) -> NSManagedObjectContext {
        switch contextType {
        case .mainContext:
            guard let context = self.mainContext else {fatalError("Main Context hasn't been created")}
            return context
        case .saveContext:
            guard let context = self.saveContext else {fatalError("Save Context hasn't been created")}
            return context
        }
    }
}
