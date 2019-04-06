//
//  ProfileViewPresenter.swift
//  Slug
//
//  Created by Denis Garifyanov on 05/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

protocol PresenterForProfileViewController {
    func saveButtonPressed(withName name: String?, aboutInformation info: String?, avatar image: UIImage?)
    func doneButtonPressed()
    func viewControllerDidLoad()
}

import Foundation
import UIKit.UIAlertController

class ProfileViewPresenter: NSObject, PresenterForProfileViewController {
    weak var viewControlerToWorkWith: MainUserProfileView!
    let mainUserProfile: User
    let okAllert = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: .alert)
    
    private func setupAllerts() {
        self.okAllert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    init(viewController: ProfileViewController) {
        self.viewControlerToWorkWith = viewController
        guard let userProfile = StorageManager.singleton.findFirst(in: .mainContext, aModel: User.self) else {fatalError("MainUser hasn't been created or loaded")}
        self.mainUserProfile = userProfile
    }
    
    func saveButtonPressed(withName name: String?, aboutInformation info: String?, avatar image: UIImage?) {
        self.mainUserProfile.name = name
        self.mainUserProfile.aboutInformation = info
        self.mainUserProfile.avatar = image?.jpegData(compressionQuality: 1.0)
        StorageManager.singleton.storeData(inTypeOfContext: .mainContext) {
            print("Данные сохранены")
        }
    }
    
    func doneButtonPressed() {
        self.viewControlerToWorkWith.dismiss(animated: true, completion: nil)
    }
    
    func viewControllerDidLoad() {
        let name: String
        let aboutInfo: String
        let profilePhoto: UIImage?
        if let n =  self.mainUserProfile.name{
            name = n
        } else {name = "Whrite your name"}
        if let i = self.mainUserProfile.aboutInformation {
            aboutInfo = i
        } else {aboutInfo = "Whrite about you!"}
        if let dataPhoto = self.mainUserProfile.avatar {
            let photo = UIImage(data: dataPhoto)
            profilePhoto = photo
        } else {profilePhoto = nil}
        self.viewControlerToWorkWith.profileLoaded(name: name, informationAbout: aboutInfo, profilePhoto: profilePhoto)
    }
}
