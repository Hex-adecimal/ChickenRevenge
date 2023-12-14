//
//  GameViewController.swift
//  ChickenRevenge
//
//  Created by Luigi Penza on 11/12/23.
//

import UIKit
import SpriteKit

protocol SceneManagerDelegate {
    func presentHomeScreen()
    func presentGameScene()
    func presentGameOver()
}

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        presentHomeScreen()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//MARK: - Scene Delegate
extension GameViewController: SceneManagerDelegate {
    func present(scene: SKScene){
        if let view = self.view as! SKView? {
            if let gestureRecognizers = view.gestureRecognizers {
                for recognizer in gestureRecognizers {
                    view.removeGestureRecognizer(recognizer)
                }
            }
            view.presentScene(scene)
            scene.scaleMode = .aspectFill
            scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
            
            view.ignoresSiblingOrder = true
            view.showsPhysics = false
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    func presentHomeScreen(){
        print("Presenting homescreen")
        let homeScreen = HomeScreen(fileNamed: "HomeScreen")
        homeScreen?.sceneManagerDelegate = self
        self.present(scene: homeScreen!)
    }
    
    func presentGameScene(){
        print("Presenting gamescene")
        let gameScene = GameScene(fileNamed: "GameScene")
        gameScene?.sceneManagerDelegate = self
        self.present(scene: gameScene!)
    }
    
    func presentGameOver(){
        print("Presenting gameover")
        let gameOver = GameOver(fileNamed: "GameOver")
        gameOver?.sceneManagerDelegate = self
        self.present(scene: gameOver!)
    }
}
