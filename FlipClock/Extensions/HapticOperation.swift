// MIT Licensed
// Copyright (c) 2018 isapozhnik <sapozhnik.ivan@gmail.com>
// https://github.com/iSapozhnik/Haptico/

import UIKit

public class HapticoPattern {
    var pattern: String
    var delay: Double

    init(pattern: String, delay: Double = 0.02) {
        self.pattern = pattern
        self.delay = delay
    }

    static let test = HapticoPattern(pattern: "o-X-o-O-*-.", delay: 1)
}


class PatternEngine {
    private enum PatternChar: Character {
        case space = "-"
        case signalRigit = "X"
        case signalHeavy = "O"
        case signalMedium = "o"
        case signalLight = "*"
        case signalSoft = "."
    }

    var isFinished: Bool {
        return queue.operationCount == 0
    }

    lazy var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private var engine: HapticFeedbackNotificationEngine
    private var pauseDuration: TimeInterval

    init(hapticEngine: HapticFeedbackNotificationEngine, pauseDuration: TimeInterval = 0.11) {
        self.engine = hapticEngine
        self.pauseDuration = pauseDuration
    }

    func generate(pattern: HapticoPattern) {
        for pat in pattern.pattern.compactMap(PatternChar.init) {
            switch pat {
                
            case .space:
                queue.addOperation(PauseOperation(delay: pattern.delay))
            case .signalRigit:
                queue.addOperation(SignalOperation(hapticEngine: engine, impact: .rigid, pauseDuration: pauseDuration))
            case .signalHeavy:
                queue.addOperation(SignalOperation(hapticEngine: engine, impact: .heavy, pauseDuration: pauseDuration))
            case .signalMedium:
                queue.addOperation(SignalOperation(hapticEngine: engine, impact: .medium, pauseDuration: pauseDuration))
            case .signalLight:
                queue.addOperation(SignalOperation(hapticEngine: engine, impact: .light, pauseDuration: pauseDuration))
            case .signalSoft:
                queue.addOperation(SignalOperation(hapticEngine: engine, impact: .soft, pauseDuration: pauseDuration))
            }
        }
    }
}

class PauseOperation: Operation {
    private var delay: Double

    init(delay: Double) {
        self.delay = delay
    }

    override func main() {
        Thread.sleep(forTimeInterval: delay)
    }
}

class SignalOperation: Operation {
    weak var engine: HapticFeedbackNotificationEngine?
    private var impact: UIImpactFeedbackGenerator.FeedbackStyle
    private var pauseDuration: TimeInterval

    init(hapticEngine: HapticFeedbackNotificationEngine?, impact: UIImpactFeedbackGenerator.FeedbackStyle, pauseDuration: TimeInterval) {
        self.engine = hapticEngine
        self.impact = impact
        self.pauseDuration = pauseDuration
    }

    override func main() {
        guard #available(iOS 10, *) else { return }
        DispatchQueue.main.async {
            self.engine?.generate(self.impact)
        }
        Thread.sleep(forTimeInterval: pauseDuration)
    }
}

final class HapticFeedbackNotificationEngine {
    var logEnabled: Bool!

    @available(iOS 10.0, *)
    private var generator: UINotificationFeedbackGenerator {
        return UINotificationFeedbackGenerator()
    }

    @available(iOS 10.0, *)
    private var impactGenerator: (light: UIImpactFeedbackGenerator, medium: UIImpactFeedbackGenerator, heavy: UIImpactFeedbackGenerator, soft: UIImpactFeedbackGenerator, rigid: UIImpactFeedbackGenerator) {
        return (
            light: UIImpactFeedbackGenerator(style: .light),
            medium: UIImpactFeedbackGenerator(style: .medium),
            heavy: UIImpactFeedbackGenerator(style: .heavy),
            soft: UIImpactFeedbackGenerator(style: .soft),
            rigid: UIImpactFeedbackGenerator(style: .rigid)
        )
    }

    func prepare() throws {
        generator.prepare()
        impactGenerator.heavy.prepare()
        impactGenerator.medium.prepare()
        impactGenerator.light.prepare()
    }

    func generate(_ impact: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch impact {
        case .light:
            impactGenerator.light.impactOccurred()
        case .medium:
            impactGenerator.medium.impactOccurred()
        case .heavy:
            impactGenerator.heavy.impactOccurred()
        case .soft:
            impactGenerator.soft.impactOccurred()
        case .rigid:
            impactGenerator.rigid.impactOccurred()
        @unknown default: return
        }
    }
}
