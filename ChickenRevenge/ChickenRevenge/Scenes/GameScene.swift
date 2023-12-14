//
//  GameScene.swift
//  ChickenRevenge
//
//  Created by Luigi Penza on 11/12/23.
//

import SpriteKit
import GameplayKit
import GameController

struct CategoryBitMask {
    static let None: UInt32 = 0
    static let Enemy: UInt32 = 0b1
    static let Ally: UInt32 = 0b10
    static let Bullet: UInt32 = 0b100
    static let Wall: UInt32 = 0b1000
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var sceneManagerDelegate: SceneManagerDelegate?
    
    var gameScore = 0 {
        didSet{
            scoreLabel.text = "SCORE: \(gameScore)"
        }
    }
    
    var worldNode = SKNode()
    var scoreLabel: SKLabelNode!
    
    var chicken = Chicken()
    
    var controlling = false
    
    var bulletPositions: [CGPoint] = [CGPoint(x:-160, y:288),CGPoint(x:160, y:288),CGPoint(x:160, y:-288),CGPoint(x:-160, y:-288)]
    var nodePosition = CGPoint()
    var startTouch = CGPoint()
    
    let background = SKSpriteNode(imageNamed: "Background")
    
    var virtualController: GCVirtualController?
    var PlayerPosx: CGFloat = 0
    var PlayerPosy: CGFloat = 0
    
    // MARK: - TouchControl
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        controlling = true
        let touch = touches.first
        if let location = touch?.location(in: self){
            startTouch = location
            nodePosition = chicken.position
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if controlling {
            let touch = touches.first
            if let location = touch?.location(in: self){
                chicken.run(SKAction.move(to: CGPoint(x:  nodePosition.x + location.x - startTouch.x, y: nodePosition.y + location.y - startTouch.y), duration: 0.1))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        controlling = false
    }
    */
    // MARK: didBegin
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if chicken.damageable {
            if collision == CategoryBitMask.Bullet | CategoryBitMask.Ally {
                bulletHit()
            }
        }
        
    }
    
    // MARK: didMove
    override func didMove(to view: SKView) {
        // Constraints
        let xRange = SKRange(lowerLimit:-(self.frame.width/2 - 10), upperLimit:self.frame.width/2 - 10)
        let yRange = SKRange(lowerLimit:-(self.frame.height/2 - 10), upperLimit:self.frame.height/2 - 10)
        chicken.constraints = [SKConstraint.positionX(xRange, y: yRange)]
        
        // Physics
        self.scaleMode = .aspectFill
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CategoryBitMask.Wall
        self.physicsBody?.pinned = true
        self.physicsBody?.isDynamic = false
        self.physicsBody!.restitution = 0
        view.ignoresSiblingOrder = true
        // MARK: Testing
        view.showsPhysics = true
        view.showsFPS = true
        view.showsNodeCount = true
        addChild(worldNode)
        physicsWorld.contactDelegate = self
        
        // Set chicken
        chicken.position = CGPoint(x:0, y:-150)
        chicken.physicsBody?.affectedByGravity = false
        chicken.physicsBody?.isDynamic = false
        chicken.damageable = true
        chicken.setScale(0.5)
        chicken.zPosition = 1
        chicken.physicsBody = SKPhysicsBody(circleOfRadius: chicken.size.height/5)
        chicken.physicsBody?.categoryBitMask = CategoryBitMask.Ally
        chicken.physicsBody?.collisionBitMask = CategoryBitMask.Wall
        chicken.physicsBody?.contactTestBitMask = CategoryBitMask.Bullet | CategoryBitMask.Enemy | CategoryBitMask.Wall
        addChild(chicken)
        
        // Set score label
        scoreLabel = SKLabelNode(fontNamed: "SF Pro")
        scoreLabel.fontSize = 22.0
        scoreLabel.text = "SCORE  0"
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: 0, y: self.frame.height/2 - 70)
        scoreLabel.zPosition = 2
        worldNode.addChild(scoreLabel)
        
        // Set background
        background.size = self.frame.size
        background.position = CGPoint(x:0, y:0)
        background.zPosition = -3
        addChild(background)
        
        // Set controller
        connectVirtualController()
        
        // Set gameplay
        if !worldNode.isPaused {
            // Set infinite bullet spawn
            let wait = SKAction.wait(forDuration: 1.0)
            let spawnBulletAction = SKAction.run {
                self.spawnBullet()
            }
            
            let sequence = SKAction.sequence([wait, spawnBulletAction])
            let repeatForever = SKAction.repeatForever(sequence)
            
            self.run(repeatForever)
        }
    }
    
    //MARK: update
    override func update(_ currentTime: TimeInterval) {
        //TODO: Insert game score here
        gameScore += 1
        
        if let leftThumbstick = virtualController?.controller?.extendedGamepad?.leftThumbstick {
            PlayerPosx = CGFloat(leftThumbstick.xAxis.value)
            if PlayerPosx >= 0.5 {
                chicken.position.x += 5
            }
            if PlayerPosx <= -0.5 {
                chicken.position.x -= 5
            }
            
            PlayerPosy = CGFloat(leftThumbstick.yAxis.value)
            if PlayerPosy >= 0.5 {
                chicken.position.y += 5
            }
            if PlayerPosy <= -0.5 {
                chicken.position.y -= 5
            }
        } else {
            print("wtf")
        }
    }
    
    func spawnBullet() {
        let bullet = SKSpriteNode(imageNamed: "polletto")
        bullet.zPosition = 1
        bullet.setScale(1.0)
        bullet.position = bulletPositions.randomElement()!
        
        //TODO: this shit
        let action = SKAction.move(to: chicken.position, duration: TimeInterval(Float.random(in: 0.5...1.0)))
        let actionHard = SKAction.move(to: chicken.position, duration: TimeInterval(Float.random(in: 0.2...5)))
        let actionHardest = SKAction.move(to: chicken.position, duration: TimeInterval(Float.random(in: 0.1...0.2)))
        let actionDone = SKAction.sequence([(SKAction.removeFromParent())])
        
        if gameScore < 1_000 {
            bullet.run(SKAction.sequence([action, actionDone]))
        } else if 1_000 <= gameScore && gameScore <= 5_000 {
            bullet.run(SKAction.sequence([actionHard, actionDone]))
        } else {
            bullet.run(SKAction.sequence([actionHardest, actionDone]))
        }
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.height/7)
        bullet.physicsBody?.categoryBitMask = CategoryBitMask.Bullet
        bullet.physicsBody!.collisionBitMask = CategoryBitMask.None
        bullet.physicsBody?.contactTestBitMask = CategoryBitMask.Ally
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.isDynamic = false
        worldNode.addChild(bullet)
    }
    
    func connectVirtualController() {
        let controllerConfic = GCVirtualController.Configuration()
        controllerConfic.elements = [GCInputLeftThumbstick]
        let controller = GCVirtualController(configuration: controllerConfic)
        controller.connect()
        
        virtualController = controller
    }
    
    func bulletHit() {
        print("you got hit!")
        
        // Changing status and invulnerability frame
        chicken.status += 1
        chicken.damageable = false
        let chickenAlpha = SKAction.fadeAlpha(to: 0.5, duration: 0.5)
        let wait = SKAction.wait(forDuration: 0.2)
        let chickenAlpha2 = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        chicken.run(SKAction.sequence([chickenAlpha, wait, chickenAlpha2, wait, SKAction.run{self.chicken.damageable = true}]))
        
        let generator: UIImpactFeedbackGenerator
        if chicken.status == 1 {
            // SKTAudio.sharedInstance().playSoundEffect("Hit1.mp3")
            generator = UIImpactFeedbackGenerator(style: .light)
        }
        else if chicken.status == 2 {
            // SKTAudio.sharedInstance().playSoundEffect("Hit2.mp3")
            generator = UIImpactFeedbackGenerator(style: .medium)
        }
        else { // if chicken.status == 3
            // SKTAudio.sharedInstance().playSoundEffect("Hit3.mp3")
            generator = UIImpactFeedbackGenerator(style: .heavy)
            gameOver()
        }
        
        generator.impactOccurred()
    }
    
    func gameOver(){
        SKTAudio.sharedInstance().backgroundMusicPlayer?.stop()
        worldNode.isPaused = true
        controlling = false
        userScore = gameScore
        let gameScene = GameOver(fileNamed: "GameOver")
        gameScene?.sceneManagerDelegate = self.sceneManagerDelegate
        print("moving to gameover")
        self.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.5))
    }
}
