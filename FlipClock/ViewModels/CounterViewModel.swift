import SwiftUI
import WidgetKit

extension UserDefaults {
    static let group = UserDefaults(suiteName: "group.me.thisisthefoxe.DaysSinceLast")!
}

class CounterViewModel: ObservableObject, FlipViewManager {
    var patternEngine = PatternEngine(hapticEngine: HapticFeedbackNotificationEngine())
    @Published var daysSince: Int {
        didSet {
            UserDefaults.group.set(daysSince, forKey: "CounterViewModel.daysSince")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    @Published var inCloseAnimation = false

    @Published var animationSpeed: AnimationTime {
        didSet {
            UserDefaults.group.set(animationSpeed.rawValue, forKey: "CounterViewModel.animationSpeed")
        }
    }

    @Published var base: Base {
        didSet {
            UserDefaults.group.set(base.rawValue, forKey: "CounterViewModel.base")
            refresh()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func numberOfUpdatesNeeded(for newDaysSince: Int) -> Int {
        var result = 1
        guard newDaysSince != 0 else { return result }
        while (newDaysSince) % Int(pow(Double(base.rawValue), Double(result))) == 0, result < digits {
            result += 1
        }
        return result
    }

    @Published var digits: Int {
        didSet {
            UserDefaults.group.set(digits, forKey: "CounterViewModel.digits")
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
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private(set) var flipViewModels: [FlipViewModel<CounterViewModel>] = []

    @Published var description: String {
        didSet {
            UserDefaults.group.set(description, forKey: "CounterViewModel.description")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    static func preview(digits: Int, count: Int) -> CounterViewModel {
        let model = CounterViewModel()
        model.digits = digits
        model.daysSince = count
        return model
    }
    
    init() {
        if UserDefaults.group.bool(forKey: "didSave") {
            daysSince = UserDefaults.group.integer(forKey: "CounterViewModel.daysSince")
            digits = UserDefaults.group.integer(forKey: "CounterViewModel.digits")
            description = UserDefaults.group.string(forKey: "CounterViewModel.description") ?? "Days since last accident"
            let baseValue = UserDefaults.group.integer(forKey: "CounterViewModel.base")
            base = Base(rawValue: baseValue) ?? .dec
            let speedRawValue = UserDefaults.group.integer(forKey: "CounterViewModel.animationSpeed")
            animationSpeed = AnimationTime(rawValue: speedRawValue) ?? .long
        } else {
            animationSpeed = .long
            base = .dec
            daysSince = 0
            digits = 5
            description = "Days since last accident"

            UserDefaults.group.set(animationSpeed.rawValue, forKey: "CounterViewModel.animationSpeed")
            UserDefaults.group.set(base.rawValue, forKey: "CounterViewModel.base")
            UserDefaults.group.set(daysSince, forKey: "CounterViewModel.daysSince")
            UserDefaults.group.set(digits, forKey: "CounterViewModel.digits")
            UserDefaults.group.set(description, forKey: "CounterViewModel.description")
            UserDefaults.group.set(true, forKey: "didSave")
        }
        initModels()
    }

    fileprivate func initModels() {
        flipViewModels.removeAll()
        for ix in 0..<digits {
            let digitAtIx = (daysSince / Int(pow(Double(base.rawValue), Double(ix)))) % base.rawValue
            let nextDigit = (digitAtIx + 1) % base.rawValue
            let newModel = FlipViewModel(parentModel: self)
            newModel.setText(old: base.character(for: digitAtIx), new: base.character(for: nextDigit))
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
    
    func refresh() {
        inCloseAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.fullFlip) { [self] in
            daysSince = daysSince % Int(pow(Double(base.rawValue), Double(digits)))
            for ix in 0..<digits {
                let digitAtIx = (daysSince / Int(pow(Double(base.rawValue), Double(ix)))) % base.rawValue
                let nextDigit = (digitAtIx + 1) % base.rawValue
                flipViewModels[ix].updateTexts(old: base.character(for: digitAtIx), new: base.character(for: nextDigit))
            }
            inCloseAnimation = false
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
                let digitAtIx = (daysSince / Int(pow(Double(base.rawValue), Double(ix)))) % base.rawValue
                let nextDigit = (digitAtIx + 1) % base.rawValue
                flipViewModels[ix].setText(old: base.character(for: digitAtIx), new: base.character(for: nextDigit))
            }
            inCloseAnimation = false
        }
    }
}
