//
//  TutorialScreen.swift
//  ChickenRevenge
//
//  Created by Luigi Penza on 11/12/23.
//

import SpriteKit
import GameKit

class TutorialScreen: SKScene {
    var sceneManagerDelegate: SceneManagerDelegate?
    var tutorialView = SKSpriteNode(imageNamed: "TutorialScreen")
    
    override func didMove(to view: SKView) {
        self.view?.showsPhysics = false
        addChild(tutorialView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = HomeScreen(fileNamed: "HomeScreen")
        gameScene?.sceneManagerDelegate = self.sceneManagerDelegate
        print("moving to home")
        self.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.4))
    }
}
