//
//  NumberPadView.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/5/25.
//

import SwiftUI

struct NumberPadView: View {
    @ObservedObject var game: SudokuGame
    
    var body: some View {
        VStack(spacing: 12) {
            // Label that changes based on notes mode
            Text(game.isNotesMode ? "Notes Mode" : "Enter Number")
                .font(.headline)
                .padding(.top, 8)
            
            // Standard number buttons 1-9 in a single row
            HStack(spacing: 10) {
                // Display numbers 1-9 for all board sizes
                ForEach(1...9, id: \.self) { number in
                    Button(action: {
                        game.handleCellInput(number)
                    }) {
                        Text("\(number)")
                            .font(.title2)
                            .fontWeight(.medium)
                            .frame(width: 50, height: 50)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle()) // Changed from RoundedRectangle to Circle
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Add a separator between number buttons and control buttons
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 36)
                    .padding(.horizontal, 4)
                
                // Notes toggle button
                Button(action: {
                    game.toggleNotesMode()
                }) {
                    Image(systemName: "pencil")
                        .font(.title2)
                        .frame(width: 50, height: 50)
                        .background(game.isNotesMode ? Color.green.opacity(0.3) : Color.green.opacity(0.1))
                        .clipShape(Circle()) // Changed from RoundedRectangle to Circle
                }
                .buttonStyle(PlainButtonStyle())
                
                // Erase button
                Button(action: {
                    game.eraseNumber()
                }) {
                    Image(systemName: "eraser")
                        .font(.title2)
                        .frame(width: 50, height: 50)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle()) // Changed from RoundedRectangle to Circle
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            
            // Additional buttons 10-12 for medium (12×12) board
            if game.boardSize == .medium {
                HStack(spacing: 10) {
                    Spacer()
                    
                    // Display numbers 10-12 for 12×12 board
                    ForEach(10...12, id: \.self) { number in
                        Button(action: {
                            game.handleCellInput(number)
                        }) {
                            Text("\(number)")
                                .font(.title2)
                                .fontWeight(.medium)
                                .frame(width: 50, height: 50)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle()) // Changed from RoundedRectangle to Circle
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 5)
                .transition(.opacity)
                .animation(.easeInOut, value: game.boardSize)
            }
            
            // Additional buttons 10-16 for large (16×16) board
            if game.boardSize == .large {
                HStack(spacing: 10) {
                    Spacer()
                    
                    // Display numbers 10-16 in a single row for 16×16 board
                    ForEach(10...16, id: \.self) { number in
                        Button(action: {
                            game.handleCellInput(number)
                        }) {
                            Text("\(number)")
                                .font(.title2)
                                .fontWeight(.medium)
                                .frame(width: 50, height: 50)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle()) // Changed from RoundedRectangle to Circle
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 5)
                .transition(.opacity)
                .animation(.easeInOut, value: game.boardSize)
            }
        }
        .padding(.bottom, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .animation(.easeInOut, value: game.isNotesMode)
    }
}

struct NumberPadView_Previews: PreviewProvider {
    static var previews: some View {
        NumberPadView(game: SudokuGame())
            .previewLayout(.sizeThatFits)
    }
}
