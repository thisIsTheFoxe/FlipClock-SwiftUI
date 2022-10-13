import SwiftUI

extension Base {
    func character(for value: Int) -> String {
        if self == .doz, value == 10 {
            return "X"
        } else if self == .doz, value == 11 {
            return "E"
        } else {
            return String(value, radix: rawValue, uppercase: true)
        }
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
