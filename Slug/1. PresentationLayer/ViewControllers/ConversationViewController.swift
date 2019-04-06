//
//  ConversationViewController.swift
//  Talks
//
//  Created by Denis Garifyanov on 22/02/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//
enum MessageType: String {
    case inComingMessage = "inComingMessageCell"
    case outGoingMessage = "outGoingMessageCell"
}



import UIKit
import MultipeerConnectivity

protocol ConversationViewControllerProtocol: UIViewController {
    func initConversation(conversation: Conversation)
}

class ConversationViewController: UIViewController {
    @IBOutlet weak var textMessageView: UITextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    var presenter: PresenterForConversationViewController!
    var keyboardIsShown = false
    var conversation: Conversation!
//    var frc: NSFetchedResultsController<Message>?
    @IBAction func sendButtonPressed(_ sender: Any) {
//        self.sendAnMessage()
    }
//    var communicator: CommunicationManager?
    @IBOutlet weak var converstaionTableView: UITableView!
//    var userID: User?
//    var conversation: [MessageStruct] = []
    override func viewDidLoad() {
        self.presenter = ConversationPresenter(uiNavigationController: self.navigationController,
                                               uiViewController: self,
                                               tableView: self.converstaionTableView,
                                               conversation: self.conversation)
        self.converstaionTableView.register(UINib(nibName: "IncomingMessagCell", bundle: nil),
                                            forCellReuseIdentifier: MessageType.inComingMessage.rawValue)
        super.viewDidLoad()
//        self.communicator?.delegate = self
        self.converstaionTableView.register(UINib(nibName: "OutGoingMessageCell", bundle: nil),
                                            forCellReuseIdentifier: MessageType.outGoingMessage.rawValue)
//        self.title = userID?.id
//        if let usedId = self.userID, let id = usedId.id {
//            self.frc = RequestAndFetchingHandler.frcForMessages(delegate: self, forUser: id)
//            do { try self.frc?.performFetch() } catch {print("shitHappens")}
//        }
        
        self.textMessageView.isScrollEnabled = false
        self.textMessageView.textContainer.heightTracksTextView = true
        self.textMessageView.endFloatingCursor()
        
        self.textMessageView.textColor = UIColor.lightGray
        self.textMessageView.selectedTextRange = textMessageView.textRange(from: textMessageView.beginningOfDocument,
                                                                           to: textMessageView.beginningOfDocument)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
//        self.converstaionTableView.reloadData()
    }
    // MARK: - lets test ConversationViewController
    func richConversation() {
//        for _ in 0...3 {
//            self.conversation.append(MessageStruct(messageID: "undefined",
//                                                   text: RandomData.randomString(length: 50),
//                                                   typeOfMessage: .inComingMessage))
//            self.conversation.append(MessageStruct(messageID: "undefined",
//                                                   text: RandomData.randomString(length: 30),
//                                                   typeOfMessage: .outGoingMessage))
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        if self.isMovingFromParent {
//            guard let parentViewControoler = self.parent?.children[0] as? ConversationListViewController else {return}
////            parentViewControoler.communicator?.delegate = parentViewControoler
//            parentViewControoler.tableViewOfChats.reloadData()
//        }
    }
}

//extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let count = self.frc?.fetchedObjects?.count else {return 0}
//        return count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let message = self.frc?.object(at: indexPath)
//        let typeOfMessge: MessageType = message!.isOutgoing ? .outGoingMessage : .inComingMessage
//        guard let cellConcept = self.converstaionTableView.dequeueReusableCell(
//            withIdentifier: typeOfMessge.rawValue) as? MessageCell
//            else {return UITableViewCell()}
//        cellConcept.setupCell(whithText: message!.text, andTypeOf: typeOfMessge)
//        return cellConcept
//
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
//}

//extension ConversationViewController: CommunicatorViewControllerDelegate {
//    func communicationManagerRecieveMessage(forUser: User) {
//        DispatchQueue.main.async {
//            self.converstaionTableView.reloadData()
//        }
//    }
//
//    func communicationManagerFoundNewUser() {
//
//    }
//
//    func sendAnMessage() {
//        let message = MessageStruct(messageID: generateMessageId(),
//                                    text: self.textMessageView.text,
//                                    typeOfMessage: .outGoingMessage)
//        let conv = self.userID?.conversation
//        RequestAndFetchingHandler.createMessage { (message) in
//            message?.createTimeStamp = Date()
//            message?.messageID = generateMessageId()
//            message?.text = textMessageView.text
//            conv?.addToMessages(message!)
//        }
//        textMessageView.text = ""
//        guard let userID = self.userID else {return}
//        self.communicator?.communicator.sendMessage(string: message, to: userID.id!, complitionHandler: nil)
//    }
//
//    func generateMessageId() -> String {
//        return "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)"
//            .data(using: .utf8)!.base64EncodedString()
//    }
//
//}

extension ConversationViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardIsShown {return} else {keyboardIsShown = !keyboardIsShown}
        if let keyboardSize=(notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey]as?NSValue)?.cgRectValue {
            self.bottomConstraint.constant += keyboardSize.height
            UIView.animate(withDuration: 0.4) {
                self.mainView.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if !keyboardIsShown {return} else {keyboardIsShown = !keyboardIsShown}
        if let keyboardSize=(notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey]as?NSValue)?.cgRectValue {
            self.bottomConstraint.constant -= keyboardSize.height
            UIView.animate(withDuration: 0.4) {
                self.mainView.layoutIfNeeded()
            }
        }
    }
}

extension ConversationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        self.textViewHeight.constant = estimatedSize.height
        UIView.animate(withDuration: 0.1) {
            self.mainView.layoutIfNeeded()
            self.converstaionTableView.layoutIfNeeded()
        }
    }
}

//extension ConversationViewController: NSFetchedResultsControllerDelegate {
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.converstaionTableView.endUpdates()
//    }
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.converstaionTableView.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            self.converstaionTableView.insertRows(at: [newIndexPath!], with: .automatic)
//        case .move:
//            self.converstaionTableView.deleteRows(at: [indexPath!], with: .automatic)
//            self.converstaionTableView.insertRows(at: [newIndexPath!], with: .automatic)
//        case .update:
//            self.converstaionTableView.reloadRows(at: [indexPath!], with: .automatic)
//        case .delete:
//            self.converstaionTableView.deleteRows(at: [indexPath!], with: .automatic)
//        }
//    }
//}

extension ConversationViewController: ConversationViewControllerProtocol {
    func initConversation(conversation: Conversation) {
        self.conversation = conversation
    }
}
