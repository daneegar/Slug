//
//  StorageManager.swift
//  Talks
//
//  Created by Denis Garifyanov on 26/03/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import CoreData

class StorageManager {
    private init() {
    }

    static let singleton = StorageManager()

    let coreDataStack = CoreDataStack()

    func loadOrInsertInMainThread<T: NSManagedObject> (anEntiti object: T.Type) -> T? {
        if let context = self.coreDataStack.mainContext {
            return self.findOrInsert(in: context, aModel: object)
        }
        print("context in load operation wasn't created")
        return nil
    }

    func storeDataInMainThread(complition: @escaping () -> Void) {
        if let context = self.coreDataStack.mainContext {
            self.coreDataStack.performSave(with: context) {
                complition()
            }
            return
        }
        print("context in saving operation wasn't created")
    }

    func insert<T: NSManagedObject>(in context: NSManagedObjectContext, aModel model: T.Type) -> T? {
        var someData = model.init()
        context.performAndWait {
            someData = NSEntityDescription.insertNewObject(forEntityName: model.entity().name!, into: context) as! T
        }
        return someData
    }
    
    func findOrInsert<T: NSManagedObject>(in context: NSManagedObjectContext, aModel model: T.Type) -> T? {
        var entiti: T?
        context.performAndWait {
            entiti = findFirst(in: context, aModel: T.self)
            if entiti == nil {
                entiti = self.insert(in: context, aModel: T.self)
            }
        }
        return entiti
    }
    
    func findFirst<T: NSManagedObject>(in context: NSManagedObjectContext, aModel entiti: T.Type) -> T? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Problem with modeling")
            return nil
        }
        var blanc: T?
        guard let fetchRequest = self.fetchRequestGeneral(model: model, forEntiti: entiti) else {
            print("Fetch request hasn't been created")
            return nil
        }
        context.performAndWait {
            do {
                let result = try context.fetch(fetchRequest)
                blanc = result.first
            } catch {
                print("FUCK")
            }
        }
        return blanc
    }
    
    private func fetchRequestGeneral<T: NSManagedObject>(model: NSManagedObjectModel, forEntiti entiti: T.Type) ->NSFetchRequest<T>? {
        guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else {return nil}
        return fetchRequest
    }
    
    private func countRequest<T: NSManagedObject>(model: NSManagedObject, for entiti: T.Type) -> Int? {
        guard let countRequest = T.fetchRequest() as? NSFetchRequest<T> else {return nil}
        return countRequest.accessibilityElementCount()
    }
    
    func findLast<T: NSManagedObject>(in context: NSManagedObjectContext, aModel entiti: T.Type, withPredicate predicate: NSPredicate? = nil) -> T? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Problem with modeling")
            return nil
        }
        guard let fetchRequest = self.fetchRequestGeneral(model: model, forEntiti: entiti) else {
            print("Fetch request hasn't been created")
            return nil
        }
        fetchRequest.predicate = predicate
        var blanc: T?
        context.performAndWait {
            do {
                let result = try context.fetch(fetchRequest)
                blanc = result.last
            } catch {
                print("FUCK")
            }
        }
        return blanc
    }
    func findAll<T: NSManagedObject>(ofType type: T.Type, in context: NSManagedObjectContext, byPropertyName name: String?, withMatch match: String?) -> [T]? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
                print("Problem with modeling")
                return nil
        }
        guard let fetchRequest = self.fetchRequestGeneral(model: model, forEntiti: type) else {
            print("Fetch request hasn't been created")
            return nil
        }
        if let nameToPredicate = name, let matchToPredicate = match {
            let predicate: NSPredicate? = NSPredicate(format: "\(nameToPredicate) == %@", matchToPredicate)
            fetchRequest.predicate = predicate
        }
        var blanc: [T]?
        context.performAndWait {
            do {
                let result = try context.fetch(fetchRequest)
                blanc = result
            } catch {
                print("FUCK")
            }
        }
        return blanc
    }
    
    func frcPrepare<T: NSManagedObject>(ofType type: T.Type,
                                        sortedBy property: String?,
                                        asscending: Bool = false,
                                        in context: NSManagedObjectContext,
                                        withSelector selector: String?,
                                        delegate: NSFetchedResultsControllerDelegate,
                                        predicate: NSPredicate? = nil,
                                        offset: Int = 0) -> NSFetchedResultsController<T> {
        let fetchRequest = type.fetchRequest()
        fetchRequest.fetchOffset = offset
        fetchRequest.predicate = predicate
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: property, ascending: asscending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataStack.mainContext!, sectionNameKeyPath: selector, cacheName: nil)
        frc.delegate = delegate
        return frc as! NSFetchedResultsController<T>
    }
}
