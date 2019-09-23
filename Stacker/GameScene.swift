//
//  GameScene.swift
//  Stacker
//
//  Created by Maarten Engels on 22/09/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let COLORS = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow]
    let IMAGE_NAMES = ["square_64x64", "square_128x64"]
    
    let MAX_NODE_COUNT = 10
    
    var spawnedNodes = 0
    
    var draggedNode: SKSpriteNode?
    
    var spawnTimer = TimeInterval(exactly: 0)!
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -2.0)
        
        // add a floor
        let floor = SKSpriteNode(color: SKColor.darkGray, size: CGSize(width: self.size.width, height: 32))
        floor.name = "Floor"
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.isDynamic = false
        floor.position = CGPoint(x: self.size.width / 2.0, y: 32)
        self.addChild(floor)
        
        // add walls
        let leftWall = SKNode()
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: self.size.height))
        leftWall.name = "leftWall"
        leftWall.physicsBody?.isDynamic = false
        leftWall.position = CGPoint(x: -8, y: self.size.height / 2.0)
        self.addChild(leftWall)
        
        let rightWall = SKNode()
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: self.size.height))
        rightWall.name = "rightWall"
        rightWall.physicsBody?.isDynamic = false
        rightWall.position = CGPoint(x: self.size.width + 8, y: self.size.height / 2.0)
        self.addChild(rightWall)
        
        let dragHandler = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        view.addGestureRecognizer(dragHandler)
        let tapHandler = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapHandler)
        
    }
    
    @objc
    func handleDrag(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        guard let view = self.view else {
            return
        }
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: view)
        
        let scenePoint = view.convert(p, to: self)
        
        switch gestureRecognize.state {
        case .began:
            if let node = self.nodes(at: scenePoint).first {
                guard ["Floor", "leftWall", "rightWall"].contains(node.name) == false else {
                    return
                }
                
                draggedNode = node as? SKSpriteNode
                draggedNode?.physicsBody?.isDynamic = false
            }
        case .changed:
            if let node = draggedNode {
                node.position = scenePoint
            }
        case .ended:
            draggedNode?.physicsBody?.isDynamic = true
            draggedNode = nil
        default:
            print("unknown state: \(gestureRecognize.state)")
        }
        
        
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        guard let view = self.view else {
            return
        }
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: view)
        
        let scenePoint = view.convert(p, to: self)
        
        if let node = self.nodes(at: scenePoint).first {
            node.physicsBody?.isDynamic = false
            let move = SKAction.move(by: CGVector(dx: 0, dy: 64), duration: 0.25)
            
            let rotation = SKAction.rotate(byAngle: 0.5 * CGFloat.pi, duration: 0.5)
            let sequence = SKAction.sequence([move, rotation])
            
            node.run(sequence) {
                node.physicsBody?.isDynamic = true
            }
        }
    }
    
    func createBlock() -> SKSpriteNode {
        // add a block
        let sprite = SKSpriteNode(imageNamed: IMAGE_NAMES.randomElement()!)
        sprite.color = COLORS.randomElement()!
        sprite.colorBlendFactor = 0.5
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.position = CGPoint(x: self.size.width / 2.0,y: self.size.height - 64.0)
        return sprite
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if spawnedNodes < MAX_NODE_COUNT && currentTime > spawnTimer {
            self.addChild(createBlock())
            spawnTimer = currentTime + Double.random(in: 0.25...0.75)
            spawnedNodes += 1
        }
        
    }
}
