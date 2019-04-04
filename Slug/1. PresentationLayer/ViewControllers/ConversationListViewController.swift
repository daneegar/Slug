//
//  ChatsTableView.swift
//  Talks
//
//  Created by Denis Garifyanov on 20/02/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit
//import CoreData.NSFetchedResultsController

class ConversationListViewController: UIViewController {

    @IBOutlet weak var isBrowserMode: UISwitch!

    @IBOutlet weak var tableViewOfChats: UITableView!
//    var listOfChats: [Chat] = []
//    var frc: NSFetchedResultsController<User>?
//    var communicator: CommunicationManager?
    @IBAction func toggleSwitch(_ sender: Any) {
//        communicator?.communicator.online = isBrowserMode.isOn
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configCommunicator()
        self.tableViewOfChats.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "ChatCell")
        self.tableViewOfChats.reloadData()
        self.navigationItem.title = "Tinkoff Chat"
//        communicator?.communicator.online = isBrowserMode.isOn
    }

    // MARK: - lets test our TableView with Cells
    private func richList() {
    }

    func logThemeChanging(selectedTheme: UIColor) {
        print("theme has been changed!")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toChat" {
//            guard let selectedIndexPath = self.tableViewOfChats.indexPathForSelectedRow else {return}
////            if let destinataion = segue.destination as? ConversationViewController {
////                destinataion.userID = frc?.object(at: selectedIndexPath)
////            }
//        }
    }
    // MARK: - actions
    @IBAction func configButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showThemeaView", sender: nil)
    }

    func configCommunicator() {
//        let userProfile = StorageManager.singleton.findOrInsert(in: StorageManager.singleton.coreDataStack.mainContext!, aModel: User.self)
//        if let name = userProfile?.name {
//            self.communicator = CommunicationManager(delegate: self, fetchResultDelegate: self, peerID: name)
//        } else {
//            self.communicator = CommunicationManager(delegate: self, fetchResultDelegate: self, peerID: "default")
//        }
//        self.frc = RequestAndFetchingHandler.frcForUsers(delegate: self)
//        do {
//            try frc?.performFetch()
//        } catch {
//            print("perform Fetching FRC done with errors")
//        }
    }

}

// MARK: - TableView methods
//extension ConversationListViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        guard let secitions = self.frc?.sections else {
////            fatalError("No sections in fetchedResultsController")
////        }
////        let sectionInfo = secitions[section]
////        return sectionInfo.numberOfObjects
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = self.tableViewOfChats.dequeueReusableCell(withIdentifier: "ChatCell")
//            as? ChatCell
//            else {
//                return UITableViewCell()
//             }
////        if let user = self.frc?.object(at: indexPath) {
////            //print("user to table \(user)")
////            cell.configProperies(withChatModel: user)
////        }
////        cell.accessoryType = .disclosureIndicator
//        return cell
//    }
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "Online"
//        } else {
//            return "Offline"
//        }
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "toChat", sender: nil)
//    }
//
//}

//extension ConversationListViewController: CommunicatorViewControllerDelegate {
//    func communicationManagerFoundNewUser() {
//        DispatchQueue.main.async {
//            self.tableViewOfChats.reloadData()
//        }
//    }
//
//    func communicationManagerRecieveMessage(forUser: User) {
//        DispatchQueue.main.async {
//            self.tableViewOfChats.reloadData()
//        }
//    }
//}

//extension ConversationListViewController: NSFetchedResultsControllerDelegate {
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableViewOfChats.endUpdates()
//    }
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableViewOfChats.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            self.tableViewOfChats.insertRows(at: [newIndexPath!], with: .automatic)
//        case .move:
//            self.tableViewOfChats.deleteRows(at: [indexPath!], with: .automatic)
//            self.tableViewOfChats.insertRows(at: [newIndexPath!], with: .automatic)
//        case .update:
//            self.tableViewOfChats.reloadRows(at: [indexPath!], with: .automatic)
//        case .delete:
//            self.tableViewOfChats.deleteRows(at: [indexPath!], with: .automatic)
//        }
//    }
//}
