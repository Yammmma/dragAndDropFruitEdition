//
//  GameScene.swift
//  Drag and drop Fruit Edition
//
//  Created by Yuma Soerianto on 15/1/17.
//  Copyright © 2017 Yuma Soerianto. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

struct CategoryMasks {
    static let word: UInt32 = 0x1 << 0
    static let correct: UInt32 = 0x1 << 1
    static let incorrect: UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var fruits = ["Apple" : "🍎", "Pear" : "🍐", "Orange" : "🍊", "Lemon" : "🍋", "Banana" : "🍌"]
    
    var word: SKSpriteNode!
    var choice1: SKSpriteNode!
    var choice2: SKSpriteNode!
    var platform: SKSpriteNode!
    var wordTxt: SKLabelNode!
    var choice1Txt: SKLabelNode!
    var choice2Txt: SKLabelNode!
    
    var wordOriginalPosition = CGPoint(x: 0, y: 460)
    var correctNode = 0
    
    var correctAudio: AVAudioPlayer!
    var incorrectAudio: AVAudioPlayer!
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.yellow
        
        // word
        word = SKSpriteNode(color: UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: 217, height: 100))
        word.position = wordOriginalPosition
        addChild(word)
        
        // choices
        choice1 = SKSpriteNode(color: UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: 100, height: 100))
        choice1.position = CGPoint(x: -155, y: -617)
        addChild(choice1)
        
        choice2 = SKSpriteNode(color: UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: 100, height: 100))
        choice2.position = CGPoint(x: 155, y: -617)
        addChild(choice2)
        
        // platform
        platform = SKSpriteNode(color: UIColor.orange, size: CGSize(width: 300, height: 100))
        platform.position = CGPoint(x: 0, y: 360)
        addChild(platform)
        
        // labels
        wordTxt = SKLabelNode(text: "")
        wordTxt.position = CGPoint.zero
        wordTxt.fontSize = 100
        wordTxt.fontColor = UIColor.black
        word.addChild(wordTxt)
        
        choice1Txt = SKLabelNode(text: "")
        choice1Txt.position = CGPoint.zero
        choice1Txt.fontSize = 100
        choice1.addChild(choice1Txt)
        
        choice2Txt = SKLabelNode(text: "")
        choice2Txt.position = CGPoint.zero
        choice2Txt.fontSize = 100
        choice2.addChild(choice2Txt)
        
        // physics
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        word.physicsBody = SKPhysicsBody(rectangleOf: word.size)
        
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.isDynamic = false
        
        choice1.physicsBody = SKPhysicsBody(rectangleOf: choice1.size)
        choice1.physicsBody?.affectedByGravity = false
        choice1.physicsBody?.isDynamic = false
        
        choice2.physicsBody = SKPhysicsBody(rectangleOf: choice2.size)
        choice2.physicsBody?.affectedByGravity = false
        choice2.physicsBody?.isDynamic = false
        
        // Collision
        physicsWorld.contactDelegate = self
        
        word.physicsBody?.categoryBitMask = CategoryMasks.word
        word.physicsBody?.contactTestBitMask = CategoryMasks.correct | CategoryMasks.incorrect
        
        setLabels()
        
        // Audio
        let correctPath = Bundle.main.path(forResource: "correct", ofType: "mp3")!
        let incorrectPath = Bundle.main.path(forResource: "incorrect", ofType: "mp3")!
        
        let correctURL = URL(fileURLWithPath: correctPath)
        let incorrectURL = URL(fileURLWithPath: incorrectPath)
        
        do {
            try correctAudio = AVAudioPlayer(contentsOf: correctURL)
            try incorrectAudio = AVAudioPlayer(contentsOf: incorrectURL)
            
            correctAudio.prepareToPlay()
            incorrectAudio.prepareToPlay()
        } catch {
            print(error)
        }
    }
    
    func setLabels() {
        var nameArray = [String]()
        var iconArray = [String]()
        
        for (key, value) in fruits {
            nameArray.append(key)
            iconArray.append(value)
        }
        
        let correctIndex = Int(arc4random_uniform(5))
        correctNode = Int(arc4random_uniform(2))
        let incorrectIndex = Int(arc4random_uniform(4))
        
        wordTxt.text = nameArray[correctIndex]
        
        if correctNode == 0 {
            choice1Txt.text = iconArray[correctIndex]
            choice1.physicsBody?.categoryBitMask = CategoryMasks.correct
            
            iconArray.remove(at: correctIndex)
            
            choice2Txt.text = iconArray[incorrectIndex]
            choice2.physicsBody?.categoryBitMask = CategoryMasks.incorrect
        } else {
            choice2Txt.text = iconArray[correctIndex]
            choice2.physicsBody?.categoryBitMask = CategoryMasks.correct
            
            iconArray.remove(at: correctIndex)
            
            choice1Txt.text = iconArray[incorrectIndex]
            choice1.physicsBody?.categoryBitMask = CategoryMasks.incorrect
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1Id: UInt32!
        var body2Id: UInt32!
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1Id = contact.bodyA.categoryBitMask
            body2Id = contact.bodyB.categoryBitMask
        } else {
            body1Id = contact.bodyB.categoryBitMask
            body2Id = contact.bodyA.categoryBitMask
        }
        
        if body1Id == CategoryMasks.word {
            var correct: Bool?
            
            if body2Id == CategoryMasks.correct {
                correctAudio.play()
                correct = true
            } else if body2Id == CategoryMasks.incorrect {
                incorrectAudio.play()
                correct = false
            }
            
            if let actuallyCorrect = correct {
                word.physicsBody = nil
                word.zRotation = 0
                word.position = wordOriginalPosition
                word.physicsBody = SKPhysicsBody(rectangleOf: word.size)
                word.physicsBody?.categoryBitMask = CategoryMasks.word
                word.physicsBody?.contactTestBitMask = CategoryMasks.correct | CategoryMasks.incorrect
                
                if actuallyCorrect {
                    let correctPath = Bundle.main.path(forResource: "correctParticle", ofType: "sks")!
                    let correctParticle = NSKeyedUnarchiver.unarchiveObject(withFile: correctPath) as! SKEmitterNode
                    
                    if correctNode == 0 {
                        correctParticle.position = choice1.position
                    } else {
                        correctParticle.position = choice2.position
                    }
                    
                    addChild(correctParticle)
                    
                    setLabels()
                } else {
                    let incorrectPath = Bundle.main.path(forResource: "incorrectParticle", ofType: "sks")!
                    let incorrectParticle = NSKeyedUnarchiver.unarchiveObject(withFile: incorrectPath) as! SKEmitterNode
                    
                    if correctNode == 0 {
                        incorrectParticle.position = choice2.position
                    } else {
                        incorrectParticle.position = choice1.position
                    }
                    
                    addChild(incorrectParticle)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLoc = touch.location(in: self)
            let touchWhere = nodes(at: touchLoc)
            
            if !touchWhere.isEmpty {
                for node in touchWhere {
                    if let node = node as? SKSpriteNode {
                        if node == word {
                            word.position = touchLoc
                            word.physicsBody?.affectedByGravity = false
                        }
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLoc = touch.location(in: self)
            let touchWhere = nodes(at: touchLoc)
            
            if !touchWhere.isEmpty {
                for node in touchWhere {
                    if let node = node as? SKSpriteNode {
                        if node == word {
                            word.position = touchLoc
                        }
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLoc = touch.location(in: self)
            let touchWhere = nodes(at: touchLoc)
            
            if !touchWhere.isEmpty {
                for node in touchWhere {
                    if let node = node as? SKSpriteNode {
                        if node == word {
                            word.position = touchLoc
                            word.physicsBody?.affectedByGravity = true
                        }
                    }
                }
            }
        }
    }
}
