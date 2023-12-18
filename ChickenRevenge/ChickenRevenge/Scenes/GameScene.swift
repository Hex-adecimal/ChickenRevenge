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
    
    var gameScoreInRow = 0
    var gameScore = 0 {
        didSet{
            scoreLabel.text = "SCORE: \(gameScore)"
        }
    }
    
    var worldNode = SKNode()
    var scoreLabel: SKLabelNode!
    let healthBar = SKSpriteNode(imageNamed: "ThreeEggs")
    
    var chicken = Chicken()
    
    var chefExists = false
    
    // Positions are for the 890-390 screen of the iphone 14, and are each corner and each midpoint
    var bulletPositions: [CGPoint] = [CGPoint(x: 0, y: 195), CGPoint(x: 422, y: 195), CGPoint(x: 422, y: 0), CGPoint(x: 422, y: -195), CGPoint(x: 0, y: -195), CGPoint(x: -422, y: -195), CGPoint(x: -422, y: 0)]
    
    let background = SKSpriteNode(imageNamed: "Background")
    
    var virtualController: GCVirtualController?
    var PlayerPosx: CGFloat = 0
    var PlayerPosy: CGFloat = 0
    
    // MARK: didBegin
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if chicken.damageable {
            if collision == CategoryBitMask.Bullet | CategoryBitMask.Ally {
                gotHit()
            }
            
            if collision == CategoryBitMask.Enemy | CategoryBitMask.Ally {
                gotHit()
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
        view.showsPhysics = false
        view.showsFPS = false
        view.showsNodeCount = false
        addChild(worldNode)
        physicsWorld.contactDelegate = self
        
        // Set chicken
        chicken.position = CGPoint(x:0, y:0)
        chicken.physicsBody?.affectedByGravity = false
        chicken.physicsBody?.isDynamic = false
        chicken.damageable = true
        chicken.setScale(0.35)
        chicken.zPosition = 1
        chicken.physicsBody = SKPhysicsBody(circleOfRadius: chicken.size.height/4)
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
        scoreLabel.position = CGPoint(x: self.size.width/2 - 100, y: -self.size.height/4)
        scoreLabel.zPosition = 2
        worldNode.addChild(scoreLabel)
        
        // Set health bar
        healthBar.position = CGPoint(x: self.size.width/2 - 100, y: -self.size.height/3)
        healthBar.zPosition = 2
        worldNode.addChild(healthBar)
        
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
        // Set gamescore
        if !chefExists {
            gameScore += 1
            gameScoreInRow += 1
        }
        if chefExists {
            gameScore += 5
            gameScoreInRow += 5
        }
        if gameScoreInRow == 1000 {
            gainHealth()
        }
        
        // Set chef spawn
        if gameScore % 10_000 >= 100 && !chefExists{
            spawnChef()
        }
        
        // Set music
        if gameScore % 10_000 == 1 {
            SKTAudio.sharedInstance().backgroundMusicPlayer?.stop()
            SKTAudio.sharedInstance().playBackgroundMusic("Background1.mp3")
        }
        if gameScore % 10_000 == 1_000 {
            SKTAudio.sharedInstance().backgroundMusicPlayer?.stop()
            SKTAudio.sharedInstance().playBackgroundMusic("Background2.mp3")
        }
        if gameScore % 10_000 == 5_000{
            SKTAudio.sharedInstance().backgroundMusicPlayer?.stop()
            SKTAudio.sharedInstance().playBackgroundMusic("Background3.mp3")
        }
        
        // Reading input
        if let leftThumbstick = virtualController?.controller?.extendedGamepad?.leftThumbstick {
            PlayerPosx = CGFloat(leftThumbstick.xAxis.value)
            if PlayerPosx >= 0.1 {
                chicken.position.x += 5
            }
            if PlayerPosx <= -0.1 {
                chicken.position.x -= 5
            }
            
            PlayerPosy = CGFloat(leftThumbstick.yAxis.value)
            if PlayerPosy >= 0.1 {
                chicken.position.y += 5
            }
            if PlayerPosy <= -0.1 {
                chicken.position.y -= 5
            }
        }
    }
    
    func spawnChef() {
        // Set the spawn of the chef
        let perchiazzi = Perchiazzi()
        perchiazzi.xScale = 1.1
        perchiazzi.yScale = 0.6

        chefExists = true
        
        perchiazzi.zPosition = 2
        perchiazzi.position = CGPoint(x: 0, y: 120)
        
        let actionToLeft = SKAction.move(to: CGPoint(x: -445, y: 120), duration: 5.0)
        let actionToRight = SKAction.move(to: CGPoint(x: 445, y: 120), duration: 5.0)
        perchiazzi.run(SKAction.repeatForever(SKAction.sequence([actionToLeft, actionToRight])))
        
        // Set physics
        perchiazzi.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 256, height: 256), center: CGPoint(x: perchiazzi.position.x, y: perchiazzi.position.y - 50))
        perchiazzi.physicsBody?.categoryBitMask = CategoryBitMask.Enemy
        perchiazzi.physicsBody!.collisionBitMask = CategoryBitMask.None
        perchiazzi.physicsBody?.contactTestBitMask = CategoryBitMask.Enemy
        perchiazzi.physicsBody?.affectedByGravity = false
        perchiazzi.physicsBody?.isDynamic = false
        
        worldNode.addChild(perchiazzi)
    }
    
    func spawnBullet() {
        let bullet = SKSpriteNode(imageNamed: "polletto")
        bullet.zPosition = 1
        bullet.setScale(1.0)
        bullet.position = bulletPositions.randomElement()!
        
        let vector = CGVector(dx: chicken.position.x - bullet.position.x, dy: chicken.position.y - bullet.position.y)
        
        let random = Float.random(in: 0.5...1.0)
        let randomHard = Float.random(in: 0.2...5)
        let randomHardest = Float.random(in: 0.1...0.2)
        
        //TODO: this shit
        let action = SKAction.move(to: chicken.position, duration: TimeInterval(random))
        let actionHard = SKAction.move(to: chicken.position, duration: TimeInterval(randomHard))
        let actionHardest = SKAction.move(to: chicken.position, duration: TimeInterval(randomHardest))
        let continueAction = SKAction.move(by: vector, duration: TimeInterval(random))
        let continueActionHard = SKAction.move(by: vector, duration: TimeInterval(randomHard))
        let continueActionHardest = SKAction.move(by: vector, duration: TimeInterval(randomHardest))
        let actionDone = SKAction.sequence([(SKAction.removeFromParent())])
        
        if gameScore % 10_000 < 1_000 {
            bullet.run(SKAction.sequence([action, continueAction, actionDone]))
        }
        
        if 1_000 <= gameScore % 10_000 && gameScore % 10_000 <= 5_000 {
            bullet.run(SKAction.sequence([actionHard, continueActionHard, actionDone]))
        } 
        
        if 5_000 < gameScore % 10_000 {
            bullet.run(SKAction.sequence([actionHardest, continueActionHardest, actionDone]))
        }
        
        // Set physics
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
    
    func gotHit() {
        print("you got hit!")
        
        // Changing status and invulnerability frame
        chicken.status += 1
        chicken.damageable = false
        let chickenAlpha = SKAction.fadeAlpha(to: 0.5, duration: 0.5)
        let wait = SKAction.wait(forDuration: 0.2)
        let chickenAlpha2 = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        chicken.run(SKAction.sequence([chickenAlpha, wait, chickenAlpha2, wait, SKAction.run{self.chicken.damageable = true}]))
        
        gameScore -= 100
        gameScoreInRow = 0
        
        let generator: UIImpactFeedbackGenerator
        if chicken.status == 1 {
            // SKTAudio.sharedInstance().playSoundEffect("Hit1.mp3")
            healthBar.texture = SKTexture(imageNamed: "TwoEggs")
            generator = UIImpactFeedbackGenerator(style: .light)
        }
        else if chicken.status == 2 {
            // SKTAudio.sharedInstance().playSoundEffect("Hit2.mp3")
            healthBar.texture = SKTexture(imageNamed: "OneEgg")
            generator = UIImpactFeedbackGenerator(style: .medium)
        }
        else { // if chicken.status == 3
            // SKTAudio.sharedInstance().playSoundEffect("Hit3.mp3")
            healthBar.texture = SKTexture(imageNamed: "NoEggs")
            generator = UIImpactFeedbackGenerator(style: .heavy)
            gameOver()
        }
        
        generator.impactOccurred()
    }
    
    func gainHealth() {
        if chicken.status > 0 {
            print("you got hp!")
            
            chicken.status -= 1
            
            gameScore += 100
            gameScoreInRow = 0
            
            if chicken.status == 0 {
                // SKTAudio.sharedInstance().playSoundEffect("Hit1.mp3")
                healthBar.texture = SKTexture(imageNamed: "ThreeEggs")
            }
            else if chicken.status == 1 {
                // SKTAudio.sharedInstance().playSoundEffect("Hit2.mp3")
                healthBar.texture = SKTexture(imageNamed: "TwoEggs")
            }
        }
    }
    
    func gameOver(){
        virtualController?.disconnect()
        SKTAudio.sharedInstance().backgroundMusicPlayer?.stop()
        worldNode.isPaused = true
        userScore = gameScore
        let gameScene = GameOver(fileNamed: "GameOver")
        gameScene?.sceneManagerDelegate = self.sceneManagerDelegate
        print("moving to gameover")
        self.view?.presentScene(gameScene!, transition: SKTransition.fade(withDuration: 0.5))
    }
}
