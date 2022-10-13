import SwiftUI
import Combine

struct CounterView: View {
    @ObservedObject var viewModel = CounterViewModel()
    @State var showTitleEdit = false

    var lastDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        guard let date = Calendar.current.date(byAdding: .day, value: -viewModel.daysSince, to: Date()) else { return "" }
        return formatter.string(from: date)
    }

    var body: some View {
        VStack {
            SettingsHeaderView(viewModel: viewModel)
            Spacer()
            Text("\(viewModel.description):")
#if !os(tvOS)
                .font(.title)
#endif
                .onTapGesture {
                    UIApplication.shared.keyWindow()?.showAlert(placeholder: "Title", currentText: viewModel.description, primaryTitle: "Set Title", cancelTitle: "Cancel", primaryAction: { newTitle in
                        viewModel.description = newTitle
                    })
                }
            HStack {
                Spacer()
                ForEach(viewModel.flipViewModels.reversed()) { model in
                    FlipView(viewModel: model)
                        .transition(.offset(x: 20, y: 0))
                }
                Spacer()
            }
            .animation(.easeOut(duration: viewModel.animationSpeed.halfFlip), value: viewModel.digits)
            Text(lastDateFormatted)
                .font(.caption)
                .padding(.bottom, 35)
            
            Button("Reset") {
                viewModel.resetFlips()
            }
            .disabled(viewModel.inCloseAnimation)
            .padding()
#if !os(tvOS)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(TintShapeStyle(), lineWidth: 3)
            )
#endif
            .padding(.bottom)
            Button(action: {
                viewModel.increase()
            }, label: {
                Text("Increase").font(.title2).bold()
            })
            .disabled(viewModel.inCloseAnimation)
            .padding()
#if !os(tvOS)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(TintShapeStyle(), lineWidth: 3)
            )
#endif
            Spacer(minLength: 100)
        }
        .tint(Color.flipBackground)
        .background()
#if !os(tvOS)
        .gesture(
            DragGesture(minimumDistance: 5, coordinateSpace: .global)
                .onChanged { value in
                    guard !viewModel.inCloseAnimation else { return }
                    viewModel.updatePercent(value.translation.height / 50)
                    if 40...60 ~= value.translation.height, viewModel.patternEngine.isFinished {
                        viewModel.patternEngine.generate(pattern: viewModel.animationSpeed.flipPattern)
                    }
                }
                .onEnded({ value in
                    guard !viewModel.inCloseAnimation else { return }
                    if value.translation.height / 50 > 1 {
                        viewModel.complete()
                    } else {
                        withAnimation {
                            viewModel.updatePercent(0)
                        }
                    }
                })
        )
#endif
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView()
    }
}
