//
//  BoardView.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/5/25.
//

import SwiftUI

struct BoardView: View {
    @ObservedObject var game: SudokuGame
    
    var body: some View {
        VStack(spacing: 0) {
            // Create the grid
            VStack(spacing: dividerSpacing) {
                // For the 12x12 board, we need to create a 3×4 grid of boxes
                // For 9×9 and 16×16, we need square grids (3×3 or 4×4)
                ForEach(0..<boxCountRows, id: \.self) { boxRow in
                    HStack(spacing: dividerSpacing) {
                        ForEach(0..<boxCountCols, id: \.self) { boxCol in
                            NestedCellView(
                                game: game,
                                mainRow: boxRow,
                                mainCol: boxCol
                            )
                        }
                    }
                }
            }
            .padding(8)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary, lineWidth: 2)
            )
        }
        .padding()
    }
    
    // Number of boxes in each row (rows of boxes)
    private var boxCountRows: Int {
        return game.boardSize.subGridSizeRows
    }
    
    // Number of boxes in each column (columns of boxes)
    private var boxCountCols: Int {
        return game.boardSize.subGridSizeCols
    }
    
    // Calculate divider spacing to emphasize box boundaries
    private var dividerSpacing: CGFloat {
        return 2
    }
}

// Preview provider
struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(game: SudokuGame(boardSize: .standard))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
