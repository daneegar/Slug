//
//  PictureViewController.swift
//  Slug
//
//  Created by Denis Garifyanov on 16/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit

protocol PresenterForPicturesViewController {
    func cancelButtonPressed()
}

class PicturesViewPresenter: NSObject, PresenterForPicturesViewController {

    let presentationAssembly: IPresentationAssembly
    weak var uiViewControllerToWorkWith: PicturesViewControllerProtocol?
    
    var urls: [String]?
    
    init (forViewController vc: PicturesViewControllerProtocol, presentationAssembly: IPresentationAssembly) {
        self.uiViewControllerToWorkWith = vc
        self.presentationAssembly = presentationAssembly
        super.init()
        self.uiViewControllerToWorkWith?.presenter = self
        self.presentationAssembly.getUrlsForPictures { (urls) in
            if let urls = urls {
                self.urls = urls
            } else {
                print("nothing been parsed")
            }
        }
    }
    
    func cancelButtonPressed() {
        uiViewControllerToWorkWith?.dismiss(animated: true, completion: nil)
    }
}

//extension PicturesViewPresenter: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//}
