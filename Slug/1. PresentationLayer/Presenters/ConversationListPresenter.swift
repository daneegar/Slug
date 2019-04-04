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

protocol PresenterForConversationList: UITableViewDataSource {
    func presentMainUserView(presentType: PresentType, inController: UINavigationController?)
    func showView(forItem indexPath: IndexPath, presentType: PresentType, inController: UINavigationController?)
    func switcherWasToggled(isOn: Bool)
    init (uiNavigationController: UINavigationController?, uiViewController: UIViewController?, tableView: UITableView?, typesOfItems: NSManagedObject.Type)
    func viewControllerDidload()
}

enum PresentType {
    case modal, pushInNavigationStack
}

class ConversationListPresenter: NSObject, PresenterForConversationList {
    
    weak var uiNavigationViewControllerToWorkWith: UINavigationController?
    weak var uiViewControllerToWorkWith: UIViewController?
    weak var tableViewToWorkWith: UITableView?
    var frc: NSFetchedResultsController<User>?


    required init (uiNavigationController: UINavigationController?, uiViewController: UIViewController?, tableView: UITableView?, typesOfItems: NSManagedObject.Type = User.self) {
        if let unc = uiNavigationController, let uivc = uiViewController, let tv = tableView {
            self.uiNavigationViewControllerToWorkWith = unc
            self.uiViewControllerToWorkWith = uivc
            self.tableViewToWorkWith = tv
        }
        else {fatalError("There is no some components in ViewController")}
        //self.frc = self.createFrc(withType: typesOfItems)
        //self.tableViewToWorkWith?.dataSource = self
    }
    
    func presentMainUserView(presentType: PresentType, inController: UINavigationController? = nil) {
        
    }
    
    func showView(forItem indexPath: IndexPath, presentType: PresentType, inController: UINavigationController?) {
        
    }
    
    func switcherWasToggled(isOn: Bool) {
        
    }
    
    func viewControllerDidload() {
        self.frc = self.createFrc(withType: User.self)
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
    
    
}

extension ConversationListPresenter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let blancCell = UITableViewCell()
        return blancCell
    }
}

extension ConversationListPresenter: NSFetchedResultsControllerDelegate {
    
}


