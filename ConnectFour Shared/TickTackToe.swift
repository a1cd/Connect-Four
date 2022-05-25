//
//  File.swift
//  Connect-Four
//
//  Created by Everett Wilber on 5/18/22.
//

import Foundation
import CoreGraphics
#if os(macOS)
import AppKit
#else
import UIKit
#endif

enum Team: Int {
	case noTeam = 0
	case red = 1
	case yellow = 2
#if os(macOS)
	var color: NSColor {
		if (self == .red) {
			return NSColor.systemRed
		} else if (self == .yellow) {
			return NSColor.systemYellow
		}
		return NSColor.windowBackgroundColor
	}
#else
	var color: UIColor {
		if (self == .red) {
			return UIColor.systemRed
		} else if (self == .yellow) {
			return UIColor.systemYellow
		}
		return UIColor.systemBackground
	}
#endif
}

struct TickTackToe {
	var scene: ConnectFourScene
	var grid: [[Team]] = Array(repeating: Array(repeating: Team.noTeam, count: 6), count: 7)
	var turn = Team.red
	static let cols = 7
	static let rows = 6
	init(scene: ConnectFourScene) {
		self.scene = scene
	}
	mutating func setPuck(_ row: Int, _ col: Int, _ team: Team) {
		grid[col][row] = team
		scene.setPuck(row, col, team)
	}
	
	var winningTiles: [(Int, Int)] = []
	var winner = Team.noTeam
	mutating func checkForWin() {
		for col in 0..<Self.cols {
			for row in 0..<Self.rows {
				if grid[col][row] != Team.noTeam {
					for colInc in [-1,0,1] {
						for rowInc in [-1,0,1] {
							if ((colInc*4 + col > Self.cols || rowInc*4 + row > Self.rows ||
								colInc*4 + col < 0 || rowInc*4 + row < 0) ||
								(colInc == 0 && rowInc == 0)) {
								continue;
							}
							var isValid = true
							for i in 0..<4 {
								if (grid[col + colInc*i][row + rowInc*i] != grid[col][row]) {
									isValid = false
									break
								}
							}
							if isValid {
								winner = grid[col][row]
								scene.winningPuck(
									fromCol: col,
									fromRow: row,
									toCol: col + colInc*3,
									toRow: row + rowInc*3
								)
								scene.gameWon(by: winner)
								return
							}
						}
					}
				}
			}
		}
	}
	func columnPuckCount(at column: Int) -> Int {
		var count = 0
		for i in grid[column] {
			if (i.rawValue>0) {
				count += 1
			} else {
				return count
			}
		}
		return count
	}
	
	mutating func place(team: Team, at column: Int) -> Bool {
		let columnCount = columnPuckCount(at: column)
		if grid[column].count >= columnCount {
			grid[column][columnCount+1] = team
			return true
		}
		return false
	}
	mutating func place(_ column: Int) -> Bool {
		if (column == -1) {
			return false
		}
		let columnCount = columnPuckCount(at: column)
		if (columnCount >= 6) {
			return false
		}
		if grid[column].count >= columnCount {
			let team = turn
			if turn == .yellow {
				turn = .red
			} else {
				turn = .yellow
			}
			setPuck(columnCount, column, team)
			checkForWin()
			return true
		}
		return false

	}
}


