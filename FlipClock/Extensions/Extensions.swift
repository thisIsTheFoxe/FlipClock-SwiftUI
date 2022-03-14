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

extension DateFormatter {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        return formatter
    }
}


extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#if swift(<5.1)
extension Strideable where Stride: SignedInteger {
    func clamped(to limits: CountableClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
#endif


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

extension UIWindow {
    public func showAlert(placeholder: String, currentText: String, primaryTitle: String, cancelTitle: String, primaryAction: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: primaryTitle, message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = currentText
            textField.becomeFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { textField.selectAll(nil) }
        }

        let primaryButton = UIAlertAction(title: primaryTitle, style: .default) { _ in
            guard let text = alertController.textFields?[0].text else { return }
            primaryAction(text)
        }

        let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)

        alertController.addAction(primaryButton)
        alertController.addAction(cancelButton)

        self.rootViewController?.present(alertController, animated: true)
    }
}

extension UIApplication {
    func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }
        .first?.windows.filter { $0.isKeyWindow }.first
    }
}
