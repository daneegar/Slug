//
//  PictureViewController.swift
//  Slug
//
//  Created by Denis Garifyanov on 16/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    
    var delegate: TakeImageDelegate?
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    @IBAction func buttonPressed(_ sender: Any) {
        guard let image = self.image else {fatalError()}
        self.delegate?.pickTaken(image: image)
        if let nvc = self.navigationController {
            nvc.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.image
        self.configButton()
    }
    func configButton() {
        self.saveButton.backgroundColor = .white
        self.saveButton.layer.borderColor = UIColor(named: "black")?.cgColor
        self.saveButton.layer.borderWidth = 1
        self.saveButton.layer.cornerRadius = 10
    }

}
