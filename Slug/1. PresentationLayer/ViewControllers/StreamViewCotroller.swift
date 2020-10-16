//
//  StreamViewContrller.swift
//  Slug
//
//  Created by Denis Garifyanov on 15.10.2020.
//  Copyright © 2020 Denis Garifyanov. All rights reserved.
//

import Foundation

import CameraKit_iOS


class StreamViewCotroller: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let session = CKFPhotoSession()
        
        let previewView = CKFPreviewView(frame: view.bounds)
        previewView.session = session
        
        view.addSubview(previewView)
        
    }
}
