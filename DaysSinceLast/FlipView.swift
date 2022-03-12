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
        print(viewModel)
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
                                viewModel.animateTop ? (viewModel.percent * -90).clamped(to: -90...0) : 0),
                        axis: (1, 0, 0),
                        anchor: .bottom,
                        perspective: 0.5)
            }
            Color.separator
                .frame(height: 1)
            ZStack {
                SingleFlipView(text: viewModel.oldValue ?? "", type: .bottom)
                if viewModel.animateBottom {
                    SingleFlipView(text: viewModel.newValue ?? "", type: .bottom)
                    .rotation3DEffect(
                        .init(
                            degrees:
                                viewModel.percent < 1 || !viewModel.animateBottom ? 90 : (2 - viewModel.percent).clamped(to: 0...90) * 90),
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
        FlipView(viewModel: FlipViewModel())
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#if swift(<5.1)
extension Strideable where Stride: SignedInteger {
    func clamped(to limits: CountableClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
#endif