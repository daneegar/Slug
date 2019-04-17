//
//  CatsServise.swift
//  Slug
//
//  Created by Denis Garifyanov on 17/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
protocol ICatService {
    func getUrlsForPictures(complition: (([String]?) -> Void)?)
}

class CatsService: ICatService {
    private let requestGetCatsConfig = RequestFactory.getCats(limit: 100)
    private let requestSender = RequestSender()
    
 
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
    private func getCats(complitionHandler: @escaping ([CatApiModel]?, String?) -> Void) {
        let requestConfig = RequestFactory.getCats()
        let requestSender = RequestSender()
        requestSender.send(config: requestConfig) { (result: Result<[CatApiModel]>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let cats):
                    complitionHandler(cats, nil)
                case .error(let error):
                    complitionHandler(nil, error)
                }
            }
        }
    }
}

fileprivate struct CatApiModel: Codable {
    let id: String
    let url: String
    let width: Int
    let height: Int
}

fileprivate class GetCatsRequest: IRequest {
    lazy var key: String = {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let plist = NSDictionary(contentsOfFile: path)
            let value = plist?.object(forKey: "ApiKey") as! String
            return value
        }
        else {fatalError()}
    }()
    var urlRequest: URLRequest?
    init(limit: Int = 20) {
        guard let url = URL(string: "https://api.thecatapi.com/v1/images/search?limit=\(String(limit))") else {fatalError("URL hasn't been created")}
        var request = URLRequest(url: url)
        request.setValue(self.key, forHTTPHeaderField: "x-api-key")
        self.urlRequest = request
    }
}
fileprivate class CatItemParser: IParser {
    typealias Model = [CatApiModel]
    func parse(data: Data) -> [CatApiModel]? {
        do {
            let jsonDecoder = JSONDecoder()
            let cats =  try jsonDecoder.decode(Array<CatApiModel>.self, from: data)
            return cats
        }
        catch {print(error)}
        return nil
    }
}

fileprivate extension RequestFactory {
    static func getCats(limit: Int = 100) -> RequestConfig<CatItemParser> {
        return RequestConfig<CatItemParser>(request: GetCatsRequest(limit: limit), parser: CatItemParser())
    }
}
