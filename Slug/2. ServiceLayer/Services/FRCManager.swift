//
//  FRCManager.swift
//  Slug
//
//  Created by Denis Garifyanov on 06/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import CoreData.NSFetchedResultsController

class FRCManager {
    static func createFrcForConversationListViewController (delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<User> {
        return StorageManager.singleton.prepareFetchResultController(ofType: User.self,
                                                                     sortedBy: "id",
                                                                     asscending: true,
                                                                     in: .mainContext,
                                                                     withSelector: nil,
                                                                     delegate: delegate,
                                                                     predicate: nil,
                                                                     offset: 0)
    }
    
    static func frcForMessages(delegate: NSFetchedResultsControllerDelegate, forConversationId id: String) ->NSFetchedResultsController<Message> {
        let predicate = NSPredicate(format: "conversation.id = %@", id)
        return StorageManager.singleton.prepareFetchResultController(ofType: Message.self,
                                                   sortedBy: "createTimeStamp",
                                                   asscending: true,
                                                   in: .mainContext,
                                                   withSelector: nil,
                                                   delegate: delegate,
                                                   predicate: predicate)
    }
    
    private static func general <T:NSManagedObject> (withType: T.Type, delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<T> {
    
        return StorageManager.singleton.prepareFetchResultController(ofType: withType,
                                                                     sortedBy: "id",
                                                                     asscending: true,
                                                                     in: .mainContext,
                                                                     withSelector: "isOnline",
                                                                     delegate: delegate,
                                                                     predicate: nil,
                                                                     offset: 0)
    }
}
