//
//  PresentationAssembly.swift
//  Slug
//
//  Created by Denis Garifyanov on 04/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit

enum ViewsToPresent {
    case MainProfileView
    case ConversationView
    case InitView
}

protocol IPresentationAssembly: class {
    func initSession()
    func present(conversation conv: Conversation)
    func presentProfileMainViewContoller()
    func presentCollectionViewOfPhotos(sender view: UIViewController, delegate: TakeImageDelegate)
    func presentView(ofPhoto photo: UIImage, sender: UINavigationController?, delegate: TakeImageDelegate)
}

class PresentationAssembly: IPresentationAssembly {
    
    private lazy var storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    private var curentWindow: UIWindow!
    private let serviceAssembly: IServicesAssembly
    private var rootPresenter: PresenterForConversationList?
    private var rootNavigationViewController: UINavigationController?
    
    init(serviceAssembly: IServicesAssembly) {
        self.serviceAssembly = serviceAssembly
    }
    
    func presentProfileMainViewContoller() {
        guard let nvc = self.storyboard.instantiateViewController(withIdentifier: "mainUserProfile") as? UINavigationController
            else {fatalError()}
        guard let vcWhatWillPresent = self.rootNavigationViewController?.children.last else {fatalError()}
        vcWhatWillPresent.present(nvc, animated: true, completion: nil)
        DispatchQueue.main.async {
            guard let mainViewContoller = nvc.children.first as? MainUserProfileView else {fatalError()}
            let _ = ProfileViewPresenter(viewController: mainViewContoller, presentationAssembly: self)
        }
    }
    
    func present(conversation conv: Conversation) {
        guard let vc = self.storyboard.instantiateViewController(withIdentifier: "conversationViewController") as? ConversationViewControllerProtocol
            else {fatalError()}
        self.rootNavigationViewController?.pushViewController(vc, animated: true)
        DispatchQueue.main.async {
            let _ = ConversationPresenter(forViewController: vc, withConversation: conv)
        }
    }
    
    func presentCollectionViewOfPhotos(sender view: UIViewController, delegate: TakeImageDelegate) {
        guard let nvc = self.storyboard.instantiateViewController(withIdentifier: "imagesNavigationController") as? UINavigationController
            else {fatalError()}
        view.present(nvc, animated: true, completion: nil)
        guard let vc = nvc.children.first as? PicturesViewControllerProtocol
            else {fatalError("There is no child or view controoler doesn't conform ConversationListViewControllerProtocol")}
        DispatchQueue.main.async {
            let _ = PicturesViewPresenter(forViewController: vc,
                                          presentationAssembly: self,
                                          catsService: self.serviceAssembly.catService,
                                          imageService: self.serviceAssembly.imageService,
                                          delegate: delegate)
        }
    }
    
    func presentView(ofPhoto photo: UIImage, sender: UINavigationController?, delegate: TakeImageDelegate) {
        guard let vc = self.storyboard.instantiateViewController(withIdentifier: "photoViewController") as? PictureViewController
            else {fatalError()}
        vc.image = photo
        vc.delegate = delegate
        if let nvc = sender {
            nvc.pushViewController(vc, animated: true)
        } else {
            let nvc = UINavigationController()
            nvc.pushViewController(vc, animated: false)
        }
    }
    
    func initSession() {
        if let app = UIApplication.shared.delegate as? AppDelegate{
            let nvc = self.storyboard.instantiateViewController(withIdentifier: "rootNavigationController") as? UINavigationController
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = nvc
            window.makeKeyAndVisible()
            app.window = window
            guard let vc = nvc?.children.first as? ConversationListViewControllerProtocol
                else {fatalError("There is no child or view controoler doesn't conform ConversationListViewControllerProtocol")}
            DispatchQueue.main.async {
                self.rootPresenter = ConversationListPresenter(forViewController: vc, presentationAssembly: self)
            }
            self.rootNavigationViewController = nvc
        }
    }
}
