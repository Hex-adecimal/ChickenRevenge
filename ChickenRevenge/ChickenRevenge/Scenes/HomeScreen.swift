//
//  HomeScreen.swift
//  ChickenRevenge
//
//  Created by Luigi Penza on 11/12/23.
//

import SpriteKit
import GameKit

class HomeScreen: SKScene {
    var sceneManagerDelegate: SceneManagerDelegate?
    
    override func didMove(to view: SKView) {
        SKTAudio.sharedInstance().backgroundMusicPlayer?.prepareToPlay()
        SKTAudio.sharedInstance().playBackgroundMusic("Home.mp3")
        
        self.view?.showsPhysics = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        touchedButton(touchLocation: touchLocation)
        
        func touchedButton(touchLocation: CGPoint) {
            let nodeAtPoint = atPoint(touchLocation)
            if let touchedNode = nodeAtPoint as? SKSpriteNode {
                SKTAudio.sharedInstance().backgroundMusicPlayer?.stop()
                if touchedNode.name?.starts(with: "Background") == true {
                    let gameScene = GameScene(fileNamed: "GameScene")
                    gameScene?.sceneManagerDelegate = self.sceneManagerDelegate
                    print("moving to gameplay")
                    self.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.4))
                }
            }
        }
    }
}
