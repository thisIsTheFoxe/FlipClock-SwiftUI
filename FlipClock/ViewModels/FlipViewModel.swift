import Combine
import SwiftUI

protocol FlipViewManager {
    var animationSpeed: AnimationTime { get }
    var base: Base { get }
}

class FlipViewModel<T: FlipViewManager & ObservableObject>: ObservableObject, Identifiable {
    @Published var newValue: String?
    @Published var oldValue: String?

    @Published var percent: Double = 0

    @ObservedObject var parentModel: T

    public init(parentModel: T) {
        self.parentModel = parentModel
    }

    /// (re)set the text without animation
    func setText(old: String?, new: String?) {
        oldValue = old
        self.newValue = new
        percent = 0
    }

    /// update the flipper where old is the new base and new is the next one
    func updateTexts(old: String?, new: String?) {
        guard old != oldValue || new != newValue else { return }
        self.newValue = old
        runAnimation(old: old, new: new)
    }

    /// complete the animation with the current values, and the completion values that are passed
    fileprivate func runAnimation(old: String?, new: String?) {
        percent = 0
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
