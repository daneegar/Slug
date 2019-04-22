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
    func setTitle(conversationName: String?, isOffline: Bool)
    var converstaionTableView: UITableView! {get}
    var presenter: PresenterForConversationViewController! {get set}
    func opponentOfConversatoinChangeStatus(isOffline: Bool)
}

class ConversationViewController: UIViewController {
    @IBOutlet weak var textMessageView: UITextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var nameOfOpponentLabel: UILabel!
    @IBOutlet weak var upMenu: UIView!
    @IBOutlet weak var sendButton: UIButton!
    var originalHeightOfButton: CGFloat?
    @IBOutlet weak var sendButtonHeight: NSLayoutConstraint!
    var presenter: PresenterForConversationViewController!
    var isOffline: Bool = true {
        didSet {
                if isOffline {
                    UIView.animate(withDuration: 1.0) {
                        self.upMenu.backgroundColor = UIColor.red
                        let transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                        self.upMenu.transform = transform
                        //self.upMenu.transform = transform
//                        let curentFontName = self.nameOfOpponentLabel.font.fontDescriptor
//                        let currentSize = self.nameOfOpponentLabel.font.pointSize * 0.85
//                        self.nameOfOpponentLabel.font = UIFont(descriptor: curentFontName, size: currentSize)
                        self.upMenu.layoutIfNeeded()
                    }
                } else {
                    UIView.animate(withDuration: 1.0) {
                        self.upMenu.backgroundColor = UIColor.green
                        let transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                        self.upMenu.transform = transform
                        //self.upMenu.transform = transform
                        self.upMenu.layoutIfNeeded()
                    }
                }
        }
    }
    var canSend: Bool? = true {
        didSet {
            if oldValue != canSend {
                if !canSend! {
                    UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: {
                            self.sendButton.isEnabled = false
                            self.sendButtonHeight.constant += self.originalHeightOfButton! * 1.15
                            self.sendButton.layoutIfNeeded()
                            self.mainView.layoutIfNeeded()
                            self.converstaionTableView.layoutIfNeeded()
                        
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.2, animations: {
                            self.sendButtonHeight.constant -= self.originalHeightOfButton! * 1.15
                            self.sendButton.layoutIfNeeded()
                            self.mainView.layoutIfNeeded()
                            self.converstaionTableView.layoutIfNeeded()
                        })
                    }, completion: nil)

                } else {
                    UIView.animate(withDuration: 0.2) {
                        //self.sendButtonHeight.constant -= self.originalHeightOfButton! * 1.15
                        //self.sendButton.backgroundColor = UIColor.blue
                        self.sendButton.isEnabled = true
                    }
                }
            }
        }
    }
    var keyboardIsShown = false
    //    var conversation: Conversation!
    @IBAction func sendButtonPressed(_ sender: Any) {
        presenter.sendMessage(text: self.textMessageView.text)
        self.textMessageView.text = ""
    }
    @IBOutlet weak var converstaionTableView: UITableView!
    override func viewDidLoad() {
        

        self.originalHeightOfButton = self.sendButtonHeight.constant
        let origImage = UIImage(named: "sendIcon")
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        sendButton.setImage(tintedImage, for: [.normal])
        sendButton.tintColor = UIColor(red: 253, green: 223, blue: 44, alpha: 1)
        self.canSend = false
        
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
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

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
        self.updateSendButton()
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        self.textViewHeight.constant = estimatedSize.height
        UIView.animate(withDuration: 0.1) {
            self.mainView.layoutIfNeeded()
            self.converstaionTableView.layoutIfNeeded()
        }
    }
    func updateSendButton(){
        var can = true
        if self.isOffline {
            can = false
        }
        if self.textMessageView.text.count == 0 {
            can = false
        }
        self.canSend = can
    }
}

extension ConversationViewController: ConversationViewControllerProtocol {
    func opponentOfConversatoinChangeStatus(isOffline: Bool) {
        self.isOffline = isOffline
        self.updateSendButton()
    }
    
    func setTitle(conversationName: String?, isOffline: Bool) {
        self.isOffline = isOffline
        self.nameOfOpponentLabel.text = conversationName
    
        self.upMenu.layer.borderColor = UIColor.white.cgColor
        self.upMenu.layer.borderWidth = 1.0
        self.upMenu.layer.cornerRadius = 15.0
        self.upMenu.layer.shadowRadius = 2.0
        self.upMenu.layer.shadowOffset = .zero
        self.upMenu.layer.shadowOpacity = 0.5
    }
}


