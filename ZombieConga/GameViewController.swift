//
//  GameViewController.swift
//  ZombieConga
//
//  Created by John Longenecker on 4/12/17.
//  Copyright © 2017 Echo Vector Technologies. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //let scene = GameScene(size: CGSize(width: 2048, height: 1536))
        let mainMenuScene = MainMenuScene(size: CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        mainMenuScene.scaleMode = .aspectFill
        skView.presentScene(mainMenuScene)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
