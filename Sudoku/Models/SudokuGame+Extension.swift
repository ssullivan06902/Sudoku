//
//  SudokuGame+Extension.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/7/25.
//

import Foundation

// Extension to add game completion tracking
extension SudokuGame {
    // Track if game has been completed and celebrated already
    private static var completedGames = Set<String>()
    
    // Generate unique identifier for current game state
    private var gameIdentifier: String {
        "\(boardSize.description)-\(difficulty.rawValue)-\(initialState.description)"
    }
    
    // Mark the current game as complete to prevent celebration popup from reappearing
    func markGameComplete() {
        SudokuGame.completedGames.insert(gameIdentifier)
    }
    
    // Check if game is solved but also not previously celebrated
    func isSolvedAndNotCelebrated() -> Bool {
        // Only return true if the game is solved AND we haven't celebrated it yet
        return isSolved() && !SudokuGame.completedGames.contains(gameIdentifier)
    }
}
