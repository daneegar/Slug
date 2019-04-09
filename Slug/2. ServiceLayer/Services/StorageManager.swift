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

    func storeData(inTypeOfContext contextType: ContextType,complition: @escaping () -> Void) {
        let context = self.coreDataStack.contex(contextType: contextType)
        self.coreDataStack.performSave(with: context) {
                complition()
        }
    }

    func insert<T: NSManagedObject>(in contextType: ContextType, aModel model: T.Type, complition: ((T?) -> Void)?){
        
        let context = self.coreDataStack.contex(contextType: contextType)
        var someData: T?
        context.performAndWait {
            someData = NSEntityDescription.insertNewObject(forEntityName: model.entity().name!, into: context) as? T
            complition?(someData)
        }
    }
    
    func findOrInsert<T: NSManagedObject>(in contextType: ContextType, aModel model: T.Type, complition: ((T?) -> Void)?) {
        var entiti: T?
        let context = self.coreDataStack.contex(contextType: contextType)
        context.performAndWait {
            entiti = findFirst(in: contextType, aModel: T.self)
            if entiti == nil {
                self.insert(in: contextType, aModel: model, complition: { (data) in
                    complition?(data)
                })
            }
            else {
                complition?(entiti)
            }
        }
    }
    
    func findFirst<T: NSManagedObject>(in contextType: ContextType, aModel entiti: T.Type) -> T? {
        let context = self.coreDataStack.contex(contextType: contextType)
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Problem with modeling \(#function)")
            return nil
        }
        var blanc: T?
        guard let fetchRequest = self.fetchRequestGeneral(model: model, forEntiti: entiti) else {
            print("Fetch request hasn't been created \(#function)")
            return nil
        }
        context.performAndWait {
            do {
                let result = try context.fetch(fetchRequest)
                blanc = result.first
            } catch {
                print("Fetch request in context done with error in \(#function)")
            }
        }
        return blanc
    }
    
    func findLast<T: NSManagedObject>(in contextType: ContextType, aModel entiti: T.Type, withPredicate predicate: NSPredicate? = nil) -> T? {
        let context = self.coreDataStack.contex(contextType: contextType)
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Problem with modeling in \(#function)")
            return nil
        }
        guard let fetchRequest = self.fetchRequestGeneral(model: model, forEntiti: entiti) else {
            print("Fetch request hasn't been created in \(#function)")
            return nil
        }
        fetchRequest.predicate = predicate
        var blanc: T?
        context.performAndWait {
            do {
                let result = try context.fetch(fetchRequest)
                blanc = result.last
            } catch {
                print("Fetch request in context done with error in \(#function)")
            }
        }
        return blanc
    }
    
    func findAll<T: NSManagedObject>(ofType type: T.Type, in contextType: ContextType, byPropertyName name: String?, withMatch match: String?, complition: (([T]?) -> Void?)?){
        let context = self.coreDataStack.contex(contextType: contextType)
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Problem with modeling \(#function)")
            return
        }
        guard let fetchRequest = self.fetchRequestGeneral(model: model, forEntiti: type) else {
            print("Fetch request hasn't been created \(#function)")
            return
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
                complition?(blanc)
            } catch {
                print("Fetch request in context done with error in \(#function)")
            }
            self.storeData(inTypeOfContext: contextType, complition: {
                
            })
        }
    }
    
    private func fetchRequestGeneral<T: NSManagedObject>(model: NSManagedObjectModel, forEntiti entiti: T.Type) ->NSFetchRequest<T>? {
        guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else {return nil}
        return fetchRequest
    }
    
    private func countRequest<T: NSManagedObject>(model: NSManagedObject, for entiti: T.Type) -> Int? {
        guard let countRequest = T.fetchRequest() as? NSFetchRequest<T> else {return nil}
        return countRequest.accessibilityElementCount()
    }
    
    func prepareFetchResultController<T: NSManagedObject>(ofType type: T.Type,
                                        sortedBy property: String?,
                                        asscending: Bool = false,
                                        in context: ContextType,
                                        withSelector selector: String?,
                                        delegate: NSFetchedResultsControllerDelegate,
                                        predicate: NSPredicate? = nil,
                                        offset: Int = 0) -> NSFetchedResultsController<T> {
        let fetchRequest = type.fetchRequest()
        fetchRequest.fetchOffset = offset
        fetchRequest.predicate = predicate
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: property, ascending: asscending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let context = self.coreDataStack.contex(contextType: context)
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: selector, cacheName: nil)
        frc.delegate = delegate
        return frc as! NSFetchedResultsController<T>
    }
}
