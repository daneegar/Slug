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
}

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    var presenter: PresenterForProfileViewController?
    
    var keyboardHeight: CGFloat!
    var activeField: UITextView?
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var gestRegognizers: [UIGestureRecognizer] = []
    private var editingModeOn = false
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var buttonGCD: UIButton!
    @IBOutlet weak var buttonOperation: UIButton!
    @IBOutlet weak var iconAddPhoto: UIView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var heightOfProfilePhotoView: NSLayoutConstraint!
    @IBOutlet weak var constraintContenViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttinViewBottom: NSLayoutConstraint!
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

    @IBAction func gcdButtonPressed(_ sender: Any) {
        
    }

    @IBAction func operationButtonPressed(_ sender: Any) {

    }
    override func viewDidLoad() {
        self.presenter?.viewControllerDidLoad()
        self.contentScrollView.flashScrollIndicators()
        self.setupDelegates()
        self.disableEditingMode()
        self.addObserveToKeyboard()
        self.setupActivityIndicator()
        self.saveButtons(makeEnable: false)
        super.viewDidLoad()
        self.setupButtons()
        self.setupProfilePhotoImageAndAddButton()
        self.setupView()
    }
    
    private func setupView() {
        self.aboutTextView.layer.borderColor = UIColor.black.cgColor
        self.aboutTextView.layer.borderWidth = 1.0
        self.contentView.layoutIfNeeded()
    }
    
    // MARK: - functions to setup View
    private func setupButtons() {
        self.buttonEdit.backgroundColor = .white
        self.buttonEdit.layer.borderColor = UIColor(named: "black")?.cgColor
        self.buttonEdit.layer.borderWidth = 1
        self.buttonEdit.layer.cornerRadius = 10
        self.buttonGCD.layer.cornerRadius = 10
        self.buttonOperation.layer.cornerRadius = 10
        self.buttonEdit.titleLabel?.text = !self.editingModeOn ? "Сохранить" : "Редактировать"
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
        //self.checkProfileIsEdited()
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        //self.checkProfileIsEdited()
    }

    func disableEditingMode() {
        self.aboutTextView.isEditable = false
        self.aboutTextView.textColor = UIColor(rgb: 0xD3D3D3, alpha: 1.0)
        self.nameTextField.isEnabled = false
        self.nameTextField.textColor = UIColor(rgb: 0xD3D3D3, alpha: 1.0)
        self.iconAddPhoto.isHidden = true
    }
    func switchEditingMode() {
        self.editingModeOn = !self.editingModeOn
        UIView.animate(withDuration: 0.3) {
            self.aboutTextView.isEditable = self.editingModeOn
            self.aboutTextView.textColor = self.editingModeOn ? .black : UIColor(rgb: 0xD3D3D3, alpha: 1.0)
            self.nameTextField.isEnabled = self.editingModeOn
            self.nameTextField.textColor = self.editingModeOn ? .black : UIColor(rgb: 0xD3D3D3, alpha: 1.0)
            self.iconAddPhoto.isHidden = !self.editingModeOn
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3, animations: {

            if self.editingModeOn {
                self.buttonEdit.setTitle("Сохранить", for: .normal)
            } else {
                self.buttonEdit.setTitle("Редактировать", for: .normal)
            }
            self.contentView.layoutIfNeeded()
        }, completion: nil)

    }
    
    func saveButtons(makeEnable enableStatus: Bool) {
        self.buttonGCD.isEnabled = enableStatus
        self.buttonOperation.isEnabled = enableStatus
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
                self.constraintContenViewHeight.constant -= self.keyboardHeight
            } else {
                self.constraintContenViewHeight.constant += self.keyboardHeight
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
