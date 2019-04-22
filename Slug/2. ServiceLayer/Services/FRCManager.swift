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
    static func createFrcForConversationListViewController (delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<Conversation> {
        var sortDescriptors: [NSSortDescriptor] = []
        sortDescriptors.append(NSSortDescriptor(key: "isOffline", ascending: true))
        sortDescriptors.append(NSSortDescriptor(key: "hasUnreadedMessages", ascending: false))
        sortDescriptors.append(NSSortDescriptor(key: "dateOfLastMessage", ascending: false))
        return StorageManager.singleton.prepareFetchResultController(ofType: Conversation.self,
                                                                     sortedBy: sortDescriptors,
                                                                     in: .mainContext,
                                                                     withSelector: "isOffline",
                                                                     delegate: delegate)
    }
    
    static func frcForMessages(delegate: NSFetchedResultsControllerDelegate, forConversationId id: String) ->NSFetchedResultsController<Message> {
        var sortDescriptors: [NSSortDescriptor] = []
        sortDescriptors.append(NSSortDescriptor(key: "createTimeStamp", ascending: false))
        let predicate = NSPredicate(format: "conversation.id = %@", id)
        return StorageManager.singleton.prepareFetchResultController(ofType: Message.self,
                                                   sortedBy: sortDescriptors,
                                                   in: .mainContext,
                                                   withSelector: nil,
                                                   delegate: delegate,
                                                   predicate: predicate)
    }
    
    static func createFrcForCurrentConversation(delegate: NSFetchedResultsControllerDelegate, forConversationId id: String) -> NSFetchedResultsController<Conversation> {
        var sortDescriptors: [NSSortDescriptor] = []
        sortDescriptors.append(NSSortDescriptor(key: "id", ascending: true))
        let predicate = NSPredicate(format: "id = %@", id)
        return StorageManager.singleton.prepareFetchResultController(ofType: Conversation.self,
                                                                     sortedBy: sortDescriptors,
                                                                     in: .mainContext,
                                                                     withSelector: nil,
                                                                     delegate: delegate,
                                                                     predicate: predicate)
    }
    
//    private static func general <T:NSManagedObject> (withType: T.Type, delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<T> {
//
////        return StorageManager.singleton.prepareFetchResultController(ofType: withType,
////                                                                     sortedBy: "id",
////                                                                     asscending: true,
////                                                                     in: .mainContext,
////                                                                     withSelector: "isOnline",
////                                                                     delegate: delegate,
////                                                                     predicate: nil,
////                                                                     offset: 0)
//    }
}
