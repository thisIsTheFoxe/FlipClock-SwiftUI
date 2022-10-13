//
//  UIApp.swift
//  FlipClock
//
//  Created by Henrik Storch on 15.09.22.
//  Copyright © 2022 Maciej Gomółka. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }
        .first?.windows.filter { $0.isKeyWindow }.first
    }
}
