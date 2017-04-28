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
        backgroundColor = SKColor.black
        let background = SKSpriteNode(imageNamed: "background1")
        
        
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
        
        
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
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
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
        guard let lastTouchedLocation = lastTouchLocation else {
            return true
        }
        
        let offsetOfLastTouchAndZombieCurrentPosition = lastTouchedLocation - zombie.position
        if offsetOfLastTouchAndZombieCurrentPosition.length() <= zombieMovePointsPerSec * CGFloat(dt) {
            zombie.position = lastTouchedLocation
            velocity = CGPoint.zero
            stopZombieAnimation()
            return false
        } else {
            return true
        }
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: size.height/2)
        addChild(enemy)
        //let actionMove = SKAction.move(to: CGPoint(x: -enemy.size.width/2, y:enemy.position.y ), duration: 2.0)
        //let actionMoveTwo = SKAction.moveBy(x: zombie.position.x, y: zombie.position.y, duration: 2.0)
        //let actionTest = SKAction.move(to: zombie.position, duration: 2.0)
        sequenceActionExample(enemy: enemy)
        //enemy.run(actionMove)
    }
    
    func newSpawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: playableRect.minY + enemy.size.height/2, max: playableRect.maxY - enemy.size.height/2))
        addChild(enemy)
        
        let actionMove = SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
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
            x: CGFloat.random(min: playableRect.minX,
                              max: playableRect.maxX),
            y: CGFloat.random(min: playableRect.minY,
                              max: playableRect.maxY))
        cat.setScale(0)
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
}
