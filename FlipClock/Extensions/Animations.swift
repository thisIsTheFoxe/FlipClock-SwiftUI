import SwiftUI

enum AnimationTime: Int, CaseIterable, Equatable {
    var iconName: String {
        switch self {
        case .short:
            return "hare"
        case .medium:
            return "speedometer"
        case .long:
            return "tortoise"
        }
    }
    case short, medium, long
#if !os(tvOS)
    var flipPattern: HapticoPattern {
        switch self {
        case .short:
            return HapticoPattern(pattern: ".X")
        case .medium:
            return HapticoPattern(pattern: "o-O")
        case .long:
            return HapticoPattern(pattern: "o-*")
        }
    }

    var resetPattern: HapticoPattern {
        switch self {
        case .short:
            return HapticoPattern(pattern: "..X")
        case .medium:
            return HapticoPattern(pattern: "oooO")
        case .long:
            return HapticoPattern(pattern: "o-o-o-*")
        }
    }
#endif
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
            return 1.5
        }
    }

    var fullFlip: Double { halfFlip + fallSpringFlip }
}
