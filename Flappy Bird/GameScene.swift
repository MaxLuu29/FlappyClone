//
//  GameScene.swift
//  Flappy Clone
//
//  Created by D@ on 1/21/19.
//  Copyright © 2019 Max Luu. All rights reserved.
//

import SpriteKit
import GameplayKit
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var backGround = SKSpriteNode()
    var i = 0;
    var gameOver = false
    var scoreLabel = SKLabelNode()
    var score = 0
    var highestScore = 0
    var gameOverLabel = SKLabelNode()
    var timer = Timer()

    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    @objc func spawnPipes() {
        var pipeDown = SKNode()
        var pipeUp = SKNode()
        let gapHeight = bird.size.height * 4 - CGFloat(i)
        let movementOffset = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffset = CGFloat(movementOffset) - self.frame.height / 4

        let pipeVelocity = SKAction.move(by: CGVector(dx: -2 * self.frame.width , dy: 0), duration: TimeInterval(self.frame.width / 100))

        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        pipeDown = SKSpriteNode(texture: pipeTexture)
        pipeDown.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + (pipeTexture.size().height / 2) + (gapHeight / 2) + pipeOffset)
        pipeDown.name = "pipeDown"
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipeDown.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipeDown.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipeDown.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipeDown.physicsBody!.isDynamic = false
        
        self.addChild(pipeDown)
        pipeDown.run(pipeVelocity)

        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        pipeUp = SKSpriteNode(texture: pipe2Texture)
        pipeUp.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - (pipe2Texture.size().height / 2) - (gapHeight / 2) + pipeOffset)
        pipeUp.name = "pipeUp"
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipe2Texture.size())
        pipeUp.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipeUp.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipeUp.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipeUp.physicsBody!.isDynamic = false
        
        self.addChild(pipeUp)
        pipeUp.run(pipeVelocity)
        
        let gap = SKNode()
        gap.name = "gap"
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(pipeVelocity)
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        
        self.addChild(gap)
        i += 5
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            print("score")
            score += 1
        } else {
            print("contact made")
            bird.physicsBody!.isDynamic = false
            gameOver = true
            timer.invalidate()
            self.speed = 0
            
            gameOverLabel.fontName = "Menlo"
            gameOverLabel.fontSize = 30
            gameOverLabel.text = "Game Over"
            //gameOverLabel.fontColor = NSColor(named: "red")
            gameOverLabel.zPosition = 2
            self.addChild(gameOverLabel)
            
        }
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        gameSetUp()
    }
    
    func gameSetUp() {
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.spawnPipes), userInfo: nil, repeats: true)
        
        let backGroundTexture = SKTexture(imageNamed: "bg.png")
        
        let backGroundAnimation = SKAction.move(by: CGVector(dx: -backGroundTexture.size().width, dy: 0), duration: 7)
        let backGroundShift = SKAction.move(by: CGVector(dx: backGroundTexture.size().width, dy: 0), duration: 0)
        
        let makeBackGroundMove = SKAction.repeatForever(SKAction.sequence([backGroundAnimation, backGroundShift]))
        var i: CGFloat = 0
        
        while i < 3 {
            backGround = SKSpriteNode(texture: backGroundTexture)
            backGround.position = CGPoint(x: backGroundTexture.size().width * i, y: self.frame.midY)
            backGround.size.height = self.frame.height
            backGround.size.width = self.frame.width
            backGround.zPosition = -1
            backGround.name = "backGround"
            backGround.run(makeBackGroundMove)
            self.addChild(backGround)
            i+=1
        }
        
        let birdFlapUpTexture = SKTexture(imageNamed: "flappy1.png")
        let birdFlapDownTexture = SKTexture(imageNamed: "flappy2.png")
        
        let animation = SKAction.animate(with: [birdFlapUpTexture, birdFlapDownTexture], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdFlapUpTexture)
        
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.name = "bird"
        bird.run(makeBirdFlap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdFlapUpTexture.size().height / 2)
        bird.physicsBody!.isDynamic = false
        
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        
        self.addChild(bird)
        
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic = false
        ground.name = "ground"
        
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(ground)
        scoreLabel.fontName = "Consolas"
        scoreLabel.fontSize = 60
        scoreLabel.zPosition = 1
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        
        self.addChild(scoreLabel)
    }
    
    override func mouseDown(with event: NSEvent) {
        if gameOver == false {
            bird.physicsBody!.isDynamic = true;
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 70))
        } else {
            gameOver = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            gameSetUp()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        scoreLabel.text = "Score: \(score)"
        for node in self.children {
            if (node.name == "pipeUp" || node.name == "pipeDown" || node.name == "gap") {
                if (node.position.x < -700) {
                    self.removeChildren(in: [node])
                }
            }
        }
    }
}
