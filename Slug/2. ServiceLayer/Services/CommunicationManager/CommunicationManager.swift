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
    func send(theMessage message: Message, toUser: User)
    func set(userID: String, userName: String)
    func beginAdvertising(browsingIsOn browsing: Bool)
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
    var peerID: String?
    var nameOfUser: String?
    init() {
    }
    func beginAdvertising(browsingIsOn browsingModeOn: Bool) {
        guard let peerId = self.peerID else {
            print("\(#function) can't be execute because peedID doesnt configure")
            return
        }
        guard let nameOfUser = self.nameOfUser else {
            print("\(#function) can't be execute because name doesnt configure")
            return
        }
        self.communicator = MultipeerCommunicator(peerId, nameOfUser, self)
    }
    
    func didFoundUser(userID: String, userName: String?) {
        handleUser(userID: userID) { (user) in
            guard let user = user else {fatalError("user hasn't been finded os insered")}
            if user.id == nil {
                user.id = userID
            }
            if user.name != userName {
                user.name = userName
            }
            user.isOnline = true
            self.createConversation(complition: { (conv) in
                guard let conv = conv else {fatalError("Conversatoin hasn't been finded os insered")}
                user.conversation = conv
            })
            
        }
    }
    
    func didLostUser(userID: String) {
        self.handleUser(userID: userID) { (user) in
            user?.isOnline = false
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
        StorageManager.singleton.findAll(ofType: User.self, in: .saveContext, byPropertyName: "name", withMatch: fromUser, complition: { (findedUsers) in
            guard let users = findedUsers else {fatalError("Fatal error in \(#function)")}
            if users.count != 1 {
                print("users founded by name = \(users.count)")
            } else {
                messageStruct?.unwrap(complition: { (text, messageId) in
                    StorageManager.singleton.insert(in: .saveContext, aModel: Message.self, complition: { (message) in
                        guard let createdMessage = message else {fatalError("messege hasn't been created \(#function)")}
                        createdMessage.text = text
                        createdMessage.id = messageId
                        users.first?.conversation?.addToMessages(createdMessage)
                    })
                    
                })
            }
        return nil
        })
    }
}

extension CommunicationManager: CommunicatorManagerSenderBrowsingAdvertising {
    func set(userID: String, userName: String) {
        self.peerID = userID
        self.nameOfUser = userName
        if self.communicator != nil {
            self.communicator = MultipeerCommunicator(userID, userName, self)
        }
    }
    
    func send(theMessage message: Message, toUser: User) {
        let messageStruct = MessageStruct(from: message, eventType: "TextMessage")
        var data = Data()
        do {
            try data = JSONEncoder().encode(messageStruct)
        } catch {
            print(error)
            return
        }
        guard let userName = toUser.name else {
            print("Name of user hasn't been unwrapped \(#function)")
            return
        }
        guard let communicator_ = self.communicator else { fatalError("\(#function) was ended with error")}
        communicator_.send(aMessage: data, toUserId: userName) { (status, error) in
            print(status)
            print(error.debugDescription)
            //TODO: - make save to DB, if sending ended corrected
            
        }
    }
}

extension CommunicationManager {
    private func addUserToStorage(userID id: String, complition: ((User)->Void)?){
        StorageManager.singleton.insert(in: .saveContext, aModel: User.self, complition: { (newUser) in
            if let user = newUser {
                complition?(user)
            }
        })
    }
    
    private func checkUserId(userID id: String, complition: (([User]) -> Void)?) {
        StorageManager.singleton.findAll(ofType: User.self, in: .saveContext, byPropertyName: "id", withMatch: id) { (findedUsers) in
            if let users = findedUsers {
                complition?(users)
            }
            return nil
        }
    }
    
    func handleUser(userID id: String, complition: @escaping (User?) -> Void) {
        var blanc: User?
        self.checkUserId(userID: id, complition: { (findedUsers) in
            if findedUsers.isEmpty {
                self.addUserToStorage(userID: id, complition: { (newUser) in
                    complition(newUser)
                })
            } else {
                blanc = findedUsers.first!
                complition(blanc)
                StorageManager.singleton.storeData(inTypeOfContext: .saveContext, complition: {})
            }
        })
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
