//
//  ContentView.swift
//  DaysSinceLast
//
//  Created by Henrik Storch on 12.03.22.
//

import SwiftUI

import Foundation
import Combine

class CounterViewModel: ObservableObject {
    @Published var daysSince = 98 {
        didSet {
            UserDefaults.standard.set(daysSince, forKey: "CounterViewModel.daysSince")
        }
    }
    var inCloseAniation = false
    
    @Published var animationSpeed: AnimationTimes = .long
    
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
                self.inCloseAniation = true
                let newModel = FlipViewModel(parentModel: self)
                flipViewModels.append(newModel)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    newModel.updateTexts(old: "0", new: "1")
                }
                completeAnimation(after: animationSpeed.fullFlip)
                
            } else if digits == flipViewModels.count - 1 {
                flipViewModels.removeLast()
            } else { initModels() }
        }
    }
    private(set) var flipViewModels: [FlipViewModel] = []

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
    
    init() {
        if UserDefaults.standard.bool(forKey: "didSave") {
//            daysSince = UserDefaults.standard.integer(forKey: "CounterViewModel.daysSince")
            digits = UserDefaults.standard.integer(forKey: "CounterViewModel.digits")
            let speedRawValue = UserDefaults.standard.integer(forKey: "CounterViewModel.animationSpeed")
            if let speed = AnimationTimes(rawValue: speedRawValue) {
                animationSpeed = speed
            }
        } else {
            initModels()
            UserDefaults.standard.set(animationSpeed.rawValue, forKey: "CounterViewModel.animationSpeed")
            UserDefaults.standard.set(daysSince, forKey: "CounterViewModel.daysSince")
            UserDefaults.standard.set(digits, forKey: "CounterViewModel.digits")
            UserDefaults.standard.set(true, forKey: "didSave")
        }
    }
    // MARK: - Private
    func updatePercent(_ percent: Double) {
        for ix in 0..<numberOfUpdatesNeeded(for: daysSince + 1) {
            flipViewModels[ix].percent = percent
        }
    }
    
    func completeAnimation(after delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            self.inCloseAniation = false
        }
    }
    
    func resetFlips() {
        guard !inCloseAniation else { return }
        inCloseAniation = true
        daysSince = 0
        for model in flipViewModels {
            model.updateTexts(old: "0", new: "1")
        }
        completeAnimation(after: animationSpeed.resetFlip + animationSpeed.fallSpringFlip)
    }
    
    func increase() {
        guard !inCloseAniation else { return }
        inCloseAniation = true
        withAnimation(.easeIn(duration: animationSpeed.halfFlip)) {
            updatePercent(1)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.halfFlip){
            self.complete()
        }
    }
    
    func complete() {
        inCloseAniation = true
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
                inCloseAniation = false
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = CounterViewModel()

    var lastDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        guard let date = Calendar.current.date(byAdding: .day, value: -viewModel.daysSince, to: Date()) else { return "" }
        return formatter.string(from: date)
    }

    var body: some View {
        VStack {
            Spacer()
            Picker("Animation", selection: $viewModel.animationSpeed) {
                ForEach(AnimationTimes.allCases, id: \.self) { speed in
                    Text(speed.title).tag(speed)
                }
            }
            .pickerStyle(.segmented)
            Stepper("# of digits", value: $viewModel.digits, in: 0...5)
            Text("Days since last accident:")
                .font(.title)
            HStack {
                Spacer()
                ForEach(viewModel.flipViewModels.reversed()) { model in
                    FlipView(viewModel: model)
                }
                Spacer()
            }
            Text("Last accident on " + lastDateFormatted)
                .font(.caption)
            Button("Reset") {
                viewModel.resetFlips()
            }
            Button("Increase") {
                viewModel.increase()
            }
            Spacer()
        }
        .background()
        .gesture(
            DragGesture(minimumDistance: 5, coordinateSpace: .global)
                .onChanged { value in
                    guard !viewModel.inCloseAniation else { return }
                    viewModel.updatePercent(value.translation.height / 50)
                }
                .onEnded({ value in
                    guard !viewModel.inCloseAniation else { return }
                    if value.translation.height / 50 > 1 {
                        viewModel.complete()
                    } else {
                        withAnimation {
                            viewModel.updatePercent(0)
                        }
                    }
                })
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.dark)
    }
}
extension DateFormatter {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        return formatter
    }

}
