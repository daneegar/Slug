//
//  BackgroundStorageTasks.swift
//  Slug
//
//  Created by Denis Garifyanov on 10/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation


protocol BackgroundTasks {
    func resetUnreadedStatus(forConversation conv: Conversation)
}

protocol BackgroundTasksInjector {
    var backgroundTask: BackgroundTasks { get }
}

fileprivate let sharedBackGroundTask: BackgroundTasks = BackgroundStorageTasks()

extension BackgroundTasksInjector {
    var backgroundTask: BackgroundTasks {
        return sharedBackGroundTask
    }
}
class BackgroundStorageTasks: BackgroundTasks {
    func resetUnreadedStatus(forConversation conv: Conversation) {
        StorageManager.singleton.findAll(ofType: Conversation.self,
                                         in: .saveContext,
                                         byPropertyName: "id",
                                         withMatch: conv.id) { (conv) -> Void? in
                                            conv?.first?.hasUnreadedMessages = false
        }
    }
}
