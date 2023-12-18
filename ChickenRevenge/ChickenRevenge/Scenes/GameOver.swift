//
//  GameOver.swift
//  ChickenRevenge
//
//  Created by Luigi Penza on 11/12/23.
//

import SpriteKit
import GameKit

class GameOver: SKScene {
    var sceneManagerDelegate: SceneManagerDelegate?
    var retryButton = SKSpriteNode()
    var mainMenuButton = SKSpriteNode()
    var score = SKLabelNode(fontNamed: "SF Pro")
    var highScore = SKLabelNode(fontNamed: "SF Pro")
    
    override func didMove(to view: SKView) {
        // Update the score
        if userScore > UserDefaults.standard.integer(forKey: "scoreKey") {
            UserDefaults.standard.set(userScore, forKey: "scoreKey")
            GKLeaderboard.submitScore(userScore, context: 0, player: GKLocalPlayer.local, leaderboardIDs: ["69420"]) { error in }
        }
        
        // Set score 
        score.zPosition = 3
        score.horizontalAlignmentMode = .center
        score.fontColor = .gray
        score.text = "\(userScore)"
        score.fontSize = 22.0
        score.position = CGPoint(x: -40, y: self.frame.height/5 - 140)
        addChild(score)
    
        // Set highscore
        highScore.zPosition = 3
        highScore.horizontalAlignmentMode = .center
        highScore.fontColor = .gray
        highScore.text = "\(UserDefaults.standard.integer(forKey: "scoreKey"))"
        highScore.fontSize = 22.0
        highScore.position = CGPoint(x: 40, y: self.frame.height/5 - 140)
        addChild(highScore)
        
        if let gameo = self.childNode(withName: "RetryButton") as? SKSpriteNode {
            retryButton = gameo
        }
        if let gameo = self.childNode(withName: "MainMenuButton") as? SKSpriteNode {
            mainMenuButton = gameo
        }
        self.view?.showsPhysics = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        touchedButton(touchLocation: touchLocation)
        
        func touchedButton(touchLocation: CGPoint) {
            let nodeAtPoint = atPoint(touchLocation)
            if let touchedNode = nodeAtPoint as? SKSpriteNode {
                if touchedNode.name?.starts(with: "RetryButton") == true {
                    let gameScene = GameScene(fileNamed: "GameScene")
                    gameScene?.sceneManagerDelegate = self.sceneManagerDelegate
                    print("moving to gameplay")
                    self.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0))
                }
                if touchedNode.name?.starts(with: "MainMenuButton") == true {
                    let gameScene = HomeScreen(fileNamed: "HomeScreen")
                    gameScene?.sceneManagerDelegate = self.sceneManagerDelegate
                    self.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0))
                }
            }
        }
    }
}
