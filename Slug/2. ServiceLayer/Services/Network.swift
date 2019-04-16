//
//  CatApi.swift
//  Slug
//
//  Created by Denis Garifyanov on 16/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit.UIImage



struct CatApiModel: Codable {
    let id: String
    let url: String
    let width: Int
    let height: Int
}


enum Result<T> {
    case success(T)
    case error(String)
}

protocol IRequest {
    var urlRequest: URLRequest? {get}
}

protocol IParser {
    associatedtype Model
    func parse(data: Data) -> Model?
}

struct RequestConfig<Parser> where Parser: IParser {
    let request: IRequest
    let parser: Parser
}

protocol IRequestSender {
    func send <Parser> (config: RequestConfig<Parser>, complitionHandler: @escaping (Result<Parser.Model>) -> Void)
}

class CatItemParser: IParser {
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

class UIImageParser: IParser {
    typealias Model = UIImage
    func parse(data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}

class GetCatsRequest: IRequest {
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

class GetCatImage: IRequest {
    var urlRequest: URLRequest?
    init(byString url: String) {
        guard let url = URL(string: url) else {fatalError("URL hasn't been created")}
        self.urlRequest = URLRequest(url: url)
    }
}

class RequestSender: IRequestSender {
    let session = URLSession.shared
    func send<Parser>(config: RequestConfig<Parser>, complitionHandler: @escaping (Result<Parser.Model>) -> Void) where Parser : IParser {
        guard let urlRequest = config.request.urlRequest else {
            complitionHandler(Result.error("url string can't be parsed to URL"))
            return
        }
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                complitionHandler(Result.error(error.localizedDescription))
                return
            }
            guard
            let data = data,
                let parserModel: Parser.Model = config.parser.parse(data: data) else {
                    complitionHandler(Result.error("received data can't be parsed"))
                    return
            }
            complitionHandler(Result.success(parserModel))
        }
        task.resume()
    }
}

struct RequestFactory {
    static func getCats(limit: Int = 100) -> RequestConfig<CatItemParser> {
        return RequestConfig<CatItemParser>(request: GetCatsRequest(limit: limit), parser: CatItemParser())
    }
    static func getImage(byUrl url: String) -> RequestConfig<UIImageParser> {
        return RequestConfig<UIImageParser>(request: GetCatImage(byString: url), parser: UIImageParser())
    }
    
}
