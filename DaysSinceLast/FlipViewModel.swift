//
//  FlipViewModel.swift
//  DaysSinceLast
//
//  Created by Henrik Storch on 12.03.22.
//

import Combine
import SwiftUI

class FlipViewModel: ObservableObject, Identifiable {

    static var dummy = { FlipViewModel() }()
    var text: String? {
        didSet { updateTexts(old: oldValue, new: text, animared: true) }
    }

    @Published var newValue: String?
    @Published var oldValue: String?

    @Published var animateTop: Bool = false
    @Published var animateBottom: Bool = false
    
    @Published var percent: Double = 0

    func updateTexts(old: String?, new: String?, animared: Bool) {
        guard old != new else { return }
        oldValue = old
        animateTop = false
        animateBottom = false
        percent = 0
        guard animared else {
            self.newValue = new
            return
        }
        
        withAnimation(Animation.easeIn(duration: 0.2)) { [weak self] in
            self?.newValue = new
            self?.animateTop = true
        }

        withAnimation(Animation.easeOut(duration: 0.2).delay(0.2)) { [weak self] in
            self?.animateBottom = true
        }
    }

}
