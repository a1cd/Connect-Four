//
//  TickTackToeScene.swift
//  Connect-Four
//
//  Created by Everett Wilber on 5/18/22.
//

import Foundation
import SpriteKit

protocol ConnectFourScene: SKScene {
	func setPuck(_ row: Int, _ col: Int, _ team: Team)
	func gameWon(by: Team)
	func winningPuck(fromCol: Int, fromRow: Int, toCol: Int, toRow: Int)
}
