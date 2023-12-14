//
//  Chicken.swift
//  ChickenRevenge
//
//  Created by Luigi Penza on 11/12/23.
//

import SpriteKit

class Chicken: SKSpriteNode, GameSprite {
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "chickenghost")
    var initialSize: CGSize = CGSize (width: 256, height: 256)
    var damageable = true
    var idleAnimation = SKAction()
    
    func createAnimation(){
        let idleFrames: [SKTexture] = [textureAtlas.textureNamed("chickenghost1"), textureAtlas.textureNamed("chickenghost2"), textureAtlas.textureNamed("chickenghost3"), textureAtlas.textureNamed("chickenghost4"), textureAtlas.textureNamed("chickenghost5"), textureAtlas.textureNamed("chickenghost6"), textureAtlas.textureNamed("chickenghost7"),
            textureAtlas.textureNamed("chickenghost8")]
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

//kfennddkjnkkn  
