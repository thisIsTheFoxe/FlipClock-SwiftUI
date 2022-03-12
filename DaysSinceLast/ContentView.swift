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
    @Published var daysSince = 0 {
        didSet {
            UserDefaults.standard.set(daysSince, forKey: "CounterViewModel.daysSince")
        }
    }
    var inCloseAniation = false
    var numberOfUpdatesNeeded: Int {
        var result = 1
        guard daysSince != 0 else { return result }
        while (daysSince + 1) % Int(pow(Double(10), Double(result))) == 0, result < digits {
            result += 1
        }
        return result
    }
    @Published var digits: Int = 5 {
        didSet {
            UserDefaults.standard.set(digits, forKey: "CounterViewModel.digits")
            if digits == flipViewModels.count + 1 {
                let newModel = FlipViewModel()
                flipViewModels.append(newModel)
                withAnimation {
                    newModel.updateTexts(old: "0", new: "1", animared: true)
                }
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
            let newModel = FlipViewModel()
            newModel.updateTexts(old: "\(digitAtIx)", new: "\(digitAtIx + 1)", animared: true)
            flipViewModels.append(newModel)
        }
    }
    
    init() {
        if UserDefaults.standard.bool(forKey: "didSave") {
            daysSince = UserDefaults.standard.integer(forKey: "CounterViewModel.daysSince")
            digits = UserDefaults.standard.integer(forKey: "CounterViewModel.digits")
        } else {
            initModels()
            UserDefaults.standard.set(daysSince, forKey: "CounterViewModel.daysSince")
            UserDefaults.standard.set(digits, forKey: "CounterViewModel.digits")
            UserDefaults.standard.set(true, forKey: "didSave")
        }
    }
    // MARK: - Private
    func updatePercent(_ percent: Double) {
        for ix in 0..<numberOfUpdatesNeeded {
            flipViewModels[ix].animateTop = true
            flipViewModels[ix].animateBottom = true
            flipViewModels[ix].percent = percent
        }
    }

    func complete() {
        inCloseAniation = true
        withAnimation(.spring(response: 0.7, dampingFraction: 0.25, blendDuration: 0.5)) {
            updatePercent(2)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            daysSince += 1
            daysSince = daysSince % Int(pow(Double(10), Double(digits)))
            for ix in 0..<numberOfUpdatesNeeded {
                let digitAtIx = (daysSince / Int(pow(Double(10), Double(ix)))) % 10
                let nextDigit = ((daysSince + 1) / Int(pow(Double(10), Double(ix)))) % 10
                flipViewModels[ix].updateTexts(old: "\(digitAtIx)", new: "\(nextDigit)", animared: false)
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
            Stepper("# of digits", value: $viewModel.digits)
            Spacer()
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
