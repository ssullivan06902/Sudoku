//
//  ControlPanelView.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/5/25.
//

import SwiftUI

struct ControlPanelView: View {
    @ObservedObject var game: SudokuGame
    
    // Get the formatted time and mistake count from ContentView
    var formattedTime: String
    var mistakes: Int
    
    // Functions for controlling the game
    var onTogglePause: () -> Void
    var onReset: () -> Void
    var onGetHint: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                // Timer display
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text(formattedTime)
                        .font(.title2)
                        .monospacedDigit()
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Mistake counter
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text("\(mistakes)")
                        .font(.title2)
                        .monospacedDigit()
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            HStack(spacing: 20) {
                // Pause/Resume button
                Button(action: {
                    onTogglePause()
                }) {
                    Image(systemName: game.isGamePaused ? "play.fill" : "pause.fill")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(Circle())
                }
                
                // Reset button
                Button(action: {
                    onReset()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Circle())
                }
                
                // Hint button
                Button(action: {
                    onGetHint()
                }) {
                    Image(systemName: "lightbulb")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(Color.yellow.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ControlPanelView_Previews: PreviewProvider {
    static var previews: some View {
        ControlPanelView(
            game: SudokuGame(),
            formattedTime: "00:00",
            mistakes: 0,
            onTogglePause: {},
            onReset: {},
            onGetHint: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
