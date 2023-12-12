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
        
        self.view?.showsPhysics = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        touchedButton(touchLocation: touchLocation)
        
        func touchedButton(touchLocation: CGPoint) {
            let nodeAtPoint = atPoint(touchLocation)
            if let touchedNode = nodeAtPoint as? SKSpriteNode {
                if touchedNode.name?.starts(with: "TutorialButton") == true {
                    let gameScene = TutorialScreen(fileNamed: "TutorialScreen")
                    gameScene?.sceneManagerDelegate = self.sceneManagerDelegate
                    print("moving to tutorial")
                    self.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.4))
                } else if touchedNode.name?.starts(with: "ScoreboardButton") == true {
                    let viewController = GKGameCenterViewController(leaderboardID: "69420", playerScope: .global, timeScope: .allTime)
                    viewController.gameCenterDelegate = sceneManagerDelegate as? GKGameCenterControllerDelegate
                    if let controller = sceneManagerDelegate as? GameViewController {
                        controller.present(viewController, animated: true, completion: nil)
                    }
                } else {
                    let gameScene = GameScene(fileNamed: "GameScene")
                    gameScene?.sceneManagerDelegate = self.sceneManagerDelegate
                    print("moving to gameplay")
                    self.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.4))
                }
            }
        }
    }
}
