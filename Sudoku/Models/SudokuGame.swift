//
//  SudokuGame.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/5/25.
//

import Foundation
import Combine
import SwiftUI

class SudokuGame: ObservableObject {
    // Board representation
    @Published private(set) var board: [[Int]]
    @Published private(set) var initialState: [[Int]] = []
    @Published private(set) var selectedCell: (row: Int, col: Int)?
    
    // Board configuration
    @Published private(set) var boardSize: BoardSize
    @Published private(set) var difficulty: Difficulty
    
    // Game state tracking
    @Published private(set) var isGamePaused: Bool = false
    @Published private(set) var isGenerating: Bool = false
    
    // Notes tracking
    @Published private(set) var notes: [[[Bool]]] = []
    
    // Properties for tracking invalid moves with animation
    @Published private(set) var lastInvalidCell: (row: Int, col: Int)? = nil
    @Published private(set) var showInvalidAnimation: Bool = false
    
    // Notes mode toggle
    @Published private(set) var isNotesMode: Bool = false
    
    // Dynamic maximum number based on board size
    var maxNumber: Int {
        switch boardSize {
        case .medium: return 12
        case .large: return 16
        default: return 9
        }
    }
    
    // Initializer with board size and optional difficulty
    init(boardSize: BoardSize = .standard, difficulty: Difficulty = .easy) {
        // Set basic properties
        self.boardSize = boardSize
        self.difficulty = difficulty
        self.isGenerating = false
        
        // Initialize board
        self.board = Array(repeating:
                    Array(repeating: 0, count: boardSize.gridSize),
                    count: boardSize.gridSize)
        
        // Initialize notes
        self.initializeEmptyNotes()
        
        // Generate board
        let generator = SudokuGenerator(boardSize: boardSize, difficulty: difficulty)
        self.board = generator.getBoard()
        
        // Store initial state
        self.storeInitialState()
    }
    
    // Toggle pause state of the game
    func togglePause() {
        guard !isGenerating else { return }
        isGamePaused.toggle()
    }
    
    // Check if a move is valid
    private func isValidMove(row: Int, col: Int, number: Int) -> Bool {
        // Check row
        for c in 0..<boardSize.gridSize {
            if c != col && board[row][c] == number {
                return false
            }
        }
        
        // Check column
        for r in 0..<boardSize.gridSize {
            if r != row && board[r][col] == number {
                return false
            }
        }
        
        // Check box (sub-grid)
        let boxSizeRows = boardSize.subGridSizeRows
        let boxSizeCols = boardSize.subGridSizeCols
        
        let boxStartRow = (row / boxSizeRows) * boxSizeRows
        let boxStartCol = (col / boxSizeCols) * boxSizeCols
        
        for r in boxStartRow..<(boxStartRow + boxSizeRows) {
            for c in boxStartCol..<(boxStartCol + boxSizeCols) {
                if (r != row || c != col) && board[r][c] == number {
                    return false
                }
            }
        }
        
        // Additional checks for 12x12 and 16x16 boards
        switch boardSize {
        case .medium: // 12x12 board
            // Ensure number appears only once in the entire board
            for r in 0..<boardSize.gridSize {
                for c in 0..<boardSize.gridSize {
                    if (r != row || c != col) && board[r][c] == number {
                        return false
                    }
                }
            }
            
        case .large: // 16x16 board
            // Ensure number appears only once in the entire board
            for r in 0..<boardSize.gridSize {
                for c in 0..<boardSize.gridSize {
                    if (r != row || c != col) && board[r][c] == number {
                        return false
                    }
                }
            }
            
        default:
            // For 9x9, existing checks are sufficient
            break
        }
        
        return true
    }
    
    // Initialize empty notes array
    private func initializeEmptyNotes() {
        notes = Array(repeating:
                        Array(repeating:
                                Array(repeating: false, count: maxNumber + 1),
                              count: boardSize.gridSize),
                      count: boardSize.gridSize)
    }
    
    // Store the initial state of the board
    private func storeInitialState() {
        initialState = board.map { $0 }
    }
    
    // Enter a number in the selected cell
    func enterNumber(_ number: Int) {
        guard !isGenerating,
              let selectedCell = selectedCell,
              number <= maxNumber else { return }
        
        let row = selectedCell.row
        let col = selectedCell.col
        
        // Validate cell selection and initial state
        guard row >= 0 && row < boardSize.gridSize,
              col >= 0 && col < boardSize.gridSize,
              initialState[row][col] == 0 else { return }
        
        // Place the number if it's a valid move
        if isValidMove(row: row, col: col, number: number) {
            board[row][col] = number
            
            // Clear notes for this cell
            for i in 1...maxNumber {
                notes[row][col][i] = false
            }
            
            // Check for game completion
            if isSolved() {
                handleGameCompletion()
            }
        } else {
            // Handle invalid move
            DispatchQueue.main.async {
                self.lastInvalidCell = (row, col)
                self.showInvalidAnimation = true
                
                // Reset animation after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.showInvalidAnimation = false
                }
                
                self.notifyInvalidMove()
            }
        }
    }
    
    // Remaining methods from the previous implementation
    
    // Toggle a note in the selected cell
    func toggleNote(_ number: Int) {
        guard !isGenerating,
              let selectedCell = selectedCell,
              number <= maxNumber else { return }
        
        let row = selectedCell.row
        let col = selectedCell.col
        
        // Validate cell selection
        guard row >= 0 && row < boardSize.gridSize,
              col >= 0 && col < boardSize.gridSize,
              board[row][col] == 0,
              initialState[row][col] == 0 else { return }
        
        // Toggle the note
        notes[row][col][number].toggle()
    }
    
    // Check if the puzzle is solved
    func isSolved() -> Bool {
        // Check if all cells are filled
        for row in 0..<boardSize.gridSize {
            for col in 0..<boardSize.gridSize {
                if board[row][col] == 0 {
                    return false
                }
            }
        }
        return true
    }
    
    // Handle game completion
    private func handleGameCompletion() {
        isGamePaused = true
        // Could trigger celebration or next level logic
    }
    
    // Erase number from selected cell
    func eraseNumber() {
        guard !isGenerating,
              let selectedCell = selectedCell else { return }
        
        let row = selectedCell.row
        let col = selectedCell.col
        
        // Only erase user-entered numbers
        if initialState[row][col] == 0 && board[row][col] != 0 {
            board[row][col] = 0
        }
    }
    
    // Toggle notes mode
    func toggleNotesMode() {
        guard !isGenerating else { return }
        isNotesMode.toggle()
    }
    
    // Handle cell input based on notes mode
    func handleCellInput(_ number: Int) {
        guard !isGenerating else { return }
        
        if isNotesMode {
            toggleNote(number)
        } else {
            enterNumber(number)
        }
    }
    
    // Select a cell
    func selectCell(row: Int, col: Int) {
        guard !isGenerating,
              row >= 0 && row < boardSize.gridSize,
              col >= 0 && col < boardSize.gridSize else { return }
        
        selectedCell = (row, col)
    }
    
    // Reset game to initial state
    func resetGame() {
        board = initialState.map { $0 }
        selectedCell = nil
        isNotesMode = false
        initializeEmptyNotes()
        isGamePaused = false
    }
    
    // Reset with new board settings
    func resetWithNewSettings(boardSize: BoardSize, difficulty: Difficulty) {
        self.boardSize = boardSize
        self.difficulty = difficulty
        
        // Regenerate board
        let generator = SudokuGenerator(boardSize: boardSize, difficulty: difficulty)
        board = generator.getBoard()
        
        // Reset other states
        storeInitialState()
        selectedCell = nil
        isNotesMode = false
        initializeEmptyNotes()
        isGamePaused = false
    }
    
    // Get hint (very basic implementation)
    func getHint() {
        guard !isGenerating,
              let selectedCell = selectedCell else { return }
        
        let row = selectedCell.row
        let col = selectedCell.col
        
        // Only provide hints for empty cells
        guard board[row][col] == 0 && initialState[row][col] == 0 else { return }
        
        // Find a valid number for this cell
        for number in 1...maxNumber {
            if isValidMove(row: row, col: col, number: number) {
                board[row][col] = number
                break
            }
        }
    }
    
    // Notify about invalid move
    private func notifyInvalidMove() {
        NotificationCenter.default.post(name: NSNotification.Name("InvalidMove"), object: nil)
    }
}
