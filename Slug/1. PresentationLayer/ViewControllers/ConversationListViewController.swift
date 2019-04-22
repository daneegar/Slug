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

protocol ConversationListViewControllerProtocol: UIViewController {
    var tableViewOfChats: UITableView! {get}
    var presenter: PresenterForConversationList? {get set}
}

class ConversationListViewController: UIViewController, ConversationListViewControllerProtocol, UIGestureRecognizerDelegate {
    
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
        self.tableViewOfChats.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "ChatCell")
        self.navigationController?.navigationBar.backItem?.title = ""
    }

}
extension ConversationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenterUnwraped.showView(forItem: indexPath, presentType: .pushInNavigationStack)
        self.tableViewOfChats.deselectRow(at: indexPath, animated: true)
    }
}





//class TinkoffGestureRecognizer: UIGestureRecognizer {
//    
//    var tinkofLogos: TinkoffTouchesEventHandler?
//    override init(target: Any?, action: Selector?) {
//        super.init(target: target, action: action)
//    }
//    
//    func addTinkoffEffect() {
//        guard let view = self.view else {fatalError()}
//        self.tinkofLogos = TinkoffTouchesEventHandler(vc: view)
//    }
//    
//    func addTableView(tableView: UITableView) {
//        self.tableView = tableView
//    }
//    
//    var trackedTouch: UITouch? = nil
//    var tableView: UITableView?
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(target: nil, action: nil)
//    }
//    
//    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
//        guard let tv = self.tableView else {return}
//        tv.touchesEstimatedPropertiesUpdated(touches)
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
//        print("\(#function)")
//        if touches.count != 1 {
//            self.state = .failed
//            
//        }
//        guard let tv = self.tableView else {return}
//        print(touches.count)
//        if self.trackedTouch == nil {
//            if let firstTouch = touches.first {
//                self.trackedTouch = firstTouch
//                tv.touchesBegan(touches, with: event)
//                self.tinkofLogos?.showLogos(atPlace: firstTouch.location(in: tv))
//                state = .began
//            }
//        } else {
//            for touch in touches {
//                if touch != self.trackedTouch {
//                    self.ignore(touch, for: event)
//                }
//            }
//        }
//    }
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(touches.first!.location(in: self.view))
//        //print(touches.first)
//        guard let tv = self.tableView else {return}
//        tv.touchesMoved(touches, with: event)
//        self.tinkofLogos?.showLogos(atPlace: touches.first!.location(in: self.view))
//        print("\(#function)")
//        state = .changed
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        //print(touches.count)
//        print(touches.first!.location(in: self.view))
//        guard let tv = self.tableView else {return}
//        tv.touchesEnded(touches, with: event)
//        self.tinkofLogos?.stop()
//        print("\(#function)")
//        //print(touches.first)
//        state = .ended
//    }
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(touches.first!.location(in: self.view))
//        guard let tv = self.tableView else {return}
//        tv.touchesCancelled(touches, with: event)
//        self.tinkofLogos?.stop()
//        print("\(#function)")
//        state = .cancelled
//    }
//    
//    override func reset() {
//        print("\(#function)")
//        self.trackedTouch = nil
//    }
//}

