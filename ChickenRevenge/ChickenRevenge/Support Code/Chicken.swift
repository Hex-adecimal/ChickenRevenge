//
//  Chicken.swift
//  ChickenRevenge
//
//  Created by Luigi Penza on 11/12/23.
//

import SpriteKit

class Chicken: SKSpriteNode, GameSprite {
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Chicken")
    var initialSize: CGSize = CGSize(width: 256, height: 256)
    var idleAnimation = SKAction()
    
    var damageable = true
    var status = 0
    
    func createAnimation(){
        var idleFrames: [SKTexture] = []
        for i in 1...8 {
            idleFrames.append(textureAtlas.textureNamed("Chicken\(i)"))
        }
        let idleAction = SKAction.animate(with: idleFrames, timePerFrame: 0.15)
        idleAnimation = SKAction.repeatForever(idleAction)
    }
    
    init() {
        super.init(texture: nil, color: .clear, size: initialSize)
        createAnimation()
        self.run(idleAnimation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
