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
    weak var collectionView: UICollectionView?
    
    var urls: [String]?
    
    init (forViewController vc: PicturesViewControllerProtocol, presentationAssembly: IPresentationAssembly) {
        self.uiViewControllerToWorkWith = vc
        self.collectionView = vc.collectionView
        self.presentationAssembly = presentationAssembly
        super.init()
        vc.collectionView.dataSource = self
        self.uiViewControllerToWorkWith?.presenter = self
        self.presentationAssembly.getUrlsForPictures { (urls) in
            if let urls = urls {
                self.urls = urls
                self.reloadData()
            } else {
                print("nothing been parsed")
            }
        }
    }
    
    func cancelButtonPressed() {
        uiViewControllerToWorkWith?.dismiss(animated: true, completion: nil)
    }
}

extension PicturesViewPresenter: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let urls = self.urls else { return 0 }
        return urls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.uiViewControllerToWorkWith?.collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
            else {fatalError()}
        if let cell = cell as? PhotoCell {
            cell.updateAppearanceFor(.none, animated: false)
        }
        return cell
    }
    func reloadData() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
}

