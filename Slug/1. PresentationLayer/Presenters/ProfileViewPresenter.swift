//
//  ProfileViewPresenter.swift
//  Slug
//
//  Created by Denis Garifyanov on 05/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

protocol TakeImageDelegate: class {
    func pickTaken(image takenImage: UIImage)
}

protocol PresenterForProfileViewController {
    func saveButtonPressed(withName name: String?, aboutInformation info: String?, avatar image: UIImage?)
    func doneButtonPressed()
    func viewControllerDidLoad()
    func addPictureButtonPressed()
    func tinkoffEffectSwithcToggled(isOn: Bool)
}

import Foundation
import UIKit.UIAlertController

class ProfileViewPresenter: NSObject, PresenterForProfileViewController {

    weak var viewControlerToWorkWith: MainUserProfileView!
    let mainUserProfile: MainUser
    let okAllert = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: .alert)
    var cameraHandler: AddPcitureHandler!
    let presentationAssembly: IPresentationAssembly
    let windowToControl: IWindowWithTouchTrace?
    
    private func setupAllerts() {
        self.okAllert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    init(viewController: MainUserProfileView,
         presentationAssembly: IPresentationAssembly,
         windowToControl: IWindowWithTouchTrace? = nil) {
        self.presentationAssembly = presentationAssembly
        self.viewControlerToWorkWith = viewController
        self.windowToControl = windowToControl
        guard let userProfile = StorageManager.singleton.findLast(in: .mainContext, aModel: MainUser.self) else {fatalError("MainUser hasn't been created or loaded")}
        self.mainUserProfile = userProfile
        super.init()
        self.viewControlerToWorkWith.presenter = self
        self.cameraHandler = CameraHandler(viewController: viewController, delegate: self)

    }
    
    func saveButtonPressed(withName name: String?, aboutInformation info: String?, avatar image: UIImage?) {
        self.mainUserProfile.name = name
        self.mainUserProfile.aboutInfirmation = info
        self.mainUserProfile.avatar = image?.jpegData(compressionQuality: 1.0)
        StorageManager.singleton.storeData(inTypeOfContext: .saveContext) {
            print("Данные сохранены")
        }
    }
    
    func doneButtonPressed() {
        self.viewControlerToWorkWith.dismiss(animated: true, completion: nil)
    }
    
    func addPictureButtonPressed() {
        print("Выбери изображение профиля")
        self.showActionSheet()
    }
    
    func tinkoffEffectSwithcToggled(isOn: Bool) {
        guard let window = self.windowToControl else {return}
        if isOn {
            window.setTrasingEnable()
            return
        }
        window.setTrasingDisable()
    }
    
    
    func viewControllerDidLoad() {
        let name: String
        let aboutInfo: String
        let profilePhoto: UIImage?
        if let n =  self.mainUserProfile.name{
            name = n
        } else {name = "Whrite your name"}
        if let i = self.mainUserProfile.aboutInfirmation {
            aboutInfo = i
        } else {aboutInfo = "Whrite about you!"}
        if let dataPhoto = self.mainUserProfile.avatar {
            let photo = UIImage(data: dataPhoto)
            profilePhoto = photo
        } else {profilePhoto = nil}
        self.viewControlerToWorkWith.profileLoaded(name: name, informationAbout: aboutInfo, profilePhoto: profilePhoto)
        if let window = windowToControl {
            self.viewControlerToWorkWith.switchOne.isOn = window.trasingIsEnable
            return
        }
        self.viewControlerToWorkWith.switchOne.isEnabled = false
    }
}

extension ProfileViewPresenter: TakeImageDelegate {
    func pickTaken(image takenImage: UIImage) {
        self.viewControlerToWorkWith.updateProfilePhoto(whitImage: takenImage)
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_:UIAlertAction!) -> Void in
            self.cameraHandler.camera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (_:UIAlertAction!) -> Void in
            self.cameraHandler.photoLibrary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Download", style: .default, handler: { (_:UIAlertAction!) -> Void in
            self.presentationAssembly.presentCollectionViewOfPhotos(sender: self.viewControlerToWorkWith, delegate: self)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.viewControlerToWorkWith.show(allert: actionSheet)
    }
}

extension ProfileViewPresenter: UITextViewDelegate {
    
}
