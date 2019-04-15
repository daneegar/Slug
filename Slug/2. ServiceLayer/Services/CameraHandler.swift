//
//  CameraHandler.swift
//  Talks
//
//  Created by Denis Garifyanov on 17/02/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit

protocol AddPcitureHandler {
    func camera()
    func photoLibrary()
}

class CameraHandler: NSObject, AddPcitureHandler {
    
    private weak var currentVC: UIViewController!
    private weak var delegate: TakeImageDelegate!
    
    init (viewController: UIViewController, delegate: TakeImageDelegate) {
        self.currentVC = viewController
        self.delegate = delegate
        
    }

    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            currentVC.present(myPickerController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Камера не доступна", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.currentVC.present(alert, animated: true)
        }
    }

    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            currentVC.present(myPickerController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Галерея не доступна", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.currentVC.present(alert, animated: true)
        }
    }
}

extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        self.delegate.pickTaken(image: selectedImage)
        currentVC.dismiss(animated: true, completion: nil)
    }

}
