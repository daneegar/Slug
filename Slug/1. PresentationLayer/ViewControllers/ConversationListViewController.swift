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
    
    @IBAction func showProfileViewController(_ sender: Any) {
        self.presenterUnwraped.presentMainUserView(presentType: .modal)
    }
    
    var presenter: PresenterForConversationList?
    lazy var presenterUnwraped: PresenterForConversationList = {
        guard let presenter = self.presenter else {fatalError("Presenter hasn't been unwraped \(#function)")}
        return presenter
    } ()

    override func viewDidLoad() {
        super.viewDidLoad()
        let presenter = ConversationListPresenter(uiNavigationController: self.navigationController,
                                                   uiViewController: self,
                                                   tableView: self.tableViewOfChats,
                                                   typesOfItems: User.self)
        self.presenter = presenter
        self.tableViewOfChats.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "ChatCell")
        self.tableViewOfChats.reloadData()
        self.navigationItem.title = "Tinkoff Chat"
    }

    // MARK: - lets test our TableView with Cells
    private func richList() {
    }

    func logThemeChanging(selectedTheme: UIColor) {
        print("theme has been changed!")
    }

    // MARK: - actions
    @IBAction func configButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showThemeaView", sender: nil)
    }


}
