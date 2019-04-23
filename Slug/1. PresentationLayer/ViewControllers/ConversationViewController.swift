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
    @IBOutlet weak var conversationBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sendMessageView: UIView!
    @IBOutlet weak var sendButtonView: UIView!
    @IBOutlet weak var nameOfOpponentLabel: UILabel!
    @IBOutlet weak var upMenu: UIView!
    @IBOutlet weak var onlineStatus: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var onlineStatusWidth: NSLayoutConstraint!
    var defaultOffset: CGFloat?
    var originalHeightOfButton: CGFloat?
    var presenter: PresenterForConversationViewController!
    var defaultOnlineStatusConstraint: CGFloat!
    var isOffline: Bool? = false {
        didSet {
            if oldValue != isOffline {
                if isOffline! {
                    UIView.animate(withDuration: 1.0) {
                        self.upMenu.backgroundColor = #colorLiteral(red: 0.8273689151, green: 0.8275085092, blue: 0.8273505569, alpha: 1)
                        self.onlineStatusWidth.constant -= self.defaultOnlineStatusConstraint
                        self.view.layoutIfNeeded()
                    }
                } else {
                    UIView.animate(withDuration: 1.0) {
                        self.upMenu.backgroundColor = #colorLiteral(red: 0.9997457862, green: 0.8681770563, blue: 0.00762256328, alpha: 1)
                        self.onlineStatusWidth.constant += self.defaultOnlineStatusConstraint
                        self.view.layoutIfNeeded()
                    }
                }
            } else {
                
            }
        }
    }
    var canSend: Bool? = true {
        didSet {
            if oldValue != canSend {
                if !canSend! {
                    self.sendButton.isEnabled = false
                    UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: {
                            self.sendButtonView.backgroundColor = #colorLiteral(red: 0.8273689151, green: 0.8275085092, blue: 0.8273505569, alpha: 1)
                            let transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                            self.sendButton.transform = transform
                        
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.2, animations: {
                            let transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                            self.sendButton.transform = transform
                        })
                    }, completion: nil)
                } else {
                    self.sendButton.isEnabled = true
                    UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: {
                            self.sendButtonView.backgroundColor = #colorLiteral(red: 1, green: 0.8678753972, blue: 0, alpha: 1)
                            let transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                            self.sendButton.transform = transform
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.2, animations: {
                            let transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                            self.sendButton.transform = transform
                        })
                    }, completion: nil)

                }
            }
        }
    }
    var keyboardIsShown = false
    @IBAction func sendButtonPressed(_ sender: Any) {
        presenter.sendMessage(text: self.textMessageView.text)
        self.textMessageView.text = ""
        self.update(textView: self.textMessageView)
    }
    @IBOutlet weak var converstaionTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainViewConfiguring()
        self.converstaionTableView.register(UINib(nibName: "IncomingMessagCell", bundle: nil),
                                            forCellReuseIdentifier: MessageType.inComingMessage.rawValue)
        self.converstaionTableView.register(UINib(nibName: "OutGoingMessageCell", bundle: nil),
                                            forCellReuseIdentifier: MessageType.outGoingMessage.rawValue)
        self.converstaionTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.converstaionTableView.keyboardDismissMode = .onDrag
        self.converstaionTableView.separatorStyle = .none
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
    
    func mainViewConfiguring() {
        
        self.mainView.layer.cornerRadius = 10
        self.mainView.layer.shadowRadius = 2.0
        self.mainView.layer.shadowOffset = .zero
        self.mainView.layer.shadowOpacity = 0.5
        
        self.sendMessageView.layer.cornerRadius = 10
        self.sendMessageView.layer.shadowRadius = 2.0
        self.sendMessageView.layer.shadowOffset = .zero
        self.sendMessageView.layer.shadowOpacity = 0.5
        self.textMessageView.layer.cornerRadius = 5
        self.textMessageView.layer.borderWidth = 0.5
        self.textMessageView.layer.borderColor = #colorLiteral(red: 0.8039951324, green: 0.8038140535, blue: 0.8124365211, alpha: 1)
        
        self.sendButtonView.layer.cornerRadius = 10
        self.sendButtonView.layer.shadowRadius = 2.0
        self.sendButtonView.layer.shadowOffset = .zero
        self.sendButtonView.layer.shadowOpacity = 0.5
        
        self.update(textView: self.textMessageView)
        self.originalHeightOfButton = self.sendButton.bounds.height
        let origImage = UIImage(named: "sendIcon")
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        sendButton.setImage(tintedImage, for: [.normal])
        sendButton.tintColor = UIColor.black
        self.canSend = false
        self.textMessageView.isScrollEnabled = false
        self.textMessageView.textContainer.heightTracksTextView = true
        self.textMessageView.endFloatingCursor()
        self.textMessageView.selectedTextRange = textMessageView.textRange(from: textMessageView.beginningOfDocument,
                                                                           to: textMessageView.beginningOfDocument)
    }
    
    func update(textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)

        self.textViewHeight.constant = estimatedSize.height
        UIView.animate(withDuration: 0.1) {
            //self.mainView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
        if self.defaultOffset == nil{
            self.defaultOffset = self.mainView.bounds.height + 8
            self.converstaionTableView.contentInset.top = self.defaultOffset!
        }
    }
}

extension ConversationViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardIsShown {return} else {keyboardIsShown = !keyboardIsShown}
        if let keyboardSize=(notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey]as?NSValue)?.cgRectValue {
            let pointToGo = CGPoint(x: 0, y: 0 - self.defaultOffset!)
            self.converstaionTableView.setContentOffset(pointToGo, animated: false)
            UIView.animate(withDuration: 1) {
                self.bottomConstraint.constant += keyboardSize.height
                self.conversationBottomConstraint.constant += keyboardSize.height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if !keyboardIsShown {return} else {keyboardIsShown = !keyboardIsShown}
        if let keyboardSize=(notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey]as?NSValue)?.cgRectValue {
                UIView.animate(withDuration: 1) {
                self.bottomConstraint.constant -= keyboardSize.height
                self.conversationBottomConstraint.constant -= keyboardSize.height
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension ConversationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.updateSendButton()
        self.update(textView: textView)
    }
    func updateSendButton(){
        var can = true
        guard let status = self.isOffline else {fatalError()}
        if status {
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
        self.defaultOnlineStatusConstraint = self.onlineStatusWidth.constant
        self.onlineStatusWidth.constant = isOffline ? 0 : self.defaultOnlineStatusConstraint
        self.isOffline = isOffline
        self.nameOfOpponentLabel.text = conversationName
        self.upMenu.layer.cornerRadius = 10
        self.upMenu.layer.shadowRadius = 2.0
        self.upMenu.layer.shadowOffset = .zero
        self.upMenu.layer.shadowOpacity = 0.5
    }
}


