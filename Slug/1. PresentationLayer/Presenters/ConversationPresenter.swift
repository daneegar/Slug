//
//  ConversationPresenter.swift
//  Slug
//
//  Created by Denis Garifyanov on 06/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit
import CoreData.NSFetchedResultsController

protocol PresenterForConversationViewController: UITableViewDataSource{
    func sendMessage(text: String?)
    func viewWillHide()
}

class ConversationPresenter: NSObject, PresenterForConversationViewController, CommunicationManagerInjector, BackgroundTasksInjector {
    
    private weak var uiViewControllerToWorkWith: ConversationViewControllerProtocol!
    private weak var tableViewToWorkWith: UITableView!
    private var frc: NSFetchedResultsController<Message>?
    private var conversation: Conversation
    
    init (forViewController vc: ConversationViewControllerProtocol, withConversation conv: Conversation) {
        self.uiViewControllerToWorkWith = vc
        self.tableViewToWorkWith = vc.converstaionTableView
        self.conversation = conv
        super.init()
        self.uiViewControllerToWorkWith.presenter = self
        self.tableViewToWorkWith.dataSource = self
        guard let id = self.conversation.id else {fatalError("conversation Id hasn't been unwrapped \(#function)")}
        self.frc = FRCManager.frcForMessages(delegate: self, forConversationId: id)
        self.performFetch()
        self.tableViewToWorkWith.reloadData()
    }
    
    
    func sendMessage(text: String?) {
        self.communicationManager.send(theMessage: text, inConversation: self.conversation)
    }
    
    func viewWillHide() {
        self.backgroundTask.resetUnreadedStatus(forConversation: self.conversation)
    }
    private func resetStatusHasUnreadedMessaged() {

    }
    
    private func performFetch() {
        do {
            try frc?.performFetch()
        } catch {
            print("perform Fetching FRC done with errors")
        }
    }
}

extension ConversationPresenter: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = self.frc, let sections = frc.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let frc = self.frc else {fatalError("Frc is nil \(#function)")}
        guard let sections = frc.sections?[section] else {return 0}
        return sections.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = self.frc?.object(at: indexPath) else {fatalError()}
        let typeOfMessge: MessageType = message.isOutgoing ? .outGoingMessage : .inComingMessage
        guard let cellConcept = self.tableViewToWorkWith.dequeueReusableCell(
            withIdentifier: typeOfMessge.rawValue) as? MessageCell
            else {return UITableViewCell()}
        cellConcept.setupCell(whithText: message.text, andTypeOf: typeOfMessge)
        cellConcept.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cellConcept
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.frc?.sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let result = self.frc?.section(forSectionIndexTitle: title, at: index) else {
            fatalError("Unable to locate section for \(title) at index: \(index)")
        }
        return result
    }
    
}

extension ConversationPresenter: NSFetchedResultsControllerDelegate {
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
}

