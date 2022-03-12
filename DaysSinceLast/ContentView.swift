//
//  ContentView.swift
//  DaysSinceLast
//
//  Created by Henrik Storch on 12.03.22.
//

import SwiftUI

import Foundation
import Combine

class CounterViewModel {
    var daysSince = 0
    var inCloseAniation = false
    var numberOfUpdatesNeeded: Int {
        var result = 1
        guard daysSince != 0 else { return result }
        while (daysSince + 1) % Int(pow(Double(10), Double(result))) == 0, result < digits {
            result += 1
        }
        return result
    }
    var digits: Int = 5 {
        didSet {
            if digits == flipViewModels.count + 1 {
                flipViewModels.append(FlipViewModel())
            } else if digits == flipViewModels.count - 1 {
                flipViewModels.removeLast()
            } else { flipViewModels = Array(repeating: FlipViewModel.dummy, count: digits) }
        }
    }
    private(set) var flipViewModels: [FlipViewModel] = []

    init() {
        for ix in 0..<digits {
            let digitAtIx = (daysSince / Int(pow(Double(10), Double(ix)))) % 10
            let newModel = FlipViewModel()
            newModel.updateTexts(old: "\(digitAtIx)", new: "\(digitAtIx + 1)", animared: true)
            flipViewModels.append(newModel)
        }
    }
    // MARK: - Private
    func updatePercent(_ percent: Double) {
        for ix in 0..<numberOfUpdatesNeeded {
            print(ix)
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
    let viewModel = CounterViewModel()
    var body: some View {
        HStack {
            ForEach(1..<(viewModel.digits + 1)) { ix in
                FlipView(viewModel: viewModel.flipViewModels[viewModel.digits - ix])
            }
        }
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
        ContentView()
    }
}
