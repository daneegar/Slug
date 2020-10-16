//
//  CommunicationManager.swift
//  Talks
//
//  Created by Denis Garifyanov on 19/03/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import CoreData

protocol CommunicatorManagerSenderBrowsingAdvertising {
    func send(theMessage message: String?, inConversation conv: Conversation)
    func set(userID: UUID, userName: String)
    func begin(inMode mode: CommunicatorMode)
}

protocol CommunicationManagerInjector {
    var communicationManager: CommunicatorManagerSenderBrowsingAdvertising { get }
}

fileprivate let sharedAppCommunicationManager: CommunicatorManagerSenderBrowsingAdvertising = CommunicationManager()

extension CommunicationManagerInjector {
    var communicationManager: CommunicatorManagerSenderBrowsingAdvertising {
        return sharedAppCommunicationManager
    }
}

class CommunicationManager: CommunicatorDelegate {
    
    var communicator: Communicator?
    var peerID: UUID?
    var nameOfUser: String?
    init() {
    }

    private let kServiceType = "slugs-chat"
    private let keyForUserName = "userName"
    
    func didFoundUser(userID: String, userName: String?) {
        handleUser(userID: userID) { (user) in
            guard let user = user else {fatalError("user hasn't been finded os insered")}
            if user.id == nil {
                user.id = UUID.init(uuidString: userID)
            }
            if user.name != userName {
                user.name = userName
            }
            user.conversation?.isOffline = false
            if let _ = user.conversation {
                
            } else {
                self.createConversation(complition: { (conv) in
                    guard let conv = conv else {fatalError("Conversatoin hasn't been finded os insered")}
                    conv.id = user.id?.uuidString
                    conv.isOffline = false
                    user.conversation = conv
                })
            }
        }
    }
    
    func didLostUser(userID: String) {
        self.handleUser(userID: userID) { (user) in
            user?.conversation?.isOffline = true
        }
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        
    }
    
    func failedToStartAdvertising(error: Error) {
        
    }
    
    func didRecieve(message jsonData: Data, fromUser: String) {
        let jsonDecoder = JSONDecoder()
        var messageStruct: MessageStruct?
        do {
            messageStruct = try jsonDecoder.decode(MessageStruct.self, from: jsonData)
        } catch {
            print("Decoding finished with errors \(#function)")
            return
        }
        StorageManager.singleton.findAll(ofType: User.self, in: .saveContext, byPropertyName: "id", withMatch: fromUser, complition: { (findedUsers) in
            guard let users = findedUsers else {fatalError("Fatal error in \(#function)")}
            if users.count != 1 {
                print("users founded by name = \(users.count)")
            } else {
                messageStruct?.unwrap(complition: { (text, messageId) in
                    StorageManager.singleton.insert(in: .saveContext, aModel: Message.self, complition: { (message) in
                        guard let createdMessage = message else {fatalError("messege hasn't been created \(#function)")}
                        createdMessage.text = text
                        createdMessage.id = messageId
                        createdMessage.isOutgoing = false
                        createdMessage.createTimeStamp = Date()
                        createdMessage.isUnreaded = true
                        self.addMessageToConv(theMessage: createdMessage, inConversation: users.first!.conversation!)
                    })
                    
                })
            }
        return nil
        })
    }
}

extension CommunicationManager: CommunicatorManagerSenderBrowsingAdvertising {
    
    private func getConfigurator(forPeerId id: UUID,
                                 andDisplayName name: String) -> MultipeerCommunicator.ServiceConfigurator {
        
        .init(serviceType: self.kServiceType,
              discoveryInfo: [self.keyForUserName: name],
              mcPeerId: .init(displayName: name, uuid: id))
        
    }
    
    func begin(inMode mode: CommunicatorMode) {
        guard let peerId = self.peerID else {
            print("\(#function) can't be execute because peedID doesnt configure")
            return
        }
        guard let nameOfUser = self.nameOfUser else {
            print("\(#function) can't be execute because name doesnt configure")
            return
        }
        
        let configurator = getConfigurator(forPeerId: peerId,
                                                                                      andDisplayName: nameOfUser)
        
        self.communicator = MultipeerCommunicator.init(serviceConfigurator: configurator, mode: mode)
        self.communicator?.delegate = self
    }
    
    func set(userID: UUID, userName: String) {
        self.peerID = userID
        self.nameOfUser = userName
        if self.communicator == nil {
            let configurator = getConfigurator(forPeerId: userID,
                                               andDisplayName: userName)
            self.communicator = MultipeerCommunicator.init(serviceConfigurator: configurator, mode: .both)
            self.communicator?.delegate = self
        }
    }
    
    func send(theMessage message: String?, inConversation conv: Conversation) {
        self.createMessage { (newMessage) in
            guard let newMsg = newMessage else {fatalError()}
            newMsg.text = message
            newMsg.id = RandomData.generateUniqId()
            newMsg.createTimeStamp = Date()
            newMsg.isOutgoing = true
            
            let messageStruct = MessageStruct(from: newMsg, eventType: "TextMessage")
            var data = Data()
            do {
                try data = JSONEncoder().encode(messageStruct)
            } catch {
                print(error)
                return
            }
            guard let userId = conv.user?.id else {
                print("id of user hasn't been unwrapped \(#function)")
                return
            }
            guard let userName = conv.user?.name else {
                print("Name of user hasn't been unwrapped \(#function)")
                return
            }
            guard let communicator_ = self.communicator else { fatalError("\(#function) was ended with error")}
            communicator_.send(aMessage: data, toUserId: userId.uuidString, whitUserName: userName) { (messageSended, error) in
                if messageSended {
                    DispatchQueue.main.async {
                        self.addMessageToConv(theMessage: newMsg, inConversation: conv)
                    }
                    return
                }
                print(error.debugDescription)
            }
        }
    }

}

extension CommunicationManager {
    private func addUserToStorage(userID id: UUID, complition: ((User)->Void)?){
        StorageManager.singleton.insert(in: .saveContext, aModel: User.self, complition: { (newUser) in
            if let user = newUser {
                complition?(user)
            }
        })
    }
    
    private func checkUserId(userID id: UUID, complition: (([User]) -> Void)?) {
        StorageManager.singleton.findAll(ofType: User.self, in: .saveContext, byPropertyName: "id", withMatch: id.uuidString) { (findedUsers) in
            if let users = findedUsers {
                complition?(users)
            }
            return nil
        }
    }
    
    func handleUser(userID id: String, complition: @escaping (User?) -> Void) {
        var blanc: User?
        guard let uuid = UUID(uuidString: id) else { return }
        self.checkUserId(userID: uuid, complition: { (findedUsers) in
            if findedUsers.isEmpty {
                self.addUserToStorage(userID: uuid, complition: { (newUser) in
                    complition(newUser)
                })
            } else {
                blanc = findedUsers.first!
                complition(blanc)
            }
        })
    }
    
    func addMessageToConv(theMessage msg: Message, inConversation conv: Conversation) {
        StorageManager.singleton.findAll(ofType: Conversation.self, in: .saveContext, byPropertyName: "id", withMatch: conv.id) { (conv) -> Void? in
            guard let converasation = conv?.first else {fatalError()}
            converasation.addToMessages(msg)
            converasation.dateOfLastMessage = msg.createTimeStamp
            if !msg.isOutgoing { converasation.hasUnreadedMessages = true }
            return nil
        }
    }
    
    private func createMessage(complition: @escaping (Message?) -> Void) {
        StorageManager.singleton.insert(in: .saveContext, aModel: Message.self, complition: { (message) in
            complition(message)
        })
    }
    
    private func createConversation(complition: @escaping (Conversation?) -> Void) {
        StorageManager.singleton.insert(in: .saveContext, aModel: Conversation.self, complition: { (conversation) in
            complition(conversation)
        })
    }
}
