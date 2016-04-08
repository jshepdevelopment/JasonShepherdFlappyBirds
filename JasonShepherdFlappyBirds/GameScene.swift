//
//  GameScene.swift
//  JasonShepherdFlappyBirds
//
//  Created by Jason Shepherd on 4/8/16.
//  Copyright (c) 2016 Salt Lake Community College. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // Variables to store score and game
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOver = 0
    var gameOverLabel = SKLabelNode()

    // Create a node for moving objects
    var movingObjects = SKNode()
    
    // Create the sprite nodes
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var labelHolder = SKSpriteNode()

    // Collision groups
    let birdGroup:UInt32 = 1
    let objectGroup:UInt32 = 2
    let gapGroup:UInt32 = 0 << 3 // bitwise mask
    
    override func didMoveToView(view: SKView) {
        
        // Set up world physics
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -5)
        
        self.addChild(movingObjects)
        
        // Set up label
        scoreLabel.fontName = "Helvitica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height-70)
        self.addChild(scoreLabel)
        
        // Set up and configure background texture, sprite node, position vertical stretch
        let backgroundTexture = SKTexture(imageNamed: "bg.png")
        
        
        // Creates the background action which moves x axis by size of background texture every 9 seconds
        let moveBackground = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: 9)
        // Replaces background to beginning
        let replaceBackground = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration: 0)
        // Creates an action that runs both actions in sequence
        let moveBackgroundForever = SKAction.repeatActionForever(SKAction.sequence([moveBackground, replaceBackground]))
        
        for var i:CGFloat = 0; i < 4; i++ {
            
            // Assign texture to backround node
            background = SKSpriteNode(texture: backgroundTexture)
            
            // Assign background position
            background.position = CGPoint(x: backgroundTexture.size().width/2+backgroundTexture.size().width * i, y: CGRectGetMidY(self.frame))
            
            // Stretches background vertically
            background.size.height = self.frame.height
            
            // Sets runAction method
            background.runAction(moveBackgroundForever)
            
            movingObjects.addChild(background)
            
        }
        
        // Create texture objects from image files
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        // Create animation object by defining images in an array to display every tenth of a second
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        
        // Add action object to run indefinately
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        
        // Assigns textures nodes
        bird = SKSpriteNode(texture: birdTexture)
        
        // Assigns positions for the sprite nodes
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        // Sets runAction method
        bird.runAction(makeBirdFlap)
        
        // Add physics to bird
        bird.physicsBody = SKPhysicsBody(circleOfRadius:bird.size.height / 2)
        // React to gravity
        bird.physicsBody?.dynamic = true
        // Don't spin around
        bird.physicsBody?.allowsRotation = false
        
        // Create collision groups
        bird.physicsBody?.categoryBitMask = birdGroup
        bird.physicsBody?.contactTestBitMask = objectGroup
        
        // Set z position to "front"
        bird.zPosition = 10
        
        // Adds sprite object to screen
        self.addChild(bird)
        
        // Set up ground node
        let ground = SKNode() // no texture or sprite
        ground.position = CGPointMake(0,0) // start bottom left
        // Width of screen is ground as rectangle
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        // Ground doesn't react to gravity
        ground.physicsBody?.dynamic = false
        
        ground.physicsBody?.categoryBitMask = objectGroup
        
        //Add to screen
        self.addChild(ground)
        
        // Timer to call makePipes
        let timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("makePipes"), userInfo: nil, repeats: true)
        

        
    }
    
    func makePipes() {
        
        // Set up pipe nodes
        // Pipe gap
        let gapHeight = bird.size.height * 4
        
        // Range of pipe movement - arc4random is from standard C library
        // Random number between 0 and half of screen size
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        // Pipe movement from starting point is a quarter of the screen size
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        
        // Moving the pipes
        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        
        // Removing pipes
        let removePipes = SKAction.removeFromParent()
        
        // Combine moving and removing pipes
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        
        let pipe1Texture = SKTexture(imageNamed: "pipe1.png")
        let pipe1 = SKSpriteNode(texture: pipe1Texture)
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipe1.size.height/2 + gapHeight / 2 + pipeOffset)
        pipe1.runAction(moveAndRemovePipes)
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1.size)
        pipe1.physicsBody?.dynamic = false
        pipe1.physicsBody?.categoryBitMask = objectGroup
        movingObjects.addChild(pipe1)
        
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipe2.size.height/2 - gapHeight / 2 + pipeOffset)
        pipe2.runAction(moveAndRemovePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2.size)
        pipe2.physicsBody?.dynamic = false
        pipe2.physicsBody?.categoryBitMask = objectGroup
        movingObjects.addChild(pipe2)
        
        // Make a scoring gap
        let gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody?.dynamic = false
        gap.physicsBody?.collisionBitMask = gapGroup
        gap.physicsBody?.contactTestBitMask = birdGroup
        movingObjects.addChild(gap)
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        print("Contact")
        
        // Contacting a gap
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup {
            score++
            scoreLabel.text = "\(score)"
            
            print("Gap contact")
        } else {
            if gameOver == 0 {
                gameOver = 1
                movingObjects.speed = 0
                
                gameOverLabel.fontName = "HELVITICA"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap to play again."
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                labelHolder.addChild(gameOverLabel)
                
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if gameOver == 0 {
            // Set the speed of bird to zero
            bird.physicsBody?.velocity = CGVectorMake(0,0)
            
            // Apply an impulse or force to the bird
            bird.physicsBody?.applyImpulse(CGVectorMake(0,50))
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
