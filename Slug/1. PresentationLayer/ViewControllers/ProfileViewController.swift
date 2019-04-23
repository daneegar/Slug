//
//  ViewController.swift
//  Talks
//
//  Created by Denis Garifyanov on 09/02/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import UIKit

protocol MainUserProfileView: UIViewController {
    func profileLoaded(name: String, informationAbout: String, profilePhoto: UIImage?)
    func updateProfilePhoto(whitImage image: UIImage)
    func show(allert: UIAlertController)
    var presenter: PresenterForProfileViewController? {get set}
    var switchOne: UISwitch! {get set}
    var charachterCounter: UILabel!{get set}
    var maxCharOfName: Int {get set}
    var maxCharOfAboutInformation: Int {get set}
}

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    var presenter: PresenterForProfileViewController?
    
    var maxCharOfName: Int = 30
    var maxCharOfAboutInformation: Int = 200
    
    @IBOutlet weak var charachterCounter: UILabel!
    var keyboardHeight: CGFloat!
    var activeField: UITextView?
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var gestRegognizers: [UIGestureRecognizer] = []
    private var editingModeOn = false
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var tinkoffEffectSwitcherView: UIView!
    @IBOutlet weak var switchOne: UISwitch!
    @IBOutlet weak var iconAddPhoto: UIView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var buttinViewBottom: NSLayoutConstraint!
    @IBOutlet weak var iconAddPhotoHeight: NSLayoutConstraint!
    @IBOutlet weak var iconAddPhotoWidth: NSLayoutConstraint!
    var defaultIconAddPhotoHeight: CGFloat!
    var defaulticonAddPhotoWidth: CGFloat!
    
    
    @IBAction func addPhoto(_ sender: Any) {
        guard let presenter = self.presenter else {fatalError()}
        presenter.addPictureButtonPressed()
    }
    @IBAction func editingModeButtonPressed(_ sender: Any) {
        if self.editingModeOn {
            self.presenter?.saveButtonPressed(withName: self.nameTextField.text,
                                              aboutInformation: self.aboutTextView.text,
                                              avatar: self.profilePhoto.image)
        }
        self.switchEditingMode()
    }

    @IBAction func doneButtonPressed (_ sender: Any) {
        self.presenter?.doneButtonPressed()
    }
    @IBAction func switchOneToggled(_ sender: Any) {
        self.presenter?.tinkoffEffectSwithcToggled(isOn: self.switchOne.isOn)
    }
    
    
    override func viewDidLoad() {
        self.presenter?.viewControllerDidLoad()
        self.contentScrollView.flashScrollIndicators()
        self.setupDelegates()
        self.disableEditingMode()
        self.addObserveToKeyboard()
        self.setupActivityIndicator()
        super.viewDidLoad()
        self.setupButtons()
        self.setupProfilePhotoImageAndAddButton()
        self.setupView()
    }
    
    private func setupView() {
        self.defaulticonAddPhotoWidth = iconAddPhotoWidth.constant
        self.defaultIconAddPhotoHeight = iconAddPhotoHeight.constant
        self.iconAddPhotoHeight.constant = 0
        self.iconAddPhotoWidth.constant = 0
        
        self.charachterCounter.alpha = 0
        self.aboutTextView.layer.cornerRadius = 5
        self.aboutTextView.layer.borderWidth = 0.5
        self.aboutTextView.layer.borderColor = #colorLiteral(red: 0.8039951324, green: 0.8038140535, blue: 0.8124365211, alpha: 1)
        self.photoView.layer.cornerRadius = 40
        self.photoView.layer.shadowRadius = 2.0
        self.photoView.layer.shadowOffset = .zero
        self.photoView.layer.shadowOpacity = 0.5
        self.nameView.layer.cornerRadius = 10
        self.nameView.layer.shadowRadius = 2.0
        self.nameView.layer.shadowOffset = .zero
        self.nameView.layer.shadowOpacity = 0.5
        self.aboutView.layer.cornerRadius = 10
        self.aboutView.layer.shadowRadius = 2.0
        self.aboutView.layer.shadowOffset = .zero
        self.aboutView.layer.shadowOpacity = 0.5
    }
    
    // MARK: - functions to setup View
    private func setupButtons() {
        self.buttonEdit.layer.cornerRadius = 10
        self.buttonEdit.titleLabel?.text = !self.editingModeOn ? "Save" : "Edit"
        self.buttonEdit.layer.shadowRadius = 2.0
        self.buttonEdit.layer.shadowOffset = .zero
        self.buttonEdit.layer.shadowOpacity = 0.5

        self.tinkoffEffectSwitcherView.layer.cornerRadius = 10
        self.tinkoffEffectSwitcherView.layer.shadowRadius = 2.0
        self.tinkoffEffectSwitcherView.layer.shadowOffset = .zero
        self.tinkoffEffectSwitcherView.layer.shadowOpacity = 0.5
    }
    private func setupProfilePhotoImageAndAddButton() {
        self.profilePhoto.layer.cornerRadius = 40
        self.iconAddPhoto.layer.cornerRadius = 40
    }

    private func setupActivityIndicator() {
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = view.center
        self.view.addSubview(activityIndicator)
    }


    private func setupDelegates() {
        self.nameTextField.delegate = self
        self.aboutTextView.delegate = self
        self.nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
}
// MARK: - editing mode handlers
extension ProfileViewController: UITextFieldDelegate, UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count <= self.maxCharOfAboutInformation {
            UIView.animate(withDuration: 0.1) {
            self.charachterCounter.text = "\(self.aboutTextView.text.count) / \(self.maxCharOfAboutInformation)"
            self.charachterCounter.layoutIfNeeded()
            }
        } else {
            textView.text.removeLast()
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        
    }

    func disableEditingMode() {
        self.aboutTextView.isEditable = false
        self.aboutTextView.textColor = UIColor(rgb: 0xD3D3D3, alpha: 1.0)
        self.nameTextField.isEnabled = false
        self.nameTextField.textColor = UIColor(rgb: 0xD3D3D3, alpha: 1.0)
        
    }
    func switchEditingMode() {
        self.editingModeOn = !self.editingModeOn
        UIView.animate(withDuration: 0.3) {
            self.charachterCounter.text = "\(self.aboutTextView.text.count) / \(self.maxCharOfAboutInformation)"
            self.charachterCounter.alpha = self.editingModeOn ? 1 : 0
            self.aboutTextView.isEditable = self.editingModeOn
            self.aboutTextView.textColor = self.editingModeOn ? .black : UIColor(rgb: 0xD3D3D3, alpha: 1.0)
            self.nameTextField.isEnabled = self.editingModeOn
            self.nameTextField.textColor = self.editingModeOn ? .black : UIColor(rgb: 0xD3D3D3, alpha: 1.0)
            
            self.iconAddPhotoHeight.constant = self.editingModeOn ? self.defaultIconAddPhotoHeight : 0
            self.iconAddPhotoWidth.constant = self.editingModeOn ? self.defaulticonAddPhotoWidth : 0
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.3, animations: {
            if self.editingModeOn {
                self.buttonEdit.setTitle("Save", for: .normal)
            } else {
                self.buttonEdit.setTitle("Edit", for: .normal)
            }
            self.contentView.layoutIfNeeded()
        }, completion: nil)

    }
}

// MARK: - keyboard methods and observers
extension ProfileViewController {
    func addObserveToKeyboard() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                           name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHied(notification:)),
                           name: UIResponder.keyboardWillHideNotification, object: nil)
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize=(notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey]as?NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
                if self.buttinViewBottom.constant == 8 {
                    self.letsChangeConstraintsWhenKeyboardHideAndShow(isHide: false)
                }
        }
    }
    @objc func keyboardWillHied(notification: NSNotification) {
            if self.buttinViewBottom.constant != 8 {
                self.letsChangeConstraintsWhenKeyboardHideAndShow(isHide: true)
            }
    }
    func letsChangeConstraintsWhenKeyboardHideAndShow(isHide: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            if isHide {
                let contentInset: UIEdgeInsets = UIEdgeInsets.zero
                self.contentScrollView.contentInset = contentInset
            } else {
                var contentInset: UIEdgeInsets = self.contentScrollView.contentInset
                contentInset.bottom = self.keyboardHeight
                self.contentScrollView.contentInset = contentInset
                var pointToGo = self.contentScrollView.contentOffset
                pointToGo = CGPoint(x: pointToGo.x, y: pointToGo.y + self.keyboardHeight)
                self.contentScrollView.setContentOffset(pointToGo, animated: false)
            }
            self.buttinViewBottom.constant =  isHide ? 8 : self.buttinViewBottom.constant + self.keyboardHeight
            self.view.layoutIfNeeded()
        })
    }

    @objc func endEditing() {
        self.aboutTextView.endEditing(true)
        self.nameTextField.endEditing(true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate {
}

extension ProfileViewController: MainUserProfileView {
    
    func show(allert: UIAlertController) {
        self.present(allert, animated: true, completion: nil)
    }
    
    func updateProfilePhoto(whitImage image: UIImage) {
        self.profilePhoto.image = image
    }
    
    func profileLoaded(name: String, informationAbout: String, profilePhoto: UIImage?) {
        self.nameTextField.text = name
        self.aboutTextView.text = informationAbout
        self.profilePhoto.image = profilePhoto
    }
    
}
