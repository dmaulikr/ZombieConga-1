//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by John Longenecker on 5/1/17.
//  Copyright © 2017 Echo Vector Technologies. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu.png")
        background.position = CGPoint(x: size.width/2, y:size.height/2)
        
        self.addChild(background)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneTapped()
    }
    
    func sceneTapped() {
        let scene = GameScene(size: size)
        scene.scaleMode = scaleMode
        
        let reveal = SKTransition.doorway(withDuration: 1.5)
        
        view?.presentScene(scene, transition: reveal)
    }
}
