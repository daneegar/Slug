//
//  ImageService.swift
//  Slug
//
//  Created by Denis Garifyanov on 17/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit.UIImage

protocol IimageService {
    func getImage(byUrl url: String, complitionHandler: @escaping (UIImage?, String?) -> Void)
    func operation(url: String) -> OperationPhotosModel
}

class ImageService: IimageService {
    func operation(url: String) -> OperationPhotosModel {
        let operation = OperationPhotosModel(url, service: self)
        return operation
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

fileprivate class GetImage: IRequest {
    var urlRequest: URLRequest?
    init(byString url: String) {
        guard let url = URL(string: url) else {fatalError("URL hasn't been created")}
        self.urlRequest = URLRequest(url: url)
    }
}

fileprivate class UIImageParser: IParser {
    typealias Model = UIImage
    func parse(data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}

fileprivate extension RequestFactory {
    static func getImage(byUrl url: String) -> RequestConfig<UIImageParser> {
        return RequestConfig<UIImageParser>(request: GetImage(byString: url), parser: UIImageParser())
    }
}

class OperationPhotosModel: Operation {
    var url: String
    var service: IimageService
    var loadingComplitionHandler: ((UIImage) -> Void)?
    var image: UIImage?
    
    init(_ url: String, service: IimageService) {
        self.service = service
        self.url = url
    }
    override func main() {
        if isCancelled {return}
        self.service.getImage(byUrl: self.url) { (image, error) in
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
