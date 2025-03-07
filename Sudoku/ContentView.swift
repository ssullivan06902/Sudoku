//
//  ContentView.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var game = SudokuGame()
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var mistakeCount: Int = 0
    @State private var showWinnerPopup: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // The blue bar is now designed to sit right below the title bar
            // 1. Medium-dark blue bar at the top with game name and controls
            ZStack {
                // Background color
                Color(red: 0.1, green: 0.2, blue: 0.5)
                    .edgesIgnoringSafeArea(.top)
                
                HStack {
                    // Left side - New Game button and control buttons
                    HStack(spacing: 8) {
                        // New Game button
                        Button(action: {
                            startNewGame()
                        }) {
                            Text("New Game")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(Color(red: 0.2, green: 0.3, blue: 0.6))
                                .cornerRadius(6)
                        }
                        
                        // Control buttons
                        HStack(spacing: 8) {
                            // Pause/Resume button
                            Button(action: {
                                togglePause()
                            }) {
                                Image(systemName: game.isGamePaused ? "play.fill" : "pause.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            
                            // Reset button
                            Button(action: {
                                resetGame()
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            
                            // Hint button
                            Button(action: {
                                getHint()
                            }) {
                                Image(systemName: "lightbulb")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.leading, 12)
                    
                    Spacer()
                    
                    // Right side - timer and error count
                    VStack(alignment: .trailing, spacing: 2) {
                        // Timer display
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .foregroundColor(.white)
                            Text(formatTime(elapsedTime))
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                                .monospacedDigit()
                        }
                        
                        // Mistake counter
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.white)
                            Text("\(mistakeCount)")
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                                .monospacedDigit()
                        }
                    }
                    .padding(.trailing, 16)
                }
                
                // Center - Game name (positioned to align with board center)
                Text("SUDOKU")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(height: 55)
            
            // Board Size & Difficulty Pickers
            HStack(spacing: 8) {
                // Board Size Picker
                Menu {
                    Button("9×9", action: { changeBoardSize(.standard) })
                    Button("12×12", action: { changeBoardSize(.medium) })
                    Button("16×16", action: { changeBoardSize(.large) })
                } label: {
                    HStack {
                        Text("Size: \(game.boardSize.description)")
                            .fontWeight(.medium)
                            .font(.subheadline)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
                }
                
                // Difficulty Picker
                Menu {
                    ForEach(Difficulty.allCases, id: \.self) { level in
                        Button(level.rawValue.capitalized, action: { changeDifficulty(level) })
                    }
                } label: {
                    HStack {
                        Text("Difficulty: \(game.difficulty.rawValue.capitalized)")
                            .fontWeight(.medium)
                            .font(.subheadline)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
                }
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            .padding(.bottom, 4)
            
            // Game board - with special scaling for 12x12 board
            BoardView(game: game)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxHeight: getScreenHeight() * 0.6)
                .scaleEffect(game.boardSize == .medium ? 1.2 : 1.0) // Zoom in for 12x12 board
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            
            // Number pad moved to where the New Game button was
            NumberPadView(game: game)
                .padding(.horizontal, 8)
                .padding(.bottom, 20) // Added buffer space below the number buttons
        }
        .onAppear {
            startTimer()
            setupNotifications()
        }
        .onDisappear {
            stopTimer()
        }
        // Show winner popup when needed
        .overlay(
            Group {
                if showWinnerPopup {
                    WinnerPopupView(
                        isShowing: $showWinnerPopup,
                        elapsedTime: elapsedTime,
                        mistakeCount: mistakeCount,
                        boardSize: game.boardSize,
                        difficulty: game.difficulty,
                        onNewGame: startNewGame
                    )
                    .onDisappear {
                        // Mark puzzle as not solved to prevent popup from reappearing
                        if game.isSolved() {
                            game.markGameComplete()
                        }
                    }
                }
            }
        )
    }
    
    // Start the game timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if !game.isGamePaused {
                elapsedTime += 1
            }
            
            // Check if game is complete after each second
            checkWinCondition()
        }
    }
    
    // Stop the timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Format elapsed time as MM:SS
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Toggle pause state
    private func togglePause() {
        game.togglePause()
    }
    
    // Reset the game
    private func resetGame() {
        elapsedTime = 0
        mistakeCount = 0
        game.resetGame()
    }
    
    // Start a new game
    private func startNewGame() {
        elapsedTime = 0
        mistakeCount = 0
        showWinnerPopup = false
        game.resetWithNewSettings(boardSize: game.boardSize, difficulty: game.difficulty)
    }
    
    // Change board size
    private func changeBoardSize(_ newSize: BoardSize) {
        guard newSize != game.boardSize else { return }
        elapsedTime = 0
        mistakeCount = 0
        showWinnerPopup = false
        game.resetWithNewSettings(boardSize: newSize, difficulty: game.difficulty)
    }
    
    // Change difficulty
    private func changeDifficulty(_ newDifficulty: Difficulty) {
        guard newDifficulty != game.difficulty else { return }
        elapsedTime = 0
        mistakeCount = 0
        showWinnerPopup = false
        game.resetWithNewSettings(boardSize: game.boardSize, difficulty: newDifficulty)
    }
    
    // Get a hint
    private func getHint() {
        game.getHint()
    }
    
    // Check if the game is won
    private func checkWinCondition() {
        if game.isSolvedAndNotCelebrated() && !showWinnerPopup {
            // Only show popup if not already showing and not when initializing a new game
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showWinnerPopup = true
                game.togglePause() // Pause the game
                timer?.invalidate() // Stop the timer when game is won
                game.markGameComplete() // Mark as celebrated
            }
        }
    }
    
    // Get screen height in a SwiftUI compatible way
    private func getScreenHeight() -> CGFloat {
        #if os(iOS)
        return UIScreen.main.bounds.height
        #elseif os(macOS)
        return NSScreen.main?.frame.height ?? 800
        #else
        return 800 // Default fallback
        #endif
    }
    
    // Setup notification observers
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("InvalidMove"),
            object: nil,
            queue: .main
        ) { _ in
            mistakeCount += 1
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
