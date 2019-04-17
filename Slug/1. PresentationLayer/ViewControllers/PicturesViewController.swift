//
//  PicturesViewController.swift
//  Slug
//
//  Created by Denis Garifyanov on 16/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import UIKit

protocol PicturesViewControllerProtocol: UIViewController {
    var collectionView: UICollectionView! {get}
    var presenter: PresenterForPicturesViewController? {get set}
}

class PicturesViewController: UIViewController, PicturesViewControllerProtocol {
    @IBOutlet weak var collectionView: UICollectionView!
    var presenter: PresenterForPicturesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
    }
    
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.presenter?.cancelButtonPressed()
    }
}




