//
//  GameScene.swift
//  JasonShepherdFlappyBirds
//
//  Created by Jason Shepherd on 4/8/16.
//  Copyright (c) 2016 Salt Lake Community College. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // Variables to set up some sweet particle effects
    let dragonSmokeParticle = SKEmitterNode(fileNamed: "DragonSmoke.sks")
    let fireTrailParticle = SKEmitterNode(fileNamed: "FireSpark.sks")
    let baddyTrailParticle = SKEmitterNode(fileNamed: "Magic.sks")

    
    // Variables to store score and game
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOver = 0
    var gameOverLabel = SKLabelNode()

    // Create a node for moving objects
    var movingObjects = SKNode()
    
    // Create the sprite nodes
    var dragon = SKSpriteNode()
    var fireball = SKSpriteNode()
    var baddy = SKSpriteNode()
    var bg1 = SKSpriteNode()
    var bg2 = SKSpriteNode()
    var bg3 = SKSpriteNode()
    var labelHolder = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
 
    // Collision groups
    let dragonGroup:UInt32 = 1
    let objectGroup:UInt32 =  2
    let fireballGroup:UInt32 = 3
    let baddyGroup:UInt32 = 4
    let gapGroup:UInt32 = 0 << 5
    
    // Load texture assets here to prevent in-game lag
    let pipe1Texture = SKTexture(imageNamed: "tower1.png")
    let pipe2Texture = SKTexture(imageNamed: "tower2.png")
    let dragonTexture1 = SKTexture(imageNamed: "frame-1.png")
    let dragonTexture2 = SKTexture(imageNamed: "frame-2.png")
    let dragonTexture3 = SKTexture(imageNamed: "frame-3.png")
    let dragonTexture4 = SKTexture(imageNamed: "frame-4.png")
    let fireballTexture = SKTexture(imageNamed: "fireball.png")
    let baddyTexture = SKTexture(imageNamed: "flappy1.png")
    let bg1Texture = SKTexture(imageNamed: "parallax-mountain-bg.png")
    let bg2Texture = SKTexture(imageNamed: "parallax-mountain-montain-far.png")
    let bg3Texture  = SKTexture(imageNamed: "parallax-mountain-mountains.png")
    
    override func didMoveToView(view: SKView) {
        
        // Set up gesture recognizer
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedRight(_:)))
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
        
        // Set up world physics
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -3)
        
        self.addChild(movingObjects)
        
        // Set up label
        scoreLabel.fontName = "Helvitica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height-70)
        self.addChild(scoreLabel)
        
        // Adding static background first
        let bg1 = SKSpriteNode(texture: bg1Texture)
        bg1.size.height = self.size.height
        bg1.size.width = self.size.width
        bg1.position = CGPointMake(self.size.width/2, self.size.height/2)
        bg1.zPosition = -3
        self.addChild(bg1)
        
        //scrollBackground(bg1Texture, scrollSpeed: 0.50, bgzPosition: -3)
        scrollBackground(bg2Texture, scrollSpeed: 0.05, bgzPosition: -2)
        scrollBackground(bg3Texture, scrollSpeed: 0.01, bgzPosition: -1)
        
        // Create animation object by defining images in an array to display every tenth of a second
        let animation = SKAction.animateWithTextures([dragonTexture1, dragonTexture2, dragonTexture3, dragonTexture4], timePerFrame: 0.1)
        
        // Add action object to run indefinately
        let makeDragonFlap = SKAction.repeatActionForever(animation)
        
        // Assigns textures nodes
        dragon = SKSpriteNode(texture: dragonTexture1)
        
        // Assigns positions for the sprite nodes
        dragon.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        // Sets runAction method
        dragon.runAction(makeDragonFlap)
        
        // Add physics to bird
        dragon.physicsBody = SKPhysicsBody(circleOfRadius: dragon.size.width/2)
        // React to gravity
        dragon.physicsBody?.dynamic = false
        // Don't spin around
        dragon.physicsBody?.allowsRotation = false
        
        // Create collision groups
        dragon.physicsBody?.categoryBitMask = dragonGroup
        dragon.physicsBody?.contactTestBitMask = baddyGroup
        
        // Adds sprite object to screen
        addChild(dragon)
        
        // Add some sweet particle fx to the dragon
        dragonSmokeParticle!.targetNode = self
        dragon.addChild(dragonSmokeParticle!)
        
        // Timer to call makePipes
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(GameScene.makePipes), userInfo: nil, repeats: true)
        makePipes()
        // Timer to spawn baddy
        _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(GameScene.spawnBaddy), userInfo: nil, repeats: true)
        
    }
    
    func makePipes() {
        
        // Set up pipe nodes
        // Pipe gap
        let gapHeight = dragon.size.height * 4
        let gap = SKNode()
       
        // Assign nodes here to increase speed
        pipe1 = SKSpriteNode(texture: pipe1Texture)
        pipe2 = SKSpriteNode(texture: pipe2Texture)
        
        // Range of pipe movement - arc4random is from standard C library
        // Random number between 0 and half of screen size
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        // Pipe movement from starting point is a quarter of the screen size
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        
        // Moving the pipes
        let movePipes = SKAction.moveByX(-self.frame.size.width*2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        
        // Removing pipes
        let removePipes = SKAction.removeFromParent()
        
        // Combine moving and removing pipes
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        //pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipe1.size.height / 2 + gapHeight / 2 + pipeOffset)
        
        pipe1.position = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width, CGRectGetMidY(self.frame) + pipe1.size.height / 2 + gapHeight / 2 + pipeOffset)
        pipe1.runAction(moveAndRemovePipes)
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1.size)
        pipe1.physicsBody?.dynamic = false
        pipe1.physicsBody?.categoryBitMask = objectGroup
        pipe1.physicsBody?.contactTestBitMask = fireballGroup
        movingObjects.addChild(pipe1)

        //pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipe2.size.height / 2 - gapHeight / 2 + pipeOffset)
        pipe2.position = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width, CGRectGetMidY(self.frame) - pipe2.size.height / 2 - gapHeight / 2 + pipeOffset)
        pipe2.runAction(moveAndRemovePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2.size)
        pipe2.physicsBody?.dynamic = false
        pipe2.physicsBody?.categoryBitMask = objectGroup
        pipe2.physicsBody?.contactTestBitMask = fireballGroup
        movingObjects.addChild(pipe2)
        
        // Make a scoring gap

        //gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffset)
        gap.position = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width, CGRectGetMidY(self.frame) + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody?.dynamic = false
        gap.physicsBody?.collisionBitMask = gapGroup
        gap.physicsBody?.categoryBitMask = gapGroup
        gap.physicsBody?.contactTestBitMask = dragonGroup
        
        if gameOver == 1 {
            gap.position = CGPointMake(0.0, 0.0)
        }
        
        movingObjects.addChild(gap)
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        //print("Contact")
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //print("first body group is is \(firstBody.categoryBitMask)")
        //print("second body group is \(secondBody.categoryBitMask)")
        
        // Fireball collision with baddy
        if firstBody.categoryBitMask == 3 || secondBody.categoryBitMask == 3 {
            
            // Remove fireballs on collision, unless it's a gap
            if firstBody.categoryBitMask == 3 && secondBody.categoryBitMask != gapGroup {
               firstBody.node?.removeFromParent()
            }
            if secondBody.categoryBitMask == 3 && firstBody.categoryBitMask != gapGroup{
                secondBody.node?.removeFromParent()
            }
            
            if firstBody.categoryBitMask == 3 {
                print("firstbody fireball collision")
                score+=1
                secondBody.node?.removeFromParent()
                //print("first body group is is \(firstBody.categoryBitMask)")
                //print("second body group is \(secondBody.categoryBitMask)")
                //contact.bodyB.node!.removeFromParent
            }
        }
        
        // Dragon and baddy collision
        if firstBody.categoryBitMask == 1 || secondBody.categoryBitMask == 1 {
            print("dragon collided")
            if firstBody.categoryBitMask == 4 || secondBody.categoryBitMask == 4 {
                print("dragon baddy collision")
                gameOver=1
            }
        }
        
        // Contacting a gap
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup {
            score += 1
            scoreLabel.text = "\(score)"
            print("Gap contact")
        }

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if gameOver == 0 {
            // Set the speed of dragon to zero
            dragon.physicsBody?.velocity = CGVectorMake(0,0)
            
            // Apply an impulse or force to the dragon
            dragon.physicsBody?.applyImpulse(CGVectorMake(0,75))
        }
        
        if gameOver == 1 {
            gameOver = 0
            gameOverLabel.removeFromParent()
            
            score = 0
            scoreLabel.text = "0"
            dragon.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            dragon.physicsBody?.affectedByGravity = true
            movingObjects.speed = 1
        }
    }
   
    func swipedRight(sender:UISwipeGestureRecognizer){
        print("Swiped right")
        launchFireball()
    }
    
    func launchFireball() {
        
        // Only one trail particle per parent
        fireTrailParticle?.removeFromParent()
        
        // Moving the fireballs
        let moveFireball = SKAction.moveByX(0.01 , y: 0, duration: 0)

        fireball = SKSpriteNode(texture: fireballTexture)
        fireball.position = CGPoint(x: dragon.position.x+32, y: dragon.position.y)
        fireball.runAction(moveFireball)
        fireball.physicsBody = SKPhysicsBody(circleOfRadius: fireball.size.width)
        fireball.physicsBody?.dynamic = true
        fireball.physicsBody?.affectedByGravity = false
        fireball.physicsBody?.categoryBitMask = fireballGroup
        fireball.physicsBody?.contactTestBitMask = baddyGroup
        
        movingObjects.addChild(fireball)
        fireball.physicsBody?.applyImpulse(CGVectorMake(30,0))
        
        // Add some sweet particle fx to the dragon
        fireTrailParticle!.targetNode = self
        fireball.addChild(fireTrailParticle!)
    }
    
    func spawnBaddy() {
        
        baddyTrailParticle?.removeFromParent()
        
        // Random number between 0 and half of screen size
        let yPosition = arc4random() % UInt32(self.frame.size.height)
        
        baddy = SKSpriteNode(texture: baddyTexture)
        baddy.position = CGPoint(x: self.frame.size.width, y: CGFloat(yPosition))
        // Moving the bad guy
        let moveBaddy = SKAction.moveByX(-self.frame.size.width * 3, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        let removeBaddy = SKAction.removeFromParent()
        let moveAndRemoveBaddy = SKAction.sequence([moveBaddy, removeBaddy])
        
        baddy.runAction(moveAndRemoveBaddy) 
        baddy.physicsBody = SKPhysicsBody(rectangleOfSize: baddy.size)
        baddy.physicsBody?.dynamic = false
        baddy.physicsBody?.categoryBitMask = baddyGroup
        baddy.physicsBody?.contactTestBitMask = dragonGroup
        
        movingObjects.addChild(baddy)
        // Add some sweet particle fx to the dragon
        baddyTrailParticle!.targetNode = self
        baddy.addChild(baddyTrailParticle!)
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // Game over if dragon leaves screen
        if dragon.position.x < 0 || dragon.position.y < 0 {
            gameOver = 1
        }
        
        // Check for game over
        if gameOver == 1 {
            
                // Hold / Reset game for next play
                print("Game over.")
                gameOverLabel.removeFromParent()
                movingObjects.speed = 0
                baddy.removeFromParent()
                pipe1.removeFromParent()
                pipe2.removeFromParent()
                dragon.physicsBody?.affectedByGravity = false
                gameOverLabel.fontName = "Helvitica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap to play again."
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                gameOverLabel.zPosition = 15
                addChild(gameOverLabel)
            
        }
        
    }
    
    func scrollBackground(backgroundTexture: SKTexture, scrollSpeed: CGFloat, bgzPosition: CGFloat) {
        
        //make your SKActions that will move the image across the screen. this one goes from right to left.
        let moveBackground = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: NSTimeInterval(scrollSpeed * backgroundTexture.size().width))
        
        //This resets the image to begin again on the right side.
        let resetBackGround = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration: 0.0)
        
        //this moves the image run forever and put the action in the correct sequence.
        let moveBackgoundForever = SKAction.repeatActionForever(SKAction.sequence([moveBackground, resetBackGround]))
        
        //then run a for loop to make the images line up end to end.
        for var i:CGFloat = 0; i<2 + self.frame.size.width / (backgroundTexture.size().width); ++i {
            let sprite = SKSpriteNode(texture: backgroundTexture)
            sprite.yScale = 2.0
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2)
            sprite.zPosition = bgzPosition
        
            sprite.runAction(moveBackgoundForever)
            
            self.addChild(sprite)
        }
    }
}
