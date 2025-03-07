//
//  CellView.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/5/25.
//

import SwiftUI

struct CellView: View {
    @ObservedObject var game: SudokuGame
    let row: Int
    let col: Int
    
    @State private var isShaking = false
    
    var body: some View {
        // First, check if the indices are within bounds of the current board
        let isInBounds = row < game.board.count && col < (game.board.isEmpty ? 0 : game.board[0].count) &&
            row < game.initialState.count && col < (game.initialState.isEmpty ? 0 : game.initialState[0].count)
        
        // Use Group to handle conditional content while maintaining the View return type
        Group {
            if isInBounds {
                // Only access array elements if the indices are valid
                cellContent
            } else {
                // Show an empty placeholder if indices are out of bounds
                // This prevents crashes during board size transitions
                Color.clear
                    .frame(width: 1, height: 1)
            }
        }
    }
    
    // Extracted the cell content to a separate computed property for cleaner code
    private var cellContent: some View {
        let isSelected = game.selectedCell?.row == row && game.selectedCell?.col == col
        let value = game.board[row][col]
        let isInitial = game.initialState[row][col] != 0
        let isInvalid = game.lastInvalidCell?.row == row && game.lastInvalidCell?.col == col && game.showInvalidAnimation
        
        return Button(action: {
            game.selectCell(row: row, col: col)
        }) {
            ZStack {
                // Background with selection state
                Rectangle()
                    .fill(cellBackgroundColor(value: value, isInitial: isInitial, isSelected: isSelected))
                    .border(cellBorderColor, width: isSelected ? 2 : 0)
                
                // Cell content: either number or notes
                if value != 0 {
                    // Display the number - using black for all numbers
                    Text("\(value)")
                        .font(.system(size: fontSize))
                        .fontWeight(isInitial ? .bold : .regular)
                        .foregroundColor(.black) // Changed to black for all numbers
                } else {
                    // Display notes if present
                    NotesView(game: game, row: row, col: col)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .aspectRatio(1.0, contentMode: .fit)
        // Apply shake animation for invalid moves
        .modifier(ShakeEffect(animatableData: isInvalid ? 1 : 0))
        // Apply highlight flash for invalid cells
        .background(
            isInvalid ? Color.red.opacity(0.3) : Color.clear
        )
    }
    
    // Dynamic font size based on board size
    private var fontSize: CGFloat {
        let standardSize: CGFloat = 20
        
        if game.boardSize.gridSize <= 0 {
            return standardSize // Safeguard against zero or negative values
        }
        
        switch game.boardSize.gridSize {
        case 4: return standardSize * 1.5  // 4x4 board
        case 9: return standardSize        // 9x9 board
        case 12: return standardSize * 0.8 // 12x12 board
        case 16: return standardSize * 0.7 // 16x16 board
        default: return standardSize
        }
    }
    
    // Background color varies based on cell state - extracted as a method for safety
    private func cellBackgroundColor(value: Int, isInitial: Bool, isSelected: Bool) -> Color {
        // Highlight selected cell
        if isSelected {
            return Color.blue.opacity(0.3)
        }
        // Distinguish initial values
        else if isInitial {
            return Color.gray.opacity(0.15)
        }
        // Custom color for filled cells
        else if value != 0 {
            return Color.white
        }
        // Empty cells
        else {
            return Color.white.opacity(0.8)
        }
    }
    
    // Border color for selected cell
    private var cellBorderColor: Color {
        return Color.blue
    }
}

// View for displaying notes in a cell
struct NotesView: View {
    @ObservedObject var game: SudokuGame
    let row: Int
    let col: Int
    
    var body: some View {
        // Add safety check for bounds
        let isInBounds = row < game.notes.count &&
                         col < (game.notes.isEmpty ? 0 : game.notes[0].count) &&
                         game.boardSize.gridSize > 0
        
        if isInBounds {
            let boxSize = Int(sqrt(Double(game.boardSize.gridSize)))
            
            GeometryReader { geometry in
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: boxSize),
                    spacing: 1
                ) {
                    ForEach(1...game.boardSize.gridSize, id: \.self) { number in
                        if number < game.notes[row][col].count && game.notes[row][col][number] {
                            Text("\(number)")
                                .font(.system(size: notesFontSize(for: geometry.size, boxSize: boxSize)))
                                .foregroundColor(.gray) // Keeping notes gray for distinction
                        } else {
                            Text("")
                                .font(.system(size: notesFontSize(for: geometry.size, boxSize: boxSize)))
                        }
                    }
                }
                .padding(2)
            }
        } else {
            // Fallback for safety
            Color.clear
        }
    }
    
    // Calculate appropriate font size for notes based on cell size
    private func notesFontSize(for size: CGSize, boxSize: Int) -> CGFloat {
        let dimension = min(size.width, size.height)
        return dimension / CGFloat(boxSize + 1) * 0.7
    }
}

// Animation modifier for cell shake effect
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(animatableData * .pi * 10) * 5, y: 0))
    }
}

// Preview provider
struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        let game = SudokuGame()
        
        return VStack {
            // Preview a filled cell
            CellView(game: game, row: 0, col: 0)
                .frame(width: 50, height: 50)
            
            // Preview an empty cell
            CellView(game: game, row: 1, col: 1)
                .frame(width: 50, height: 50)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
