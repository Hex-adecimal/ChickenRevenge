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
        score.fontColor = .systemOrange
        score.text = "FINAL SCORE: \(userScore)"
        score.fontSize = 22.0
        score.position = CGPoint(x: 0, y: self.frame.height/5 - 80)
        addChild(score)
    
        // Set highscore
        highScore.zPosition = 3
        highScore.horizontalAlignmentMode = .center
        highScore.fontColor = .systemOrange
        highScore.text = "HIGH SCORE: \(UserDefaults.standard.integer(forKey: "scoreKey"))"
        highScore.fontSize = 22.0
        highScore.position = CGPoint(x: 0, y: self.frame.height/5 - 110)
        addChild(highScore)
        
        if let gameo = self.childNode(withName: "RetryButton") as? SKSpriteNode {
            retryButton = gameo
        }
        if let gameo = self.childNode(withName: "MainMenuButton") as? SKSpriteNode {
            mainMenuButton = gameo
        }
        self.view?.showsPhysics = false
    }
}
