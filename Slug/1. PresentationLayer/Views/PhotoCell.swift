//
//  PhotoCell.swift
//  Slug
//
//  Created by Denis Garifyanov on 16/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photo: UIImageView!
    var image: UIImage?
    
    override func prepareForReuse() {
        DispatchQueue.main.async {
            self.displayPhoto(.none)
        }
    }
    
    func updateAppearanceFor(_ photo: UIImage?, animated: Bool = true) {
        DispatchQueue.main.async {
            if animated {
                UIView.animate(withDuration: 0.5) {
                    self.displayPhoto(photo)
                }
            } else {
                self.displayPhoto(photo)
            }
        }
    }
    
    private func displayPhoto(_ image: UIImage?) {
        self.image = image
        if let image = image {
            photo.image = image
            photo.alpha = 1.0
            loadingIndicator?.alpha = 0
            loadingIndicator?.stopAnimating()
            backgroundColor = #colorLiteral(red: 0.9338415265, green: 0.9338632822, blue: 0.9338515401, alpha: 1)
            layer.cornerRadius = 10
        } else {
            photo.alpha = 0
            loadingIndicator?.alpha = 1
            loadingIndicator?.startAnimating()
            backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            layer.cornerRadius = 10
        }
    }
}
