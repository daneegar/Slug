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
    var presenter: PresenterForConversationList?
    lazy var presenterUnwraped: PresenterForConversationList = {
        guard let presenter = self.presenter else {fatalError("Presenter hasn't been unwraped \(#function)")}
        return presenter
    } ()

    @IBOutlet weak var isBrowserMode: UISwitch!

    @IBOutlet weak var tableViewOfChats: UITableView!

    @IBAction func toggleSwitch(_ sender: Any) {
        self.presenterUnwraped.switcherWasToggled(isOn: self.isBrowserMode.isOn)
    }
    
    @IBAction func showProfileViewController(_ sender: Any) {
        self.presenterUnwraped.presentMainUserView(presentType: .modal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let presenter = ConversationListPresenter(uiNavigationController: self.navigationController,
                                                   uiViewController: self,
                                                   tableView: self.tableViewOfChats,
                                                   typesOfItems: User.self)
        self.presenter = presenter
        self.tableViewOfChats.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "ChatCell")
        self.navigationItem.title = "Tinkoff Chat"
    }
}
extension ConversationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenterUnwraped.showView(forItem: indexPath, presentType: .pushInNavigationStack)
        self.tableViewOfChats.deselectRow(at: indexPath, animated: true)
    }
}
