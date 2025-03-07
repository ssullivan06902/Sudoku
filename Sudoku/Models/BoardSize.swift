//
//  BoardSize.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/5/25.
//

import Foundation

enum BoardSize {
    case standard  // 9x9 grid (3x3 boxes)
    case medium    // 12x12 grid (modified to use 3x3 boxes for better visual grouping)
    case large     // 16x16 grid (4x4 boxes)
    
    var gridSize: Int {
        switch self {
        case .standard:
            return 9
        case .medium:
            return 12
        case .large:
            return 16
        }
    }
    
    var subGridSize: Int {
        switch self {
        case .standard:
            return 3  // 3×3 boxes
        case .medium:
            return 3  // For medium, use consistent 3×3 boxes for visual grouping
        case .large:
            return 4  // 4×4 boxes
        }
    }
    
    var subGridSizeRows: Int {
        switch self {
        case .standard:
            return 3  // 3×3 boxes
        case .medium:
            return 3  // Modified to use 3×3 boxes instead of 3×4
        case .large:
            return 4  // 4×4 boxes
        }
    }
    
    var subGridSizeCols: Int {
        switch self {
        case .standard:
            return 3  // 3×3 boxes
        case .medium:
            return 3  // Modified to use 3×3 boxes instead of 3×4
        case .large:
            return 4  // 4×4 boxes
        }
    }
    
    var description: String {
        switch self {
        case .standard:
            return "9×9"
        case .medium:
            return "12×12"
        case .large:
            return "16×16"
        }
    }
}
