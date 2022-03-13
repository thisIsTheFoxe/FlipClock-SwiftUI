//
//  Extensions.swift
//  DaysSinceLast
//
//  Created by Henrik Storch on 12.03.22.
//

import SwiftUI

extension Color {
    static var flipBackground: Color { Color(UIColor.label) }
    static var separator: Color { .gray }
    static var textColor: Color { Color(UIColor.systemBackground) }
}

enum AnimationTimes: Int, CaseIterable, Equatable {
    var title: String {
        switch self {
        case .short:
            return "Short"
        case .medium:
            return "Medium"
        case .long:
            return "Long"
        }
    }
    case short, medium, long
    
    var flipAnimation: Animation {
        switch self {
        case .short:
                return .spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0.3)
            
        case .medium:
                return .spring(response: 0.4, dampingFraction: 0.2, blendDuration: 0.5)
            
        case .long:
                return .spring(response: 0.5, dampingFraction: 0.15, blendDuration: 0.7)
        }
    }
    
    var halfFlip: Double {
        switch self {
        case .short:
            return 0.1
        case .medium:
            return 0.4
        case .long:
            return 0.75
        }
    }
    var resetFlip: Double {
        switch self {
        case .short:
            return 0.1
        case .medium:
            return 0.4
        case .long:
            return 1
        }
    }
    var fallSpringFlip: Double {
        switch self {
        case .short:
            return 0.5
        case .medium:
            return 1
        case .long:
            return 2
        }
    }
    
    var fullFlip: Double { halfFlip + fallSpringFlip }
}
