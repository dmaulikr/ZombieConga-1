//
//  GameScene.swift
//  ZombieConga
//
//  Created by John Longenecker on 4/12/17.
//  Copyright © 2017 Echo Vector Technologies. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var zombie: SKSpriteNode!
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * pi
    var velocity = CGPoint.zero
    
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    let zombieAnimation: SKAction
    let catMovePointsPerSecond: CGFloat = 480.0
    let catCollisionSound = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSOund = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    var zombieInvincible = false
    var lives = 5
    var gameOver = false
    
    let cameraNode = SKCameraNode()
    let cameraMovePointsPerSec: CGFloat = 200.0
    
    let livesLabel = SKLabelNode(fontNamed: "Glimstick")
    
    var cameraRect: CGRect {
        let x = cameraNode.position.x - size.width/2 + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height/2 + (size.height - playableRect.height)/2

        return CGRect (x: x, y: y, width: playableRect.width, height: playableRect.height)
    }

    
    override init(size: CGSize) {
        print("Size \(size)")
        
        let maxAspectRadio:CGFloat = 16.0/9.0//1
        let playableHeight = size.width / maxAspectRadio //2
        let playableMargin = (size.height-playableHeight)/2.0 //3
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)//4
        
        //1
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init (coder:) has not been implemented")//6
    }
    
    override func didMove(to view: SKView)
    {
//        backgroundColor = SKColor.black
//        let background = SKSpriteNode(imageNamed: "background1")
//        
//        
//        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        background.zPosition = -1
//        let background = backgroundNode()
//        background.anchorPoint = CGPoint.zero
//        background.position = CGPoint.zero
//        background.name = "background"
//        addChild(background)
//        
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            background.name = "background"
            addChild(background)
        }
        
        addZombie()
        //spawnEnemy()
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.newSpawnEnemy()},
                               SKAction.wait(forDuration: 2.0)])))
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                                                self?.spawnCat()
                }, SKAction.wait(forDuration: 1.0)])))
        
        playBackgroundMusic(filename: "backgroundMusic.mp3")
        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        livesLabel.text = "Lives: x"
        livesLabel.fontColor = SKColor.black
        livesLabel.fontSize = 100
        livesLabel.zPosition = 150
        //livesLabel.position = CGPoint.zero
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .bottom
        livesLabel.position = CGPoint(x: -playableRect.size.width/2 + CGFloat(20), y: -playableRect.size.height/2 + CGFloat(20))
        cameraNode.addChild(livesLabel)
        //addChild(livesLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
       // print("\(dt * 1000) milliseconds since last update")
        
        let result = checkLastLocation(lastTouchedLocation: lastTouchLocation)
        
        if result {
            rotate(sprite: zombie, direction: velocity)
            move(sprite: zombie, velocity: velocity)
        }

        boundsCheckZombie()
        //checkCollisiions()
        moveTrain()
        moveCamera()
        livesLabel.text = "Lives: \(lives)"
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You lose!")
            //1
            let gameOverScene = GameOverScene(size: size, won: false)
            backgroundMusicPlayer.stop()
            gameOverScene.scaleMode = scaleMode
            
            //2
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            
            //3 
            view?.presentScene(gameOverScene, transition: reveal)
        }
        //cameraNode.position = zombie.position
    }
    
    override func didEvaluateActions() {
        checkCollisiions()
    }
    
    func sceneTouched(touchLocation: CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(location: touchLocation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    func addZombie() {
        zombie = SKSpriteNode(imageNamed: "zombie1")
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.zPosition = 100
        addChild(zombie)
        //zombie.run(SKAction.repeatForever(zombieAnimation))
        
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        //1 
        let amountToMove = velocity * CGFloat(dt)

        //2
        sprite.position += amountToMove

    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
        startZombieAnimation()
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = abs(velocity.x)
        }
        
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            print("Velocity Before Change \(velocity)")
            velocity.y = -velocity.y
            print("Velocity After Change \(velocity)")
        }
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(zombieRotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate

        
    }
    
    func checkLastLocation(lastTouchedLocation: CGPoint?)->Bool {
//        guard let lastTouchedLocation = lastTouchLocation else {
//            return true
//        }
        
//        let offsetOfLastTouchAndZombieCurrentPosition = lastTouchedLocation - zombie.position
//        if offsetOfLastTouchAndZombieCurrentPosition.length() <= zombieMovePointsPerSec * CGFloat(dt) {
//            zombie.position = lastTouchedLocation
//            velocity = CGPoint.zero
//            stopZombieAnimation()
//            return false
//        } else {
//            return true
//        }
        return true
    }
    
//    func spawnEnemy() {
//        let enemy = SKSpriteNode(imageNamed: "enemy")
//        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: size.height/2)
//        addChild(enemy)
//        //let actionMove = SKAction.move(to: CGPoint(x: -enemy.size.width/2, y:enemy.position.y ), duration: 2.0)
//        //let actionMoveTwo = SKAction.moveBy(x: zombie.position.x, y: zombie.position.y, duration: 2.0)
//        //let actionTest = SKAction.move(to: zombie.position, duration: 2.0)
//        sequenceActionExample(enemy: enemy)
//        //enemy.run(actionMove)
//    }
    
    func newSpawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: cameraRect.maxX + enemy.size.width/2, y: CGFloat.random(min: cameraRect.minY + enemy.size.height/2, max: cameraRect.maxY - enemy.size.height/2))
        enemy.name = "enemy"
        enemy.zPosition = 50
        addChild(enemy)
        
        //let actionMove = SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
        let actionMove = SKAction.moveBy(x: -(size.width + enemy.size.width), y: 0, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func sequenceActionExample(enemy: SKSpriteNode) {
        //let actionMidMove = SKAction.move(to: CGPoint(x: size.width/2, y:playableRect.minY + enemy.size.height/2), duration: 1.0)
        let actionMidMove = SKAction.moveBy(x: -size.width/2 - enemy.size.width/2, y: -playableRect.height/2 + enemy.size.height/2, duration: 1.0)
        //let actionMove = SKAction.move(to: CGPoint(x: -enemy.size.width/2, y:enemy.position.y), duration: 1.0)
        let actionMove = SKAction.moveBy(x: -size.width/2-enemy.size.width/2, y: playableRect.height/2, duration: 1.0)
        let wait = SKAction.wait(forDuration: 0.25)
        let logMessage = SKAction.run() {
            print("Reached bottom!")
        }
        
        //let reverseMid = actionMidMove.reversed()
        //let reverseMove = actionMove.reversed()
        //let sequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove, reverseMove, logMessage, wait, reverseMid])
        let halfSequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove])
        let sequence = SKAction.sequence([halfSequence, halfSequence.reversed()])
        let repeatAction = SKAction.repeatForever(sequence)
        enemy.run(repeatAction)
        
    }
    
    func startZombieAnimation() {
        if zombie.action(forKey: "animation") == nil {
            zombie.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeAction(forKey: "animation")
    }
    
    func spawnCat() {
        //1 
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPoint(
            x: CGFloat.random(min: cameraRect.minX,
                              max: cameraRect.maxX),
            y: CGFloat.random(min: cameraRect.minY,
                              max: cameraRect.maxY))
        cat.zPosition = 50
        cat.setScale(0)
        cat.name = "cat"
        addChild(cat)
        
        //2
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        //let wait = SKAction.wait(forDuration: 10.0)
        cat.zRotation = -pi / 16.0
        let leftWiggle = SKAction.rotate(byAngle: pi/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        //let wiggleWait = SKAction.repeat(fullWiggle, count: 10)
        
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear,groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))

    }
    
    func zombieHit(cat: SKSpriteNode) {
//        cat.removeFromParent()
        catToTrain(cat: cat)
        run(catCollisionSound)

    }
    
    func zombieHit(enemy: SKSpriteNode) {
        zombieInvincible = true
        //enemy.removeFromParent()
        customBlinkAction(zombie: zombie)
        run(enemyCollisionSOund)
        loseCats()
        lives -= 1
    }
    
    func checkCollisiions() {
        var hitCats = [SKSpriteNode]()
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        
        for cat in hitCats {
            zombieHit(cat: cat)
        }
        
        if zombieInvincible {
            return
        }
        
        var hitEnemies = [SKSpriteNode]()
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 20).intersects(self.zombie.frame) {
                hitEnemies.append(enemy)
            }
        }
            
        for enemy in hitEnemies {
            zombieHit(enemy: enemy)
        }
        
    }
    
    func customBlinkAction(zombie: SKSpriteNode) {
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration/blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run() { [weak self] in
            self?.zombie.isHidden = false
            self?.zombieInvincible = false
        }
        zombie.run(SKAction.sequence([blinkAction,setHidden]))
    }
    
    func catToTrain(cat: SKSpriteNode) {
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1)
        cat.run(SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2))

        //zombie.zPosition = 100
    }
    
    func moveTrain() {
        var trainCount = 0
        var targetPosition = zombie.position
        
        enumerateChildNodes(withName: "train") { node, stop in
            trainCount += 1
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSecond
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
        
        if trainCount >= 10 && !gameOver {
            gameOver = true
            print("You win!")
            //1
            let gameOverScene = GameOverScene(size: size, won: true)
            backgroundMusicPlayer.stop()
            gameOverScene.scaleMode = scaleMode
            //2 
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            //3
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func loseCats() {
        //1
        var loseCount = 0
        enumerateChildNodes(withName: "train") {node, stop in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            
            node.name = ""
            let nodeActions = SKAction.sequence([SKAction.group([SKAction.rotate(byAngle: pi * 4, duration: 1.0), SKAction.move(to: randomSpot, duration: 1.0), SKAction.scale(to: 0, duration: 1.0), SKAction.scale(to: 0, duration: 1.0)])])
            
            node.run(nodeActions)
            //4
            loseCount += 1
            if loseCount >= 2 {
                stop[0] = true
            }
        }
    }
    
    func backgroundNode() ->SKSpriteNode {
        //1 
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        //2
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        //3
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        //4
        backgroundNode.size = CGSize(width: background1.size.width + background2.size.width, height: background1.size.height)
        return backgroundNode
        
    }
    
    func moveCamera() {
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        camera?.position += amountToMove
        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                background.position = CGPoint(x: background.position.x + background.size.width * 2, y: background.position.y)
            }
        }
    }
}
