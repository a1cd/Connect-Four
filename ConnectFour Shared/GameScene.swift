//
//  GameScene.swift
//  ConnectFour Shared
//
//  Created by Everett Wilber on 5/13/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, ConnectFourScene {
	var game: TickTackToe?
	var entities = [GKEntity]()
	var graphs = [String : GKGraph]()
	
	private var lastUpdateTime : TimeInterval = 0
	private var label : SKLabelNode?
	private var spinnyNode : SKShapeNode?
	private var puckViewHoles: [[SKShapeNode]] = []
	var pucks: [[SKShapeNode]] = Array(repeating: Array(repeating: SKShapeNode(circleOfRadius: 0), count: 6), count: 7)
	private var columnGuides: [SKShapeNode] = []
	private var mouse: SKShapeNode?
	private var puckViewHoleSize = 100.0
	private var viewHoleGapSize = 25.0
	private var columnGap = 25.0
	var lights: SKNode?
	var lightCorners: [SKLightNode] = []
	var yellowLights: [SKLightNode] = []
	var redLights: [SKLightNode] = []
	var background: SKShapeNode?
	var winningParticle: SKEmitterNode?
	
	func setPuck(_ row: Int, _ col: Int, _ team: Team) {
		if (team == Team.red) {
			pucks[col][row].fillColor = .red
			pucks[col][row].physicsBody?.isDynamic = true
		} else if (team == Team.yellow) {
			pucks[col][row].fillColor = .yellow
			pucks[col][row].physicsBody?.isDynamic = true
		} else {
			pucks[col][row].physicsBody?.isDynamic = false
		}
	}
	
	func winningPuck(fromCol: Int, fromRow: Int, toCol: Int, toRow: Int) {
		let path = CGMutablePath()
		path.addLines(between: [
			getPositionFor(
				row: Double(fromRow),
				col: Double(fromCol)
			),
			getPositionFor(
				row: Double(toRow),
				col: Double(toCol)
			)
		])
		let winPath = SKShapeNode(path: path)
		winPath.lineWidth = 10
		self.addChild(winPath)
	}
	
	func gameWon(by: Team) {
		print("winner" + by.rawValue.description)
		background?.fillColor = by.color.withAlphaComponent(0.5)
		background?.run(SKAction(named: "Pulse")!)
		
		if (by == Team.red) {
			winningParticle = SKEmitterNode(fileNamed: "red")
		} else {
			winningParticle = SKEmitterNode(fileNamed: "yellow")
		}
		winningParticle?.position = .init(x: frame.midX, y: frame.maxY)
		self.addChild(winningParticle!)
	}
	
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
		scene.setupScene()
		
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        return scene
    }
	
	func findSizes() {
		let split = CGFloat.minimum(
			frame.size.width/10,
			frame.size.height/9
		)
		columnGap = split/6
		viewHoleGapSize = split/6
		puckViewHoleSize = split*(2/3)
	}
	
	func setupScene() {
		findSizes()
		
		background = SKShapeNode(rectOf: self.size)
		background?.zPosition = -1
		self.addChild(background!)
		
		lights = self.childNode(withName: "Lights")
		lightCorners.append(lights?.childNode(withName: "UL_Light_Yellow") as! SKLightNode)
		lightCorners.append(lights?.childNode(withName: "BL_Light_Yellow") as! SKLightNode)
		yellowLights.append(lights?.childNode(withName: "UL_Light_Yellow") as! SKLightNode)
		yellowLights.append(lights?.childNode(withName: "BL_Light_Yellow") as! SKLightNode)
		lightCorners.append(lights?.childNode(withName: "UR_Light_Red") as! SKLightNode)
		lightCorners.append(lights?.childNode(withName: "BR_Light_Red") as! SKLightNode)
		redLights.append(lights?.childNode(withName: "UR_Light_Red") as! SKLightNode)
		redLights.append(lights?.childNode(withName: "BR_Light_Red") as! SKLightNode)
		game = TickTackToe(scene: self)
		let shape = SKShapeNode(circleOfRadius: puckViewHoleSize)
		shape.physicsBody = SKPhysicsBody(circleOfRadius: 10, center: CGPoint())
		shape.physicsBody?.isDynamic=false
		self.addChild(shape)
		
		self.lastUpdateTime = 0
		
		self.mouse = SKShapeNode(circleOfRadius: 15)
		self.mouse!.fillColor = .white
		self.mouse!.strokeColor = .black
		self.mouse!.lineWidth = 3.0
		self.mouse!.glowWidth = 0.5
		// Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
		// Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
		for column in 0...7 {
//			let pointFrom = CGPoint(
//				x: (Double(column)-3.5) * (viewHoleGapSize+puckViewHoleSize) + (puckViewHoleSize+viewHoleGapSize)/2,
//				y: (-3.0) * (viewHoleGapSize + puckViewHoleSize)
//			)
//			let pointTo = CGPoint(
//				x: (Double(column)-3.5) * (viewHoleGapSize+puckViewHoleSize) + (puckViewHoleSize/2),
//				y: (3.0) * (viewHoleGapSize + puckViewHoleSize)
//			)
			let visual = SKShapeNode(
				rect: CGRect(
					origin: CGPoint.init(
						x: 0.0,
						y: 0.0
					),
					size: CGSize(
						width: 1,
						height: (self.viewHoleGapSize*5)+(puckViewHoleSize*6)*2
					)
				)
			)
			visual.lineWidth = 0
//			visual.strokeColor = .blue
			visual.physicsBody = SKPhysicsBody(rectangleOf: visual.frame.size, center: visual.position)
			visual.physicsBody?.isDynamic = false
			visual.position.x = getPositionFor(row: 0, col: Double(column)-0.5).x
			self.addChild(visual)
			self.columnGuides.append(visual)
		}
		let path = CGMutablePath()
		path.addLines(between: [getPositionFor(row: -0.5, col: 0), getPositionFor(row: -0.5, col: 8)])
		let BottomBox = SKShapeNode(path: path)
		BottomBox.physicsBody = SKPhysicsBody(
			edgeFrom: getPositionFor(row: -0.5, col: 0),
			to: getPositionFor(row: -0.5, col: 8)
		)
		BottomBox.physicsBody?.isDynamic=false
		BottomBox.fillColor = .systemBlue
		self.addChild(BottomBox)
		
		for column in 0..<7 {
			var columnHolder: [SKShapeNode] = []
			for row in 0..<6 {
				let node = SKShapeNode(rectOf: CGSize(
						width: puckViewHoleSize,
						height: puckViewHoleSize
					),
					cornerRadius: 15
				)
				node.position = getPositionFor(row: Double(row), col: Double(column))
				print(node.position)
				node.lineWidth = 5
				self.addChild(node)
				columnHolder.append(node)
				
				let shape = SKShapeNode(circleOfRadius: (puckViewHoleSize+viewHoleGapSize)/2)
				shape.physicsBody = SKPhysicsBody(circleOfRadius: (puckViewHoleSize+viewHoleGapSize)/2, center: CGPoint())
				shape.physicsBody?.isDynamic = false
				shape.physicsBody?.restitution = 0.4
				shape.position = getPositionFor(row: Double(row)+7.5, col: Double(column))
				shape.lineWidth = 4
				shape.fillColor = .black
				shape.zPosition = -0.1
				pucks[column][row] = shape
				self.addChild(shape)
			}
			self.puckViewHoles.append(columnHolder)
		}
		
	}
	
	func click(at: CGPoint) {
		if game!.winner == Team.noTeam {
			game!.place(getColumn(at))
			if game!.winner == Team.noTeam {
				background?.fillColor = game!.turn.color.withAlphaComponent(0.25)
			}
		}
	}
	func getPositionFor(row: Double, col: Double) -> CGPoint {
		return CGPoint(
			x: (col-3.5) * (puckViewHoleSize+viewHoleGapSize+columnGap),
			y: (row-3.0) * (puckViewHoleSize+viewHoleGapSize)
		)
	}
	func getColumn(_ forPoint: CGPoint) -> Int {
		let col = round(
			(forPoint.x/(puckViewHoleSize+viewHoleGapSize+columnGap))+3.5
		)
		if (col>=0 && col<7) {
			return Int(col)
		} else {
			return -1
		}
	}
	
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction(named: "Pulse")!, withKey: "fadeInOut")
        }
        super.touchesBegan(touches, with: event)
        for t in touches {

        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			click(at: t.location(in: self))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
        }
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
	override func mouseEntered(with event: NSEvent) {
		mouse?.isHidden = false
		mouse?.position = event.location(in: self)
		print(mouse!)
	}
	override func mouseExited(with event: NSEvent) {
		mouse?.isHidden = true
		print(mouse!)
	}
	override func mouseMoved(with event: NSEvent) {
		mouse?.position = event.location(in: self)
		print("hi")
	}
	
    override func mouseDown(with event: NSEvent) {
		print("down")
    }
    
    override func mouseDragged(with event: NSEvent) {
		print("drag")
    }
    
    override func mouseUp(with event: NSEvent) {
		mouse?.position = event.location(in: self)
		click(at: event.location(in: self))
    }
}
#endif

