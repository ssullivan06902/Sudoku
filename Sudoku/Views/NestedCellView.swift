//
//  NestedCellView.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/5/25.
//

import SwiftUI

struct NestedCellView: View {
    @ObservedObject var game: SudokuGame
    let mainRow: Int
    let mainCol: Int
    
    var body: some View {
        // Get the number of rows and columns in each box
        let boxRows = getBoxRows()
        let boxCols = getBoxCols()
        
        // Safety check to ensure we're within bounds
        let isValidBox = mainRow < getNumBoxesInRow() && mainCol < getNumBoxesInCol()
        
        if isValidBox {
            VStack(spacing: 1) {
                ForEach(0..<boxRows, id: \.self) { subRow in
                    HStack(spacing: 1) {
                        ForEach(0..<boxCols, id: \.self) { subCol in
                            // Calculate the actual row and column in the full grid
                            let row = mainRow * boxRows + subRow
                            let col = mainCol * boxCols + subCol
                            
                            CellView(
                                game: game,
                                row: row,
                                col: col
                            )
                        }
                    }
                }
            }
            .background(Color.gray.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black, lineWidth: 2)  // Thick black border
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            // Placeholder for out-of-bounds boxes during transitions
            Color.clear
                .frame(width: 10, height: 10)
        }
    }
    
    // Get number of rows in each box
    private func getBoxRows() -> Int {
        switch game.boardSize.gridSize {
        case 9:  return 3  // 3×3 boxes for 9×9 board
        case 12: return 4  // 3×4 boxes for 12×12 board (3 rows of 4-cell-high boxes)
        case 16: return 4  // 4×4 boxes for 16×16 board
        default: return 3  // Default to 3 as a safety measure
        }
    }
    
    // Get number of columns in each box
    private func getBoxCols() -> Int {
        switch game.boardSize.gridSize {
        case 9:  return 3  // 3×3 boxes for 9×9 board
        case 12: return 3  // 3×4 boxes for 12×12 board (4 columns of 3-cell-wide boxes)
        case 16: return 4  // 4×4 boxes for 16×16 board
        default: return 3  // Default to 3 as a safety measure
        }
    }
    
    // Get number of boxes in each row of the grid
    private func getNumBoxesInRow() -> Int {
        switch game.boardSize.gridSize {
        case 9:  return 3  // 3 boxes per row for 9×9 board
        case 12: return 3  // 3 boxes per row for 12×12 board
        case 16: return 4  // 4 boxes per row for 16×16 board
        default: return 3  // Default to 3 as a safety measure
        }
    }
    
    // Get number of boxes in each column of the grid
    private func getNumBoxesInCol() -> Int {
        switch game.boardSize.gridSize {
        case 9:  return 3  // 3 boxes per column for 9×9 board
        case 12: return 4  // 4 boxes per column for 12×12 board
        case 16: return 4  // 4 boxes per column for 16×16 board
        default: return 3  // Default to 3 as a safety measure
        }
    }
}

// Preview provider
struct NestedCellView_Previews: PreviewProvider {
    static var previews: some View {
        NestedCellView(game: SudokuGame(), mainRow: 0, mainCol: 0)
            .previewLayout(.sizeThatFits)
            .frame(width: 150, height: 150)
            .padding()
    }
}
