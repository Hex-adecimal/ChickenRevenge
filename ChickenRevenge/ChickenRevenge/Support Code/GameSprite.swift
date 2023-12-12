//
//  GameSprite.swift
//  ChickenRevenge
//
//  Created by Luigi Penza on 11/12/23.
//

import SpriteKit

protocol GameSprite {
    var textureAtlas: SKTextureAtlas {get set}
    var initialSize: CGSize {get set}
}
