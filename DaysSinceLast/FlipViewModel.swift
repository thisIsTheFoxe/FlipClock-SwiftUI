//
//  FlipViewModel.swift
//  DaysSinceLast
//
//  Created by Henrik Storch on 12.03.22.
//

import Combine
import SwiftUI

class FlipViewModel: ObservableObject, Identifiable {

    
    @Published var newValue: String?
    @Published var oldValue: String?

//    @Published var animateTop: Bool = false
//    @Published var animate: Bool = false
    
    @Published var percent: Double = 0
    
    @ObservedObject var parentModel: CounterViewModel

    public init(parentModel: CounterViewModel) {
        self.parentModel = parentModel
    }

    func setText(old: String?, new: String?) {
        oldValue = old
        self.newValue = new
        percent = 0
    }
    
    func updateTexts(old: String?, new: String?) {
        print(parentModel.animationSpeed.resetFlip, parentModel.animationSpeed.fallSpringFlip)
        guard old != oldValue, new != newValue else { return }
        percent = 0
        self.newValue = old
        withAnimation(.easeIn(duration: parentModel.animationSpeed.resetFlip)) {
            self.percent = 1
        }
        withAnimation(parentModel.animationSpeed.flipAnimation.delay(parentModel.animationSpeed.resetFlip)) {
            self.percent = 2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + parentModel.animationSpeed.resetFlip + parentModel.animationSpeed.fallSpringFlip) {
            self.setText(old: old, new: new)
        }
    }

}
