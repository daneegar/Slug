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

protocol PresenterForConversationList: UITableViewDataSource {
    func presentMainUserView(presentType: PresentType)
    func showView(forItem indexPath: IndexPath, presentType: PresentType)
    func switcherWasToggled(isOn: Bool)
}

enum PresentType {
    case modal, pushInNavigationStack
}

class ConversationListPresenter: NSObject, PresenterForConversationList {
    
    private var uiNavigationViewControllerToWorkWith: UINavigationController
    private var uiViewControllerToWorkWith: UIViewController
    private var tableViewToWorkWith: UITableView
    var frc: NSFetchedResultsController<User>?
    

    init (uiNavigationController: UINavigationController?, uiViewController: UIViewController?, tableView: UITableView?, typesOfItems: NSManagedObject.Type = User.self) {
        if let unc = uiNavigationController, let uivc = uiViewController, let tv = tableView {
            self.uiNavigationViewControllerToWorkWith = unc
            self.uiViewControllerToWorkWith = uivc
            self.tableViewToWorkWith = tv
        }
        else {fatalError("There is no some components in ViewController")}
        super.init()
        self.findOrInitTheMainUser()
        self.tableViewToWorkWith.dataSource = self
    }
    
    func presentMainUserView(presentType: PresentType) {
        guard let mvc = uiViewControllerToWorkWith.storyboard?.instantiateViewController(withIdentifier: "mainUserProfile") else {return}
        uiViewControllerToWorkWith.present(mvc, animated: true)
    }
    
    func showView(forItem indexPath: IndexPath, presentType: PresentType) {
        
    }
    
    func switcherWasToggled(isOn: Bool) {
        
    }
    
    private func findOrInitTheMainUser() {
        guard let mainUser = StorageManager.singleton.findOrInsert(in: .mainContext, aModel: User.self) else {fatalError("MainUser hasn't been created or loaded")}
        var isInititiate: Bool = false
        if mainUser.name == nil {
            mainUser.name = "unNamed"
            isInititiate = true
        }
        if mainUser.id == nil {
            mainUser.generateId()
            isInititiate = true
        }
        if mainUser.avatar == nil {
            mainUser.avatar = UIImage(named: "placeholder-user")?.jpegData(compressionQuality: 1.0)
            isInititiate = true
        }
        mainUser.isOnline = true
        if isInititiate {
            StorageManager.singleton.storeData(inTypeOfContext: .mainContext) {
                print("Main user has been loaded or saver")
            }
        }
        self.frc = self.createFrc(withType: User.self)
        self.performFetch()
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    private func createFrc <T:NSManagedObject> (withType: T.Type) -> NSFetchedResultsController<T> {
        return StorageManager.singleton.prepareFetchResultController(ofType: withType,
                                                              sortedBy: "name",
                                                              asscending: true,
                                                              in: .mainContext,
                                                              withSelector: "isOnline",
                                                              delegate: self,
                                                              predicate: nil,
                                                              offset: 1)
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
        return sectionInfo.name
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
///Users/denis/Library/Developer/CoreSimulator/Devices/62DD715A-7A4F-4274-8BC4-801301C1F854/data/Containers/Bundle/Application/1B2307FB-8141-43F7-AECF-F3C932B6E8FD/Slug.app/
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
}


