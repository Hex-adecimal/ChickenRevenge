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
let randomNumber = arc4random_uniform(2)

class GameScene: SKScene, SKPhysicsContactDelegate {
    var sceneManagerDelegate: SceneManagerDelegate?

    var gameScore = 0 {
        didSet{
            scoreLabel.text = "SCORE: \(gameScore)"
        }
    }
    var worldNode = SKNode()
    //var chicken = Chicken()
    let chicken = SKSpriteNode(imageNamed: "chickenghost1")
    
    var virtualController: GCVirtualController?
    var PlayerPosx : CGFloat = 0
    var scoreLabel: SKLabelNode!
    var controlling = false
    var nodePosition = CGPoint()
    var startTouch = CGPoint()
    let background = SKSpriteNode(imageNamed: "Background")
        
    //MARK: - TouchControl
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
    
    //MARK: didBegin
    
    //MARK: didMove
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
        //chicken.damageable = true // also here
        chicken.setScale(0.5) // here
        chicken.zPosition = 1
        chicken.physicsBody = SKPhysicsBody(circleOfRadius: chicken.size.height/5)
        chicken.physicsBody?.categoryBitMask = CategoryBitMask.Ally
        chicken.physicsBody?.collisionBitMask = CategoryBitMask.Wall
        chicken.physicsBody?.contactTestBitMask = CategoryBitMask.Bullet | CategoryBitMask.Enemy | CategoryBitMask.Wall
        print (chicken.position)
        addChild(chicken)
        
        connectVirtuellController()

        
        // Set score label
        scoreLabel = SKLabelNode(fontNamed: "SF Pro")
        scoreLabel.fontSize = 22.0
        scoreLabel.text = "SCORE  0"
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: 0, y: self.frame.height/2 - 70) //MARK: Change 80 here if problems ig
        scoreLabel.zPosition = 2
        worldNode.addChild(scoreLabel)

        // Set background
        background.size = self.frame.size
        background.position = CGPoint(x:0, y:0)
        background.zPosition = -3
        addChild(background)
        
        if !worldNode.isPaused {
            //TODO: this
            //self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run{self.spawnEnemy()}, SKAction.wait(forDuration: 2.5)])))
            //self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run{self.spawnLilEnemy()}, SKAction.wait(forDuration: 3.0)])))
        }
    }

    
    //MARK: update
    
    
    
    override func update(_ currentTime: TimeInterval) {
        //TODO: Insert game score here
        gameScore += 1
        
        PlayerPosx = CGFloat((virtualController?.controller?.extendedGamepad?.leftThumbstick.xAxis.value)!)
        if PlayerPosx >= 0.5 {
        chicken.position.x += 1
        }
        if PlayerPosx <= -0.5 {
            chicken.position.x -= 1
        }
    }
    func connectVirtuellController() {
        let controllerConfic = GCVirtualController.Configuration()
        controllerConfic.elements = [GCInputLeftThumbstick]
        let controller = GCVirtualController(configuration: controllerConfic)
        controller.connect()
    
        virtualController = controller
    }
}


