//
//  ConfettiView.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/7/25.
//

import SwiftUI

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var timer: Timer?
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    let duration: TimeInterval = 3.0
    
    func startConfetti() {
        // Create initial confetti pieces
        confettiPieces = (0..<100).map { _ in
            let randomX = CGFloat.random(in: 0...1)
            let randomSize = CGFloat.random(in: 5...15)
            let randomColor = colors.randomElement() ?? .blue
            let randomRotation = Double.random(in: 0...360)
            let randomRotationSpeed = Double.random(in: -720...720)
            
            return ConfettiPiece(
                position: CGPoint(x: randomX, y: -0.1),
                size: randomSize,
                color: randomColor,
                rotation: randomRotation,
                rotationSpeed: randomRotationSpeed,
                speed: Double.random(in: 0.2...0.8)
            )
        }
        
        // Start animation timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            withAnimation(.linear(duration: 0.03)) {
                for i in 0..<confettiPieces.count {
                    confettiPieces[i].position.y += CGFloat(confettiPieces[i].speed) * 0.02
                    confettiPieces[i].rotation += confettiPieces[i].rotationSpeed * 0.01
                }
            }
        }
        
        // Stop confetti after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            timer?.invalidate()
            timer = nil
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces.indices, id: \.self) { index in
                    let piece = confettiPieces[index]
                    Rectangle()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.4)
                        .position(
                            x: piece.position.x * geometry.size.width,
                            y: piece.position.y * geometry.size.height
                        )
                        .rotationEffect(.degrees(piece.rotation))
                }
            }
        }
        .onAppear {
            startConfetti()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

struct ConfettiPiece {
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var rotation: Double
    var rotationSpeed: Double
    var speed: Double
}

struct ConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        ConfettiView()
            .frame(width: 300, height: 300)
            .background(Color.black.opacity(0.2))
    }
}
