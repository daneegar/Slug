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
import AssetsLibrary

protocol PresenterForConversationList: class, UITableViewDataSource {
    func presentMainUserView(presentType: PresentType)
    func showView(forItem indexPath: IndexPath, presentType: PresentType)
    func switcherWasToggled(isOn: Bool)
}

enum PresentType {
    case modal, pushInNavigationStack
}

class ConversationListPresenter: NSObject, PresenterForConversationList, CommunicationManagerInjector {
    
    private weak var uiNavigationViewControllerToWorkWith: UINavigationController!
    private weak var uiViewControllerToWorkWith: UIViewController!
    private weak var tableViewToWorkWith: UITableView!
    var sectionIndexTitles = ["Online", "Offline"]
    var frc: NSFetchedResultsController<User>?
    var mainUser: User? {
        willSet {
            if let value = newValue {
                self.configCommunicationManager(withMain: value)
            }
        }
    }

    init (uiNavigationController: UINavigationController?, uiViewController: UIViewController?, tableView: UITableView?, typesOfItems: NSManagedObject.Type = User.self) {
        if let unc = uiNavigationController, let uivc = uiViewController, let tv = tableView {
            self.uiNavigationViewControllerToWorkWith = unc
            self.uiViewControllerToWorkWith = uivc
            self.tableViewToWorkWith = tv
        }
        else {fatalError("There is no some components in ViewController")}
        super.init()
        self.tableViewToWorkWith.dataSource = self
        self.findOrInitTheMainUser()
    }
    
    func presentMainUserView(presentType: PresentType) {
        guard let profileViewController = uiViewControllerToWorkWith.storyboard?.instantiateViewController(withIdentifier: "mainUserProfile") else {return}
        uiViewControllerToWorkWith.present(profileViewController, animated: true)
    }
    
    func showView(forItem indexPath: IndexPath, presentType: PresentType) {
        guard let conversationViewController = self.uiViewControllerToWorkWith.storyboard?.instantiateViewController(withIdentifier: "conversationViewController") as? ConversationViewControllerProtocol else {return}
        guard let user = self.frc?.object(at: indexPath) else {
            print("there is know user in indexPath \(indexPath)")
            return
        }
        if let conversation = user.conversation {
            conversationViewController.initConversation(conversation: conversation)
            self.uiNavigationViewControllerToWorkWith.pushViewController(conversationViewController, animated: true)
            return
        }
    }
    
    func switcherWasToggled(isOn: Bool) {
        
    }
    
    private func findOrInitTheMainUser(){
        StorageManager.singleton.findOrInsert(in: .mainContext, aModel: User.self, complition: {(savedOrCreatedUser) in
            var isInititiate: Bool = false
            guard let user = savedOrCreatedUser else {fatalError("Main User hasn't been created or founded")}
            if user.name == nil {
                user.name = "unNamed"
                isInititiate = true
            }
            if user.id == nil {
                user.generateId()
                isInititiate = true
            }
            if user.avatar == nil {
                user.avatar = UIImage(named: "placeholder-user")?.jpegData(compressionQuality: 1.0)
                isInititiate = true
            }
            user.isOnline = true
            self.mainUser = user
            self.frc = FRCManager.createFrcForConversationListViewController(delegate: self)
            self.performFetch()
        })
    }
    
    private func configCommunicationManager(withMain user: User) {
        if let id = user.id, let name = user.name {
            self.communicationManager.set(userID: id, userName: name)
        } else {
            print("Communication manager cann't be configured without name or id of Main User")
            return
        }
        self.communicationManager.beginAdvertising(browsingIsOn: true)
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
        if let user = self.frc?.object(at: indexPath) {
            cell.configProperies(withChatModel: user)
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = self.frc?.sections?[section] else {
            return nil
        }
        let title: String
        if sectionInfo.name == "0" {
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
            self.tableViewToWorkWith.insertRows(at: [newIndexPath!], with: .automatic)
        case .move:
            self.tableViewToWorkWith.deleteRows(at: [indexPath!], with: .automatic)
            self.tableViewToWorkWith.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            self.tableViewToWorkWith.reloadRows(at: [indexPath!], with: .automatic)
        case .delete:
            self.tableViewToWorkWith.deleteRows(at: [indexPath!], with: .automatic)
        @unknown default:
            print("FetchResultController back the uknowed Change type")
        }
    }
    func sectionIndexTitle(forSectionName sectionName: String) -> String? {
        print("\(#function)")
        return nil
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableViewToWorkWith.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move:
            self.tableViewToWorkWith.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            self.tableViewToWorkWith.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            self.tableViewToWorkWith.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default :
            return
        }
    }
}

