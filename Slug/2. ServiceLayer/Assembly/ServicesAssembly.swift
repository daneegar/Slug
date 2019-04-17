//
//  Assembly.swift
//  Slug
//
//  Created by Denis Garifyanov on 04/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit.UIImage


protocol IServicesAssembly {
    var catService: ICatService {get}
    var imageService: IimageService {get}
}

class ServicesAssembly: IServicesAssembly {
    var catService: ICatService
    let coreAssembly: ICoreAssembly
    var imageService: IimageService
    
    init (coreAssembly: ICoreAssembly) {
        self.coreAssembly = coreAssembly
        self.catService = CatsService()
        self.imageService = ImageService()
    }
}
