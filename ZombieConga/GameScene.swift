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
    let zombieMoviePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    
    override init(size: CGSize) {
        print("Size \(size)")
        
        let maxAspectRadio:CGFloat = 16.0/9.0//1
        let playableHeight = size.width / maxAspectRadio //2
        let playableMargin = (size.height-playableHeight)/2.0 //3
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)//4
        
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
        velocity = direction * zombieMoviePointsPerSec
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
        sprite.zRotation = direction.angle
    }
    
    func checkLastLocation(lastTouchedLocation: CGPoint?)->Bool {
        guard let lastTouchedLocation = lastTouchLocation else {
            return true
        }
        
        let offsetOfLastTouchAndZombieCurrentPosition = lastTouchedLocation - zombie.position
        if offsetOfLastTouchAndZombieCurrentPosition.length() <= zombieMoviePointsPerSec * CGFloat(dt) {
            zombie.position = lastTouchedLocation
            velocity = CGPoint.zero
            return false
        } else {
            return true
        }
    }
}
