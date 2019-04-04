//
//  PresentationAssembly.swift
//  Slug
//
//  Created by Denis Garifyanov on 04/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit

protocol IPresentationAssembly {
    /// Создает экран с приложениями
    func demoViewCotnroller() -> UIViewController
    
    /// Создает экран где бегают пингвинчики
    func pinguinViewController() -> UIViewController
}

class PresentationAssembly: IPresentationAssembly {
    
    func pinguinViewController() -> UIViewController {
        return UIViewController()
    }
    
    
    private let serviceAssembly: IServicesAssembly
    
    init(serviceAssembly: IServicesAssembly) {
        self.serviceAssembly = serviceAssembly
    }
    
    // MARK: - DemoViewController
    
    func demoViewCotnroller() -> UIViewController {
        return UIViewController()
    }
    
    private func demoModel(){

    }
    
    // MARK: - PinguinViewController
    
    func pinguinViewController(){

    }
    
    // MARK: - AnotherViewController
    //.....
}
