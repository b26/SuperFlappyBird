//
//  GameScene.swift
//  SuperFlappyBird
//
//  Created by Bashir on 2015-03-24.
//  Copyright (c) 2015 b26. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var startMenu = SKSpriteNode()
    
    var background = SKSpriteNode()
    
    var bird = SKSpriteNode()
    
    var menuObject = SKNode()
    
    var gameOverMenuObject = SKNode()
    
    var movingObjects = SKNode()
    
    var scoreLabelHolder = SKNode()
    
    var birdObject = SKNode()
    
    var birdLevel:UInt32 = 1
    
    var backgroundSpeed:NSTimeInterval = 9
    
    let birdGroup: UInt32 = 1
    
    let objectGroup: UInt32 = 2
    
    let gapGroup:UInt32 = 0 << 3
    
    var score = 0
    
    var timerStarted = 0
    
    var gameOver = 0 //0 is game is going On
    
    var scoreLabel = SKLabelNode()
    
    var timer = NSTimer()
    
    var birdTimer = NSTimer()
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.physicsWorld.contactDelegate = self
        self.name = "Main"
        self.addChild(menuObject)
        self.addChild(movingObjects)
        self.addChild(birdObject)
        self.addChild(gameOverMenuObject)
        self.addChild(scoreLabelHolder)
        createBackground()
        createStartMenu()
        createBird()
        //loadGameOverScreen()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            var location:CGPoint = touch.locationInNode(self)
            var node:SKNode = self.nodeAtPoint(location)
            
            if let name = node.name as String! {
                switch (name) {
                case "Easy":
                    println("Easy")
                    menuObject.removeAllChildren()
                    birdLevel = 1
                    backgroundSpeed = 9
                    removeBackgroundBirdPipesScore()
                    reloadBackgroundBirdPipesScore()
                    createGround()
                    //addScoreLabel()
                    
     
                case "Medium":
                    backgroundSpeed = 3
                    birdLevel = 2
                    menuObject.removeAllChildren()
                    removeBackgroundBirdPipesScore()
                    messageThenRun()
                    reloadBackgroundBirdPipesScore()
                    createGround()

                case "Super":
                    menuObject.removeAllChildren()
                    birdLevel = 1
                    
                    birdPhysics()
                    println("Super")
                    
                case "Main":
                    println("Main")
                    
                case "RetryButton":
                    println("Retry BABY")
                    //need a retry game function
                    gameOverMenuObject.removeAllChildren()
                    retryGame()
                    
                case "MainButton":
                    println("Main BABY")
                    gameOverMenuObject.removeAllChildren()
                    createStartMenu()
                    
                case "Bird":
                    birdFlaps()
                
                default:
                    println("Somewhere else")
                }
            }
            
            else {
                birdFlaps()
            }
    
        }
    }
    
    func createBackground () {
        var backgroundTexture = SKTexture(imageNamed: "bg")
        var moveBackgroundByX = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: backgroundSpeed)
        var replaceBackground = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration: 0)
        var moveBackgroundForever = SKAction.repeatActionForever(SKAction.sequence([moveBackgroundByX, replaceBackground]))
        
        for var i:CGFloat = 0; i < 3; i++ {
            background = SKSpriteNode(texture: backgroundTexture)
            background.position = CGPoint(x: backgroundTexture.size().width/2 + (backgroundTexture.size().width * i), y: CGRectGetMidY(self.frame))
            background.size.height = self.frame.height
            background.runAction(moveBackgroundForever)
            movingObjects.addChild(background)
        }
    }
    
    func createBird () {
        
        var birdTextureOne = SKTexture(imageNamed: "flappy1")
        var birdTextureTwo = SKTexture(imageNamed: "flappy2")
        
        bird = SKSpriteNode(texture: birdTextureOne)
        
        bird.name = "Bird"
        
        var animateBirdForever = SKAction.repeatActionForever(SKAction.animateWithTextures([birdTextureOne, birdTextureTwo], timePerFrame: 0.1))
        
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height - (self.frame.height * 5/32))
        
        bird.physicsBody?.categoryBitMask = birdGroup
        
        bird.physicsBody?.collisionBitMask = gapGroup
        
        bird.physicsBody?.contactTestBitMask = objectGroup
        
        println(self.frame.height)
        
        bird.runAction(animateBirdForever)
        
        bird.zPosition = 100
        
        birdObject.addChild(bird)
        
    }
    
    func birdPhysics () {
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.allowsRotation = false
    }
    
    func birdFlaps() {
        if gameOver == 0 {
            switch (birdLevel) {
            case 1:
                bird.physicsBody?.velocity = CGVectorMake(0, 0)
                bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
                bird.physicsBody?.allowsRotation = false
                self.physicsWorld.speed = 1
            case 2:
                if birdPosition() {
                    bird.physicsBody?.allowsRotation = true
                    bird.physicsBody?.velocity = CGVectorMake(0, 30)
                    bird.physicsBody?.applyImpulse(CGVectorMake(0, 60))
                }
                else {
                    gameOver = 1
                    self.movingObjects.speed = 0
                    scoreLabel.hidden = true
                    loadGameOverScreen()
                }
                
            case 3:
                bird.physicsBody?.velocity = CGVectorMake(0, 0)
                bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
                println("SUUUPPPPPAAAA")
            default:
                println("Error")
            }
        }
    }
    
    func createGround () {
        
        var ground = SKNode()
        
        ground.position = CGPointMake(0, 0)
        
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.width * 2, 1))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.contactTestBitMask = birdGroup
        
        if birdLevel == 1 {
            ground.physicsBody?.categoryBitMask = objectGroup
        }
        
        self.addChild(ground)
        
    }
    
    func createPipes () {
        
        var pipeOne = SKSpriteNode()
        var pipeTwo = SKSpriteNode()
        
        var pipeOneTexture = SKTexture(imageNamed: "pipe1")
        var pipeTwoTexture = SKTexture(imageNamed: "pipe2")
        
        var movementAmount = CGFloat(arc4random() % (UInt32(self.frame.size.height / 2)))
        
        var pipeOffset = movementAmount - self.frame.size.height / 4
        
        var movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        
        var movePipesUp = SKAction.moveBy(CGVector(dx: 0, dy: 25), duration: 0.5)
        var movePipesDown = SKAction.moveBy(CGVector(dx: 0, dy: -25), duration: 0.5)
        var moveNew = SKAction.moveBy(CGVector(dx: -self.frame.size.width * 2, dy: 100), duration: NSTimeInterval(self.frame.size.width / 100))
        var removePipes = SKAction.removeFromParent()
        
        var move = SKAction.sequence([movePipesUp, movePipesDown])
        
        var repeat = SKAction.repeatActionForever(move)
        
        var moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        var gapPipe = bird.size.height * 2

        
        if birdLevel == 2 {
            moveAndRemovePipes = SKAction.group([moveNew, repeat])
            gapPipe = 2 * (gapPipe/3)
            
        }
        
        
        pipeOne = SKSpriteNode(texture: pipeOneTexture)
        pipeTwo = SKSpriteNode(texture: pipeTwoTexture)
        
        pipeOne.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.width, y: CGRectGetMidY(self.frame) + pipeOne.size.height/2 + gapPipe + pipeOffset)
        
        pipeOne.physicsBody = SKPhysicsBody(rectangleOfSize: pipeOne.size)
        

        pipeTwo.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.width, y: CGRectGetMidY(self.frame) - pipeTwo.size.height/2 - gapPipe + pipeOffset)
        
        pipeTwo.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTwo.size)
        
        //check for birdLevel before adding animations
        
        pipeOne.physicsBody?.dynamic = false
        
        pipeTwo.physicsBody?.dynamic = false
        
        
        pipeOne.physicsBody?.categoryBitMask = objectGroup
        
        pipeTwo.physicsBody?.categoryBitMask = objectGroup
        
        pipeOne.physicsBody?.contactTestBitMask = birdGroup
        
        pipeTwo.physicsBody?.contactTestBitMask = birdGroup

        pipeOne.runAction(moveAndRemovePipes)
        
        pipeTwo.runAction(moveAndRemovePipes)
        
        var gap = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(1, self.frame.height))
        
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width + (pipeOne.size.width / 2) + 20, y:  CGRectGetMidY(self.frame) +  pipeOffset)
        
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: gap.size)
        
        gap.physicsBody?.dynamic = false
        
        gap.physicsBody?.collisionBitMask = gapGroup
        
        gap.physicsBody?.categoryBitMask = gapGroup
        gap.name = "Gap"
        
        gap.physicsBody?.contactTestBitMask = birdGroup
        
        gap.zPosition = 1
        
        gap.runAction(moveAndRemovePipes)
        
        movingObjects.addChild(gap)
        
        movingObjects.addChild(pipeOne)
        movingObjects.addChild(pipeTwo)

    }
    
    func addScoreLabel () {
        scoreLabel.hidden = false
        scoreLabel.text = "0"
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height - 100)
        scoreLabel.zPosition = 9
        scoreLabelHolder.addChild(scoreLabel)
    }
    

    
    func createStartMenu () {
        
        var menuTitle = createLabel("Super Flappy Bird")
        
        menuTitle.fontSize = 40
        menuTitle.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height - menuTitle.frame.height - 10)
        
        
        menuObject.addChild(menuTitle)
        
        var margin:CGFloat = 10
        for var i:CGFloat = 0; i < 3; i++ {
            
            var color = UIColor(red:0.07 + (0.12 * i), green:0.23 + (0.22 * i), blue:0.32 + (0.12 * i), alpha:1)
            
            startMenu = SKSpriteNode(color: color, size: CGSizeMake(2*(self.frame.width/3), 100))
            startMenu.name = "Colored"
            
            if i == 0 {
                startMenu.addChild(createLabel("Easy"))
            }
            
            if i == 1 {
                startMenu.addChild(createLabel("Medium"))
            }
            
            if i == 2 {
                startMenu.addChild(createLabel("Super"))
                
            }
            startMenu.position = CGPoint(x: CGRectGetMidX(self.frame), y: (self.frame.height - startMenu.frame.height/2 - 200) - ((startMenu.frame.height + 10) * i))
            startMenu.zPosition = 3
            
            
            menuObject.addChild(startMenu)
        }

    }
    
    func createLabel(text: String) -> SKLabelNode {
        var label = SKLabelNode()
        label.name = text
        label.fontName = "Helvetica-Bold"
        label.text = text
        label.position = CGPoint(x: 0, y: -label.frame.height/2)
        return label
    }
    
    func messageThenRun() {
        var mediumMessage = "DON'T FALL OFF THE SCREEN".wordList
        //["Don't", "Fall", "Off", "The", "Screen"]
        
        for var i = 0; i < mediumMessage.count; i++ {
            var wordNode = SKLabelNode(text: mediumMessage[i])
            wordNode.fontName = "Helvetica-Bold"
            wordNode.fontSize = 80
            wordNode.fontColor = UIColor.redColor()
            wordNode.position = CGPoint(x: CGRectGetMidX(self.frame) + (self.frame.width * CGFloat(i)), y: CGRectGetMidY(self.frame))
            var dis = SKAction.colorizeWithColorBlendFactor(1, duration: 1)
            var moveByX = SKAction.moveByX(-self.frame.width - (self.frame.width * CGFloat(i)), y: 0, duration: 3 + ( 1 * NSTimeInterval(i)))
            //NSTimeInterval(i)
            //wordNode.runAction(SKAction.sequence([moveByX,dis]))
            wordNode.runAction(moveByX)
            self.addChild(wordNode)
        }
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup {
            
            println("A: \(contact.bodyA)")
            println("B: \(contact.bodyB)")
            
            score++
            
            scoreLabel.text = "\(score)"
            
        }
        
        else if contact.bodyA.categoryBitMask == objectGroup || contact.bodyB.categoryBitMask == objectGroup {
            if birdLevel == 1 {
                if gameOver == 0 {
                    self.movingObjects.speed = 0
                    gameOver = 1
                    scoreLabel.hidden = true
                    endTimerForPipes()
                    loadGameOverScreen()
                }
            }
            
            if birdLevel == 2 {
                println("KEEP GOING IT'LL ONLY GET WORSE....")
            }
            
            if birdLevel == 3 {
                println("I DONT KNOW WHAT TO SAY ANYMORE...GOOD LUCK")
            }
        }
        
    }
    
    func loadGameOverScreen() {
        //GameOver at the top
        //Then your score
        //Replay or Choose go back to main screen (load main screen).
        var gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontName = "Helvetica-Bold"
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height - gameOverLabel.frame.height - 10)
        
        gameOverMenuObject.addChild(gameOverLabel)
        
        
        //Add Score
        
        var scoreLabel = SKLabelNode(text: "Score")
        scoreLabel.fontSize = 40
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontColor = UIColor.redColor()
        scoreLabel.position = CGPoint(x: gameOverLabel.position.x, y: CGRectGetMidY(self.frame))
        
        gameOverMenuObject.addChild(scoreLabel)
        
        
        //Add Score Number
        
        var scoreNumberLabel = SKLabelNode(text: "\(score)")
        scoreNumberLabel.fontSize = 40
        scoreNumberLabel.fontName = "Helvetica-Bold"
        scoreNumberLabel.fontColor = UIColor.redColor()
        scoreNumberLabel.position = CGPoint(x: scoreLabel.position.x, y: scoreLabel.position.y - (scoreLabel.frame.height/2 + scoreNumberLabel.frame.height))
        
        gameOverMenuObject.addChild(scoreNumberLabel)
        
        
        //Load Options 
        
        
        //Retry
        
        var retryButton = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(self.frame.width/2, 100))
        
        retryButton.name = "RetryButton"
        
        var retryLabel = createLabel("Retry")
        
        retryLabel.name = "RetryButton"
        
        retryButton.position = CGPoint(x: self.position.x + retryButton.size.width/2, y: self.size.height/4)
        
        retryButton.zPosition = 10
        retryButton.addChild(retryLabel)
        
        gameOverMenuObject.addChild(retryButton)
        
        
        
        //Main Menu Button
        
        var mainMenuButton = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(self.frame.width/2, 100))
        
        mainMenuButton.zPosition = 10
        
        mainMenuButton.name = "MainButton"
        
        var mainMenuLabel = createLabel("Main Menu")
        
        mainMenuLabel.name = "MainButton"
        
        mainMenuButton.position = CGPoint(x: self.frame.width - mainMenuButton.size.width/2, y: self.size.height/4)
        
        mainMenuButton.addChild(mainMenuLabel)
        
        gameOverMenuObject.addChild(mainMenuButton)
        
    }
    
    //Stop Game
    
    func stopGame() {
        
        
        
    }
    
    func startTimerForPipes() {
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("createPipes"), userInfo: nil, repeats: true)
    }
    
    func endTimerForPipes() {
        timer.invalidate()
        //movingObjects.removeAllChildren()
    }
    
    //Retry Game
    
    func retryGame () {
        
        removeBackgroundBirdPipesScore()
        
        if gameOver == 1 {
            if birdLevel == 1 {
                reloadBackgroundBirdPipesScore()
                gameOver = 0
            }
            
            else if birdLevel == 2 {
                reloadBackgroundBirdPipesScore()
                gameOver = 0
            }
        }
    }
    
    func removeBackgroundBirdPipesScore() {
        birdObject.removeAllChildren()
        scoreLabelHolder.removeAllChildren()
        movingObjects.removeAllChildren()
        endTimerForPipes()
    }
    
    func reloadBackgroundBirdPipesScore() {
        if gameOver == 1 {
            gameOver = 0
        }
        score = 0
        scoreLabel.text = "0"
        createBackground()
        movingObjects.speed = 1
        
        if (birdObject.childNodeWithName("Bird") == nil) {
            createBird()
        }

        birdPhysics()
        addScoreLabel()
        scoreLabel.hidden = false

        startTimerForPipes()

    }
    
    func birdPosition() -> Bool {
        if bird.position.x > self.frame.origin.x {
            return true
        }
        
        else {

            return false
        }
    }
    
    func birdTimerStart() {
        if timerStarted == 0 {
            timerStarted == 1
            birdTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("birdPosition"), userInfo: nil, repeats: true)
        }
        else {
            
        }

    }
    
    func birdTimerEnd() {
        birdTimer.invalidate()
        println("deleted")
    }
}
