//
//  SudokuGenerator.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/5/25.
//

import Foundation

class SudokuGenerator {
    private var boardSize: BoardSize
    private var difficulty: Difficulty
    
    init(boardSize: BoardSize, difficulty: Difficulty = .easy) {
        self.boardSize = boardSize
        self.difficulty = difficulty
    }
    
    func getBoard() -> [[Int]] {
        // First, get a base board for the selected size
        var board: [[Int]]
        switch boardSize {
        case .standard:
            board = getRandomStandardBoard()
        case .medium:
            board = getRandomMediumBoard()
        case .large:
            board = getRandomLargeBoard()
        }
        
        // Then apply difficulty by removing more numbers
        applyDifficulty(to: &board)
        
        return board
    }
    
    // Get a random 9×9 board
    private func getRandomStandardBoard() -> [[Int]] {
        // Generate a solved standard board
        var board = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        
        // Use recursive backtracking to fill the board
        let _ = fillBoard(board: &board, row: 0, col: 0)
        
        // Apply random transformations to create variations
        applyRandomTransformations(board: &board)
        
        return board
    }
    
    // Get a random 12×12 board
    private func getRandomMediumBoard() -> [[Int]] {
        // For a 12×12 board, we'll create a more robust generation method
        var board = Array(repeating: Array(repeating: 0, count: 12), count: 12)
        
        // Create subgrid groups for a 12x12 board (3x4 subgrids)
        let subgridGroups: [[Int]] = [
            [1, 2, 3, 4, 5, 6],
            [7, 8, 9, 10, 11, 12]
        ]
        
        // Fill each 3x4 subgrid
        for boxRow in 0..<4 {
            for boxCol in 0..<3 {
                // Select the appropriate number set
                let numberSet = subgridGroups[boxCol % 2]
                
                // Prepare this specific 3x4 subgrid
                let startRow = boxRow * 3
                let startCol = boxCol * 4
                
                // Shuffle the number set
                var shuffledSet = numberSet.shuffled()
                
                // Fill the subgrid
                for subRow in 0..<3 {
                    for subCol in 0..<4 {
                        let row = startRow + subRow
                        let col = startCol + subCol
                        
                        // Ensure we have a number to place
                        board[row][col] = shuffledSet.popLast() ?? 0
                    }
                }
            }
        }
        
        return board
    }
    
    // Get a random 16×16 board
    private func getRandomLargeBoard() -> [[Int]] {
        // For a 16×16 board, create a more robust generation method
        var board = Array(repeating: Array(repeating: 0, count: 16), count: 16)
        
        // Create subgrid groups for a 16x16 board (4x4 subgrids)
        let subgridGroups: [[Int]] = [
            [1, 2, 3, 4],
            [5, 6, 7, 8],
            [9, 10, 11, 12],
            [13, 14, 15, 16]
        ]
        
        // Fill each 4x4 subgrid
        for boxRow in 0..<4 {
            for boxCol in 0..<4 {
                // Select the appropriate number set
                let numberSet = subgridGroups[boxCol]
                
                // Prepare this specific 4x4 subgrid
                let startRow = boxRow * 4
                let startCol = boxCol * 4
                
                // Shuffle the number set
                var shuffledSet = numberSet.shuffled()
                
                // Fill the subgrid
                for subRow in 0..<4 {
                    for subCol in 0..<4 {
                        let row = startRow + subRow
                        let col = startCol + subCol
                        
                        // Ensure we have a number to place
                        board[row][col] = shuffledSet.popLast() ?? 0
                    }
                }
            }
        }
        
        return board
    }
    
    // Recursive backtracking algorithm to fill a Sudoku board
    private func fillBoard(board: inout [[Int]], row: Int, col: Int) -> Bool {
        let gridSize = board.count
        
        // If we've filled all cells, we're done
        if row >= gridSize {
            return true
        }
        
        // Move to the next cell
        let nextRow = (col + 1 >= gridSize) ? row + 1 : row
        let nextCol = (col + 1 >= gridSize) ? 0 : col + 1
        
        // If this cell already has a value, move to the next cell
        if board[row][col] != 0 {
            return fillBoard(board: &board, row: nextRow, col: nextCol)
        }
        
        // Try each number 1-9 in a random order
        let numbers = Array(1...9).shuffled()
        for num in numbers {
            // Check if this number is valid in this cell
            if isValid(board: board, row: row, col: col, value: num) {
                // Place the number and continue
                board[row][col] = num
                
                // Recursively fill the rest of the board
                if fillBoard(board: &board, row: nextRow, col: nextCol) {
                    return true
                }
                
                // If we couldn't complete the board, backtrack
                board[row][col] = 0
            }
        }
        
        // If no number worked, backtrack
        return false
    }
    
    // Check if a number is valid for a cell
    private func isValid(board: [[Int]], row: Int, col: Int, value: Int) -> Bool {
        let gridSize = board.count
        
        // Check row
        for c in 0..<gridSize {
            if board[row][c] == value {
                return false
            }
        }
        
        // Check column
        for r in 0..<gridSize {
            if board[r][col] == value {
                return false
            }
        }
        
        // Check box (sub-grid)
        let boxSize = Int(sqrt(Double(gridSize)))
        let boxRow = (row / boxSize) * boxSize
        let boxCol = (col / boxSize) * boxSize
        
        for r in 0..<boxSize {
            for c in 0..<boxSize {
                if board[boxRow + r][boxCol + c] == value {
                    return false
                }
            }
        }
        
        return true
    }
    
    // Apply random transformations to create variations of the same board
    private func applyRandomTransformations(board: inout [[Int]]) {
        // Get the number of boxes in the grid
        let boxSizeRows = boardSize.subGridSizeRows
        let boxSizeCols = boardSize.subGridSizeCols
        let numBoxesRow = boardSize.gridSize / boxSizeRows
        let numBoxesCol = boardSize.gridSize / boxSizeCols
        
        // Apply several random transformations
        for _ in 0..<5 {
            let transformation = Int.random(in: 0..<4)
            
            switch transformation {
            case 0:
                // Swap two rows within the same box band
                let boxBand = Int.random(in: 0..<numBoxesRow)
                let rowInBox1 = Int.random(in: 0..<boxSizeRows)
                let rowInBox2 = Int.random(in: 0..<boxSizeRows)
                swapRows(board: &board, row1: boxBand * boxSizeRows + rowInBox1, row2: boxBand * boxSizeRows + rowInBox2)
                
            case 1:
                // Swap two columns within the same box band
                let boxBand = Int.random(in: 0..<numBoxesCol)
                let colInBox1 = Int.random(in: 0..<boxSizeCols)
                let colInBox2 = Int.random(in: 0..<boxSizeCols)
                swapColumns(board: &board, col1: boxBand * boxSizeCols + colInBox1, col2: boxBand * boxSizeCols + colInBox2)
                
            case 2:
                // Swap two box bands (rows)
                if numBoxesRow >= 2 {
                    let band1 = Int.random(in: 0..<numBoxesRow)
                    let band2 = Int.random(in: 0..<numBoxesRow)
                    if band1 != band2 {
                        swapBoxBandsRows(board: &board, band1: band1, band2: band2)
                    }
                }
                
            case 3:
                // Swap two box bands (columns)
                if numBoxesCol >= 2 {
                    let band1 = Int.random(in: 0..<numBoxesCol)
                    let band2 = Int.random(in: 0..<numBoxesCol)
                    if band1 != band2 {
                        swapBoxBandsColumns(board: &board, band1: band1, band2: band2)
                    }
                }
                
            default:
                break
            }
        }
    }
    
    // Swap two rows
    private func swapRows(board: inout [[Int]], row1: Int, row2: Int) {
        let temp = board[row1]
        board[row1] = board[row2]
        board[row2] = temp
    }
    
    // Swap two columns
    private func swapColumns(board: inout [[Int]], col1: Int, col2: Int) {
        for row in 0..<board.count {
            let temp = board[row][col1]
            board[row][col1] = board[row][col2]
            board[row][col2] = temp
        }
    }
    
    // Swap two box bands (rows)
    private func swapBoxBandsRows(board: inout [[Int]], band1: Int, band2: Int) {
        let boxSize = boardSize.subGridSizeRows
        
        for i in 0..<boxSize {
            swapRows(board: &board, row1: band1 * boxSize + i, row2: band2 * boxSize + i)
        }
    }
    
    // Swap two box bands (columns)
    private func swapBoxBandsColumns(board: inout [[Int]], band1: Int, band2: Int) {
        let boxSize = boardSize.subGridSizeCols
        
        for i in 0..<boxSize {
            swapColumns(board: &board, col1: band1 * boxSize + i, col2: band2 * boxSize + i)
        }
    }
    
    // Apply difficulty by removing numbers
    private func applyDifficulty(to board: inout [[Int]]) {
        // Determine how many cells to remove based on difficulty
        let totalCells = boardSize.gridSize * boardSize.gridSize
        let baseRemovalPercentage: Double
        
        switch difficulty {
        case .easy:
            baseRemovalPercentage = 0.4  // Remove 40% of cells
        case .medium:
            baseRemovalPercentage = 0.5  // Remove 50% of cells
        case .hard:
            baseRemovalPercentage = 0.6  // Remove 60% of cells
        case .expert:
            baseRemovalPercentage = 0.7  // Remove 70% of cells
        }
        
        // Adjust for board size
        let adjustedRemovalPercentage: Double
        switch boardSize {
        case .standard:
            adjustedRemovalPercentage = baseRemovalPercentage
        case .medium:
            adjustedRemovalPercentage = baseRemovalPercentage + 0.05
        case .large:
            adjustedRemovalPercentage = baseRemovalPercentage + 0.1
        }
        
        let cellsToRemove = Int(Double(totalCells) * adjustedRemovalPercentage)
        
        // Get all cell positions
        var positions: [(row: Int, col: Int)] = []
        for row in 0..<boardSize.gridSize {
            for col in 0..<boardSize.gridSize {
                positions.append((row, col))
            }
        }
        
        // Shuffle positions to randomize removal
        positions.shuffle()
        
        // Remove cells
        var removed = 0
        
        for position in positions {
            let row = position.row
            let col = position.col
            
            // Save original value (unused variable warning fixed by using _)
            let _ = board[row][col]
            board[row][col] = 0
            
            // Check if we've removed enough cells
            removed += 1
            if removed >= cellsToRemove {
                break
            }
        }
        
        print("Created puzzle with \(removed) cells removed")
    }
}
