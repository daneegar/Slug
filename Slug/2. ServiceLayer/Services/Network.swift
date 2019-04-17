//
//  CatApi.swift
//  Slug
//
//  Created by Denis Garifyanov on 16/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit.UIImage

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

}




