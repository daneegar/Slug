//
//  Assembly.swift
//  Slug
//
//  Created by Denis Garifyanov on 04/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation


protocol IServicesAssembly {

}

class ServicesAssembly: IServicesAssembly {
    let coreAssembly: ICoreAssembly
    init (coreAssembly: ICoreAssembly) {
        self.coreAssembly = coreAssembly
    }
}
