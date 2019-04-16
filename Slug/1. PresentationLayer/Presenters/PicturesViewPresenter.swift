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

    private let presentationAssembly: IPresentationAssembly
    private weak var uiViewControllerToWorkWith: PicturesViewControllerProtocol?
    private weak var collectionView: UICollectionView?
    private let model: IPhotosModel
    private let delegate: TakeImageDelegate
    let loadingQueue = OperationQueue()
    var loadingOperations: [IndexPath: OperationPhotosModel] = [:]
    
    var urls: [String]?
    
    init (forViewController vc: PicturesViewControllerProtocol,
          presentationAssembly: IPresentationAssembly,
          model: IPhotosModel,
          delegate: TakeImageDelegate) {
        self.model = model
        self.uiViewControllerToWorkWith = vc
        self.collectionView = vc.collectionView
        self.presentationAssembly = presentationAssembly
        self.delegate = delegate
        super.init()
        vc.collectionView.dataSource = self
        vc.collectionView.delegate = self
        self.uiViewControllerToWorkWith?.presenter = self
        self.model.getUrlsForPictures { (urls) in
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

extension PicturesViewPresenter: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoCell else { return }
        let updateCellClosure: (UIImage?) -> Void = { [weak self] image in
            guard let self = self else {
                return
            }
            cell.updateAppearanceFor(image, animated: true)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        if let dataLoader = loadingOperations[indexPath] {
            // 3
            if let image = dataLoader.image {
                cell.updateAppearanceFor(image, animated: false)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                // 4
                dataLoader.loadingComplitionHandler = updateCellClosure
            }
        } else {
            guard let urls = self.urls else {fatalError()}
            let dataLoader = OperationPhotosModel(urls[indexPath.row], model: self.model)
            dataLoader.loadingComplitionHandler = updateCellClosure
            loadingQueue.addOperation(dataLoader)
            loadingOperations[indexPath] = dataLoader
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                                     didEndDisplaying cell: UICollectionViewCell,
                                     forItemAt indexPath: IndexPath) {
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = self.collectionView?.cellForItem(at: indexPath) as? PhotoCell,
        let image = cell.image
        else {fatalError()}
        self.presentationAssembly.presentView(ofPhoto: image,
                                              sender: self.uiViewControllerToWorkWith?.navigationController,
                                              delegate: self.delegate)
    }
}


