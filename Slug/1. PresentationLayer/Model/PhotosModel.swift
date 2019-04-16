//
//  PhotosModel.swift
//  Slug
//
//  Created by Denis Garifyanov on 17/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit.UIImage

protocol IPhotosModel {
    func getUrlsForPictures(complition: (([String]?)->Void)?)
    func getImage(byUrl url: String, complitionHandler: @escaping (UIImage?, String?) -> Void)
}

class PhotosModel: IPhotosModel {
    func getUrlsForPictures(complition: (([String]?) -> Void)?) {
        self.getCats { (cats, error) in
            if let error = error {
                print(error)
                return
            }
            if let cats = cats {
                let result = cats.map({$0.url})
                complition?(result)
            }
        }
    }
    
    func getCats(complitionHandler: @escaping ([CatApiModel]?, String?) -> Void) {
        let requestConfig = RequestFactory.getCats()
        let requestSender = RequestSender()
        requestSender.send(config: requestConfig) { (result: Result<[CatApiModel]>) in
            switch result {
            case .success(let cats):
                complitionHandler(cats, nil)
            case .error(let error):
                complitionHandler(nil, error)
            }
        }
    }
    
    func getImage(byUrl url: String, complitionHandler: @escaping (UIImage?, String?) -> Void) {
        let requestConfig = RequestFactory.getImage(byUrl: url)
        let requserSender = RequestSender()
        requserSender.send(config: requestConfig) { (result: Result<UIImage>) in
            switch result {
            case .success(let image):
                complitionHandler(image, nil)
            case .error(let error):
                complitionHandler(nil, error)
            }
        }
    }
}
class OperationPhotosModel: Operation {
    var url: String
    var model: IPhotosModel
    var loadingComplitionHandler: ((UIImage) -> Void)?
    var image: UIImage?
    
    init(_ url: String, model: IPhotosModel) {
        self.model = model
        self.url = url
    }
    override func main() {
        if isCancelled {return}
        self.model.getImage(byUrl: self.url) { (image, error) in
            if let error = error {
                print(error)
                return
            }
            if let image = image {
                self.image = image
                DispatchQueue.main.async {
                    self.loadingComplitionHandler?(image)
                }
            }
        }
    }
}


