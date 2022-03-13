//
//  FlipView.swift
//  DaysSinceLast
//
//  Created by Henrik Storch on 12.03.22.
//

import SwiftUI

struct FlipView: View {
    
    init(viewModel: FlipViewModel) {
        self.viewModel = viewModel
    }
    
    @ObservedObject var viewModel: FlipViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                SingleFlipView(text: viewModel.newValue ?? "", type: .top)
                SingleFlipView(text: viewModel.oldValue ?? "", type: .top)
                    .rotation3DEffect(
                        .init(
                            degrees:
                                (viewModel.percent * -90).clamped(to: -90...0)),
                        axis: (1, 0, 0),
                        anchor: .bottom,
                        perspective: 0.5)
            }
            Color.separator
                .frame(height: 1)
            ZStack {
                SingleFlipView(text: viewModel.oldValue ?? "", type: .bottom)
                if viewModel.percent >= 1 {
                    SingleFlipView(text: viewModel.newValue ?? "", type: .bottom)
                        .rotation3DEffect(
                            .init(
                                degrees:
                                    ((2 - viewModel.percent) * 90).clamped(to: 0...90)),
                            axis: (1, 0, 0),
                            anchor: .top,
                            perspective: 0.5)
                }
            }
        }
        .fixedSize()
    }
}

struct FlipView_Previews: PreviewProvider {
    static var previews: some View {
        FlipView(viewModel: FlipViewModel(parentModel: CounterViewModel()))
    }
}
