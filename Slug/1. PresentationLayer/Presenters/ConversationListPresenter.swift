//
//  ConversationListPresenter.swift
//  Slug
//
//  Created by Denis Garifyanov on 04/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit
import CoreData.NSFetchedResultsController

protocol PresenterForConversationList: class, UITableViewDataSource {
    func presentMainUserView(presentType: PresentType)
    func showView(forItem indexPath: IndexPath, presentType: PresentType)
    func switcherWasToggled(isOn: Bool)
    func presentStreamView(presentType: PresentType)
}

enum PresentType {
    case modal, pushInNavigationStack
}

class ConversationListPresenter: NSObject, PresenterForConversationList, CommunicationManagerInjector {

    private weak var uiViewControllerToWorkWith: ConversationListViewControllerProtocol!
    private weak var tableViewToWorkWith: UITableView!
    private var presentationAssembly: IPresentationAssembly
    var frc: NSFetchedResultsController<Conversation>?
    var mainUser: MainUser? {
        willSet {
            if let value = newValue {
                self.configCommunicationManager(withMain: value)
            }
        }
    }

    init (forViewController vc: ConversationListViewControllerProtocol, presentationAssembly: IPresentationAssembly) {
        self.uiViewControllerToWorkWith = vc
        self.tableViewToWorkWith = vc.tableViewOfChats
        self.presentationAssembly = presentationAssembly
        super.init()
        self.uiViewControllerToWorkWith.presenter = self
        self.uiViewControllerToWorkWith.tableViewOfChats.dataSource = self
        self.findOrInitTheMainUser()
        self.tableViewToWorkWith.reloadData()
    }
    
    func presentMainUserView(presentType: PresentType) {
        self.presentationAssembly.presentProfileMainViewContoller()
    }
    
    func showView(forItem indexPath: IndexPath, presentType: PresentType) {
        guard let conversation = self.frc?.object(at: indexPath) else {
            print("there is know user in indexPath \(indexPath)")
            return
        }
        self.presentationAssembly.present(conversation: conversation)
    }
    
    func switcherWasToggled(isOn: Bool) {
        self.communicationManager.begin(inMode: .both)
    }
    
    func presentStreamView(presentType: PresentType) {
        self.presentationAssembly.presentStreamPreviewController()
    }
    
    
    private func findOrInitTheMainUser(){
        StorageManager.singleton.findOrInsert(in: .mainContext, aModel: MainUser.self, complition: {(savedOrCreatedUser) in
            guard let user = savedOrCreatedUser else {fatalError("Main User hasn't been created or founded")}
            self.mainUser = user
            
        })
        self.frc = FRCManager.createFrcForConversationListViewController(delegate: self)
        self.performFetch()
    }
    
    private func configCommunicationManager(withMain user: MainUser) {
        if let id = user.id, let name = user.name {
            self.communicationManager.set(userID: id, userName: name)
        } else {
            print("Communication manager cann't be configured without name or id of Main User")
            return
        }
    }
    private func performFetch() {
        do {
            try frc?.performFetch()
        } catch {
            print("perform Fetching FRC done with errors")
        }
    }
    
    
}

extension ConversationListPresenter: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let frc = self.frc
        let sections = frc?.sections
        return sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let frc = self.frc else {fatalError("Frc is nil \(#function)")}
        guard let sections = frc.sections?[section] else {return 0}
        return sections.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableViewToWorkWith.dequeueReusableCell(withIdentifier: "ChatCell") as? ChatCell
            else {
                return UITableViewCell()
        }
        if let conversation = self.frc?.object(at: indexPath) {
            StorageManager.singleton.findAll(ofType: Message.self, in: .mainContext, byPropertyName: "conversation.id", withMatch: conversation.id) { (message) -> Void? in
                guard var messages = message else {fatalError()}
                messages.sort(by: { (msg1, msg2) -> Bool in
                    guard let dateOfMsg1 = msg1.createTimeStamp else {return true}
                    guard let dateOfMsg2 = msg2.createTimeStamp else {return false}
                    return dateOfMsg1 < dateOfMsg2
                    })
                cell.configProperies(withChatModel: conversation, withLastMessage: messages.last)
                return nil
                }
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = self.frc?.sections?[section] else {
            return nil
        }
        let title: String
        if sectionInfo.name == "1" {
            title = "Offline"
        } else {
            title = "Online"
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let result = self.frc?.section(forSectionIndexTitle: title, at: index) else {
            fatalError("Unable to locate section for \(title) at index: \(index)")
        }
        return result
    }
    
}

extension ConversationListPresenter: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableViewToWorkWith.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableViewToWorkWith.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableViewToWorkWith.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableViewToWorkWith.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tableViewToWorkWith.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            self.tableViewToWorkWith.insertRows(at: [newIndexPath!], with: .fade)
            self.tableViewToWorkWith.deleteRows(at: [indexPath!], with: .fade)
        @unknown default:
            print("FetchResultController back the uknowed Change type")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableViewToWorkWith.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            self.tableViewToWorkWith.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default :
            return
        }
    }
}

