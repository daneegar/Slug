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


class ConversationListPresenter: NSObject {
    
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


