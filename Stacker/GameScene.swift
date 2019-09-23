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
    let IMAGE_NAMES = ["square_256x64", "square_128x128", "shape_1", "shape_2", "shape_1_f", "shape_2_f"]
    let MAX_NODE_COUNT = 10
    
    private var spawnedBlocksCount = 0
    private var draggedBlock: SKSpriteNode?
    private var spawnTimer = TimeInterval(exactly: 0)!
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -2.0)
        
        createLevel()
        
        // we use UIKit gesture recognition for the UI. Note that we reuse the "pan" gesture as a "drag/drop" gesture.
        let dragHandler = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        view.addGestureRecognizer(dragHandler)
        let tapHandler = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapHandler)
        
    }
    
    // note: this could also be created using a scene file
    private func createLevel() {
        // add a floor
        let floor = SKSpriteNode(color: SKColor.darkGray, size: CGSize(width: self.size.width, height: 32))
        floor.name = "Floor"
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.isDynamic = false
        floor.position = CGPoint(x: self.size.width / 2.0, y: 32)
        self.addChild(floor)
        
        // add walls
        // add left wall
        let leftWall = SKNode()
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: self.size.height))
        leftWall.name = "leftWall"
        leftWall.physicsBody?.isDynamic = false
        leftWall.position = CGPoint(x: leftWall.frame.width / 2.0, y: self.size.height / 2.0) // this places the wall just outside of visibility
        self.addChild(leftWall)
        
        // add right wall
        let rightWall = SKNode()
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: self.size.height))
        rightWall.name = "rightWall"
        rightWall.physicsBody?.isDynamic = false
        rightWall.position = CGPoint(x: self.size.width + rightWall.frame.width / 2.0, y: self.size.height / 2.0)
        self.addChild(rightWall)
    }
    
    @objc
    func handleDrag(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SKView
        guard let view = self.view else {
            return
        }
        
        // get the position within the view where the gesture event happened.
        let p = gestureRecognize.location(in: view)
        
        // convert the position within the view to position within the scene
        let scenePoint = view.convert(p, to: self)
        
        switch gestureRecognize.state {
        case .began:
            if let node = self.nodes(at: scenePoint).first {
                // make sure we are not trying to drag the level geometry
                guard ["Floor", "leftWall", "rightWall"].contains(node.name) == false else {
                    return
                }
                
                draggedBlock = node as? SKSpriteNode
                
                // set the physicsBody to "kinematic" so it is not affected by gravity when we drag it around.
                draggedBlock?.physicsBody?.isDynamic = false
            }
        case .changed:
            if let block = draggedBlock {
                // change block position to position within the scene where we are currently dragging to
                block.position = scenePoint
            }
        case .ended:
            // make the block dynamic again, so it's affected by gravity and other forces.
            draggedBlock?.physicsBody?.isDynamic = true
            draggedBlock = nil
        default:
            print("unknown state: \(gestureRecognize.state)")
        }
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SKView
        guard let view = self.view else {
            return
        }
        
        // get the position within the view where the tap happened.
        let p = gestureRecognize.location(in: view)
        
        // convert the position within the view to position within the scene
        let scenePoint = view.convert(p, to: self)
        
        if let node = self.nodes(at: scenePoint).first {
            // make sure we are not trying to drag the level geometry
            guard ["Floor", "leftWall", "rightWall"].contains(node.name) == false else {
                return
            }
            
            // we now do a couple of things
            // first, we set the node to be "kinematic", so it's not affected by gravity during the animation
            node.physicsBody?.isDynamic = false
            
            // then we create two actions:
            // action 1: move the node up so it has ample space to rotate
            let move = SKAction.move(by: CGVector(dx: 0, dy: node.frame.height), duration: 0.25)
            // action 2: rotate the node 90 degrees counter-clockwise.
            let rotation = SKAction.rotate(byAngle: 0.5 * CGFloat.pi, duration: 0.5)
            let sequence = SKAction.sequence([move, rotation])
            
            // the action has a completion handler, that makes the node dynamic again.
            node.run(sequence) {
                node.physicsBody?.isDynamic = true
            }
        }
    }
    
    private func createBlock() -> SKSpriteNode {
        // add a block
        let imageName = IMAGE_NAMES.randomElement()!
        let block = SKSpriteNode(imageNamed: imageName)
        block.color = COLORS.randomElement()!
        
        // use colorBlendFactor to "mix" the greyscale image and the selected color
        block.colorBlendFactor = 0.5
        
        if imageName.starts(with: "square") {
            block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
        } else {
            block.physicsBody = SKPhysicsBody(texture: block.texture!, size: block.texture!.size())
        }
        
        // spawn the block from top-center screen
        block.position = CGPoint(x: self.size.width / 2.0, y: self.size.height)
        return block
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if spawnedBlocksCount < MAX_NODE_COUNT && currentTime > spawnTimer {
            self.addChild(createBlock())
            spawnTimer = currentTime + Double.random(in: 0.25...0.75)
            spawnedBlocksCount += 1
        }
    }
}
