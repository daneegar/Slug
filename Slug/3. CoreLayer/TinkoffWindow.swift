//
//  TinkoffWindowStyle.swift
//  Slug
//
//  Created by Denis Garifyanov on 22/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import UIKit

protocol IWindowWithTouchTrace {
    var trasingIsEnable: Bool {get}
    func setTrasingEnable()
    func setTrasingDisable()
}

class WindowWithTouchTrace: UIWindow, IWindowWithTouchTrace {
    private var tinkoffLogoGenetor: ICellEmitterGenerator!
    var trasingIsEnable = true
    init(frame: CGRect, withCellEmitterGenetor cellEmitterGenerator: ICellEmitterGenerator?) {
        super.init(frame: frame)
        if let cem = cellEmitterGenerator {
            self.tinkoffLogoGenetor = cem
        }
        self.tinkoffLogoGenetor = CellEmitterGeneratorInPoint(layer: self.layer, pngNamed: "logo")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        guard self.trasingIsEnable else {return}
        event.allTouches?.forEach {
            switch $0.phase {
            case .began: touchBegan($0)
            case .moved, .stationary: touchMoved($0)
            case .cancelled, .ended: touchEnded($0)
            default: return
            }
        }
        
    }
    func setTrasingEnable() {
        self.trasingIsEnable = true
    }
    
    func setTrasingDisable() {
        self.trasingIsEnable = false
    }
    
    private func touchBegan(_ touch: UITouch) {
        self.tinkoffLogoGenetor.showLogos(atPlace: touch.location(in: self))
    }
    
    private func touchMoved(_ touch: UITouch) {
        self.tinkoffLogoGenetor.showLogos(atPlace: touch.location(in: self))
    }
    
    private func touchEnded(_ touch: UITouch) {
        self.tinkoffLogoGenetor.stopShow()
    }
    
    private func removeAllTouchViews() {
        self.tinkoffLogoGenetor.stopShow()
    }
}

protocol ICellEmitterGenerator {
    func showLogos(atPlace cgPoint: CGPoint)
    func stopShow()
}

class CellEmitterGeneratorInPoint: ICellEmitterGenerator{
    
    
    private var subEmitterLayer: CAEmitterLayer!
    private let emitterCell = CAEmitterCell()
    private let layer: CALayer
    let image: CGImage
    
    init?(layer: CALayer, pngNamed: String){
        guard let image = UIImage(named: pngNamed) else {
            print("image didn't found can't be get")
            return nil
        }
        guard let cgImage = image.cgImage else {
            print("cgImage can't be get")
            return nil
        }
        self.image = cgImage
        self.layer = layer
        setupEmitterCell()
    }
    
    func showLogos(atPlace cgPoint: CGPoint) {
        if self.subEmitterLayer == nil {
            self.subEmitterLayer = CAEmitterLayer()
            self.subEmitterLayer.emitterSize = layer.bounds.size
            self.subEmitterLayer.emitterShape = CAEmitterLayerEmitterShape.point
            self.subEmitterLayer.emitterCells = [emitterCell]
            self.layer.addSublayer(self.subEmitterLayer)
        }
        self.subEmitterLayer.emitterPosition = cgPoint
    }
    
    func stopShow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard let layer = self.subEmitterLayer else {return}
            layer.removeFromSuperlayer()
            self.subEmitterLayer = nil
        }
    }
    
    private func setupEmitterCell() {
        emitterCell.contents = self.image
        emitterCell.lifetime = 1.0
        emitterCell.birthRate = 5
        emitterCell.blueRange = 0.15
        emitterCell.velocity = 10
        emitterCell.velocityRange = 20
        emitterCell.scale = 0.07
        emitterCell.scaleRange = 0.02
        emitterCell.emissionRange = CGFloat.pi / 2
        emitterCell.emissionLongitude = CGFloat.pi
        emitterCell.yAcceleration = CGFloat.random(in: -100...100)
        emitterCell.alphaSpeed = -0.05
    }
}
