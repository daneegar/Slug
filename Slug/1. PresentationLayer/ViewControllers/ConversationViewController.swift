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
    @IBAction func sendButtonPressed(_ sender: Any) {
        presenter.sendMessage(text: self.textMessageView.text)
        self.textMessageView.text = ""
    }
    @IBOutlet weak var converstaionTableView: UITableView!
    override func viewDidLoad() {
        self.presenter = ConversationPresenter(uiNavigationController: self.navigationController,
                                               uiViewController: self,
                                               tableView: self.converstaionTableView,
                                               conversation: self.conversation)
        self.converstaionTableView.register(UINib(nibName: "IncomingMessagCell", bundle: nil),
                                            forCellReuseIdentifier: MessageType.inComingMessage.rawValue)
        super.viewDidLoad()
        self.converstaionTableView.register(UINib(nibName: "OutGoingMessageCell", bundle: nil),
                                            forCellReuseIdentifier: MessageType.outGoingMessage.rawValue)
        self.textMessageView.isScrollEnabled = false
        self.textMessageView.textContainer.heightTracksTextView = true
        self.textMessageView.endFloatingCursor()
        self.textMessageView.textColor = UIColor.lightGray
        self.converstaionTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.textMessageView.selectedTextRange = textMessageView.textRange(from: textMessageView.beginningOfDocument,
                                                                           to: textMessageView.beginningOfDocument)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        presenter.viewWillHide()
    }
}

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

extension ConversationViewController: ConversationViewControllerProtocol {
    func initConversation(conversation: Conversation) {
        self.conversation = conversation
    }
}
