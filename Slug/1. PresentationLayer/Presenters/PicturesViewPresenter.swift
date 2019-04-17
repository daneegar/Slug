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

class UrlAndImages {
    let url: String
    var image: UIImage?
    init (url: String) {
        self.url = url
    }
}

class PicturesViewPresenter: NSObject, PresenterForPicturesViewController {

    private let presentationAssembly: IPresentationAssembly
    private weak var uiViewControllerToWorkWith: PicturesViewControllerProtocol?
    private weak var collectionView: UICollectionView?
    private var objects: [UrlAndImages] = []
    private let catsService: ICatService
    private let imageService: IimageService
    private let delegate: TakeImageDelegate
    let loadingQueue = OperationQueue()
    var loadingOperations: [IndexPath: OperationPhotosModel] = [:]
    
    
    init (forViewController vc: PicturesViewControllerProtocol,
          presentationAssembly: IPresentationAssembly,
          catsService: ICatService,
          imageService: IimageService,
          delegate: TakeImageDelegate) {
        self.uiViewControllerToWorkWith = vc
        self.collectionView = vc.collectionView
        self.presentationAssembly = presentationAssembly
        self.delegate = delegate
        self.catsService = catsService
        self.imageService = imageService
        super.init()
        vc.collectionView.dataSource = self
        vc.collectionView.delegate = self
        self.uiViewControllerToWorkWith?.presenter = self
        self.catsService.getUrlsForPictures { (urls) in
            if let url = urls {
                let _ = url.map({self.objects.append(UrlAndImages(url: $0))})
                self.reloadData()
            } else {
                print("nothing been parsed")
            }
        }
    }
    
    func cancelButtonPressed() {
        uiViewControllerToWorkWith?.dismiss(animated: true, completion: nil)
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
}

extension PicturesViewPresenter: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.objects.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.uiViewControllerToWorkWith?.collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
            else {fatalError()}
        if let cell = cell as? PhotoCell {
            if let image = self.objects[indexPath.row].image {
                cell.updateAppearanceFor(image, animated: false)
            } else {
                cell.updateAppearanceFor(.none, animated: false)
            }
        }
        return cell
    }
}

extension PicturesViewPresenter: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoCell else { return }
        self.cellWillDisplay(atIndexPath: indexPath, cell: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                     didEndDisplaying cell: UICollectionViewCell,
                                     forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoCell else { return }
        self.cellDidEndDisplayeng(atIndexPath: indexPath, cell: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = self.collectionView?.cellForItem(at: indexPath) as? PhotoCell else {fatalError()}
        if let image = cell.image {
            self.presentationAssembly.presentView(ofPhoto: image,
                                              sender: self.uiViewControllerToWorkWith?.navigationController,
                                              delegate: self.delegate)
        }
    }
}

extension PicturesViewPresenter: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/3.0 - 5
        let yourHeight = yourWidth
        
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}
//MARK: - cells appearances
extension PicturesViewPresenter {
    func cellWillDisplay(atIndexPath indexPath: IndexPath, cell: PhotoCell) {
        if let image = objects[indexPath.row].image {
            cell.updateAppearanceFor(image, animated: true)
            return
        }
        let updateCellClosure: (UIImage?) -> Void = { [weak self] image in
            guard let self = self else {
                return
            }
            self.objects[indexPath.row].image = image
            cell.updateAppearanceFor(image, animated: true)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        if let dataLoader = loadingOperations[indexPath] {
            // 3
            if let image = dataLoader.image {
                self.objects[indexPath.row].image = image
                cell.updateAppearanceFor(image, animated: false)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                // 4
                dataLoader.loadingComplitionHandler = updateCellClosure
            }
        } else {
            let dataLoader = self.imageService.operation(url: self.objects[indexPath.row].url)
            dataLoader.loadingComplitionHandler = updateCellClosure
            loadingQueue.addOperation(dataLoader)
            loadingOperations[indexPath] = dataLoader
        }
    }
    func cellDidEndDisplayeng(atIndexPath indexPath: IndexPath, cell: PhotoCell) {
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
}



