//
//  Difficulty.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/5/25.
//

import Foundation

enum Difficulty: String, CaseIterable {
    case easy
    case medium
    case hard
    case expert
    
    var cellsToRemove: Double {
        switch self {
        case .easy:
            return 0.4  // Remove 40% of cells
        case .medium:
            return 0.5  // Remove 50% of cells
        case .hard:
            return 0.6  // Remove 60% of cells
        case .expert:
            return 0.7  // Remove 70% of cells
        }
    }
}
