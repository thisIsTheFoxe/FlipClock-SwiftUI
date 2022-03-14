import SwiftUI

class CounterViewModel: ObservableObject, FlipViewManager {
    var patternEngine = PatternEngine(hapticEngine: HapticFeedbackNotificationEngine())
    @Published var daysSince = 0 {
        didSet {
            UserDefaults.standard.set(daysSince, forKey: "CounterViewModel.daysSince")
        }
    }

    @Published var inCloseAnimation = false
    
    @Published var animationSpeed: AnimationTime = .long
    
    func numberOfUpdatesNeeded(for newDaysSince: Int) -> Int {
        var result = 1
        guard newDaysSince != 0 else { return result }
        while (newDaysSince) % Int(pow(Double(10), Double(result))) == 0, result < digits {
            result += 1
        }
        return result

    }
    @Published var digits: Int = 5 {
        didSet {
            UserDefaults.standard.set(digits, forKey: "CounterViewModel.digits")
            if digits == flipViewModels.count + 1 {
                self.inCloseAnimation = true
                let newModel = FlipViewModel(parentModel: self)
                flipViewModels.append(newModel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    newModel.updateTexts(old: "0", new: "1")
                }
                completeAnimation(isReset: false)
            } else if digits == flipViewModels.count - 1 {
                flipViewModels.removeLast()
            } else { initModels() }
        }
    }
    private(set) var flipViewModels: [FlipViewModel<CounterViewModel>] = []
    @Published var description: String = "Days since last accident" {
        didSet {
            UserDefaults.standard.set(description, forKey: "CounterViewModel.description")
        }
    }
    init() {
        if UserDefaults.standard.bool(forKey: "didSave") {
            daysSince = UserDefaults.standard.integer(forKey: "CounterViewModel.daysSince")
            digits = UserDefaults.standard.integer(forKey: "CounterViewModel.digits")
            if let desc = UserDefaults.standard.string(forKey: "CounterViewModel.description") {
                description = desc
            }
            let speedRawValue = UserDefaults.standard.integer(forKey: "CounterViewModel.animationSpeed")
            if let speed = AnimationTime(rawValue: speedRawValue) {
                animationSpeed = speed
            }
        } else {
            initModels()
            UserDefaults.standard.set(animationSpeed.rawValue, forKey: "CounterViewModel.animationSpeed")
            UserDefaults.standard.set(daysSince, forKey: "CounterViewModel.daysSince")
            UserDefaults.standard.set(digits, forKey: "CounterViewModel.digits")
            UserDefaults.standard.set(description, forKey: "CounterViewModel.description")
            UserDefaults.standard.set(true, forKey: "didSave")
        }
    }

    fileprivate func initModels() {
        flipViewModels.removeAll()
        for ix in 0..<digits {
            let digitAtIx = (daysSince / Int(pow(Double(10), Double(ix)))) % 10
            let nextDigit = (digitAtIx + 1) % 10
            let newModel = FlipViewModel(parentModel: self)
            newModel.setText(old: "\(digitAtIx)", new: "\(nextDigit)")
            flipViewModels.append(newModel)
        }
    }

    fileprivate func completeAnimation(isReset: Bool) {
        let delay: Double
        if isReset {
            delay = animationSpeed.resetFlip + animationSpeed.fallSpringFlip
            DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.resetFlip) {
                self.patternEngine.generate(pattern: self.animationSpeed.resetPattern)
            }
        } else {
            delay = animationSpeed.halfFlip + animationSpeed.fallSpringFlip
            DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.halfFlip) {
                self.patternEngine.generate(pattern: self.animationSpeed.flipPattern)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            self.inCloseAnimation = false
        }
    }
    
    func updatePercent(_ percent: Double) {
        for ix in 0..<numberOfUpdatesNeeded(for: daysSince + 1) {
            flipViewModels[ix].percent = percent
        }
    }
    
    func resetFlips() {
        guard !inCloseAnimation, daysSince != 0 else { return }
        inCloseAnimation = true
        daysSince = 0
        for model in flipViewModels {
            model.updateTexts(old: "0", new: "1")
        }
        completeAnimation(isReset: true)
    }
    
    func increase() {
        guard !inCloseAnimation else { return }
        inCloseAnimation = true
        withAnimation(.easeIn(duration: animationSpeed.halfFlip)) {
            updatePercent(1)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.halfFlip) {
            self.complete()
            self.patternEngine.generate(pattern: self.animationSpeed.flipPattern)
        }
    }
    
    func complete() {
        inCloseAnimation = true
        withAnimation(animationSpeed.flipAnimation) {
            updatePercent(2)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.fallSpringFlip) { [self] in
            daysSince += 1
            daysSince = daysSince % Int(pow(Double(10), Double(digits)))
            for ix in 0..<numberOfUpdatesNeeded(for: daysSince) {
                let digitAtIx = (daysSince / Int(pow(Double(10), Double(ix)))) % 10
                let nextDigit = (digitAtIx + 1) % 10
                flipViewModels[ix].setText(old: "\(digitAtIx)", new: "\(nextDigit)")
            }
            inCloseAnimation = false
        }
    }
}
