//
//  User.swift
//  Slug
//
//  Created by Denis Garifyanov on 05/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation

extension User {
    func generateId () {
        self.id = UUID.init()
    }
}
