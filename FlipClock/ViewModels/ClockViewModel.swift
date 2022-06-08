import Foundation
import Combine

class ClockViewModel: FlipViewManager, ObservableObject {
    @Published var base: Base = .dec
    let animationSpeed: AnimationTime = .short

    init() {
        setupTimer()
    }

    private(set) lazy var flipViewModels = { (0...5).map { _ in FlipViewModel(parentModel: self) } }()

    // MARK: - Private

    private func setupTimer() {
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .map { [timeFormatter] in timeFormatter.string(from: $0) }
            .removeDuplicates()
            .sink(receiveValue: { [weak self] in self?.setTimeInViewModels(time: $0) })
            .store(in: &cancellables)
    }

    private func setTimeInViewModels(time: String) {
        zip(time, flipViewModels).forEach { number, viewModel in
            viewModel.updateTexts(old: "\(number)", new: nil)
        }
    }

    private var cancellables = Set<AnyCancellable>()
    private let timeFormatter = DateFormatter.timeFormatter

}
