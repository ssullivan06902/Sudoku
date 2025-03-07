//
//  WinnerPopupView.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/7/25.
//

import SwiftUI

struct WinnerPopupView: View {
    @Binding var isShowing: Bool
    let elapsedTime: TimeInterval
    let mistakeCount: Int
    let boardSize: BoardSize
    let difficulty: Difficulty
    let onNewGame: () -> Void
    
    @State private var offset: CGFloat = 1000
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        dismissPopup()
                    }
                }
            
            // Confetti layer
            ConfettiView()
            
            // Main popup content
            VStack(spacing: 20) {
                // Title with trophy icon
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                    
                    Text("Puzzle Solved!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Image(systemName: "trophy.fill")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                }
                .padding(.top)
                
                // Game stats
                VStack(alignment: .leading, spacing: 10) {
                    statsRow(label: "Time", value: formatTime(elapsedTime))
                    statsRow(label: "Board Size", value: boardSize.description)
                    statsRow(label: "Difficulty", value: difficulty.rawValue.capitalized)
                    statsRow(label: "Mistakes", value: "\(mistakeCount)")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                
                // Message
                Text("Great job! You've solved the puzzle.")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Buttons
                HStack(spacing: 20) {
                    // Play again button
                    Button(action: {
                        dismissPopup()
                        onNewGame()
                    }) {
                        Text("New Game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 120)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    // Close button
                    Button(action: {
                        dismissPopup()
                    }) {
                        Text("Close")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 120)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.1, green: 0.2, blue: 0.5), Color(red: 0.2, green: 0.3, blue: 0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(radius: 20)
            .frame(maxWidth: 400)
            .offset(y: offset)
        }
        .onAppear {
            withAnimation(.spring()) {
                offset = 0
            }
        }
    }
    
    private func statsRow(label: String, value: String) -> some View {
        HStack {
            Text(label + ":")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundColor(.white)
                .fontWeight(.semibold)
            
            Spacer()
        }
    }
    
    private func dismissPopup() {
        withAnimation(.spring()) {
            offset = 1000
        }
        
        // Slightly delay changing the isShowing flag to allow animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct WinnerPopupView_Previews: PreviewProvider {
    static var previews: some View {
        WinnerPopupView(
            isShowing: .constant(true),
            elapsedTime: 325, // 5:25
            mistakeCount: 3,
            boardSize: .standard,
            difficulty: .medium,
            onNewGame: {}
        )
    }
}
