import SwiftUI

enum Setting {
    case animation, digits, base
}

struct SettingsHeaderView: View {
    @ObservedObject var viewModel: CounterViewModel
    @State var activeSetting: Setting? {
        didSet {
            if activeSetting == oldValue { activeSetting = nil }
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 20) {
                Button {
                    activeSetting = .animation
                } label: {
                    Image(systemName: "timer")
                        .font(.title)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(TintShapeStyle(), lineWidth: 3)
                        )
                }
                Button {
                    activeSetting = .digits
                } label: {
                    Image(systemName: "number")
                        .font(.title)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(TintShapeStyle(), lineWidth: 3)
                        )
                }
                Menu {
                    ForEach(Base.allCases) { base in
                        HStack {
                            Button {
                                viewModel.base = base
                            } label: {
                                if base == viewModel.base {
                                    Image(systemName: "checkmark")
                                    Spacer()
                                }
                                Text(base.baseName)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "florinsign.square")
                        .font(.title)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(TintShapeStyle(), lineWidth: 3)
                        )
                }
            }
            .padding()
            HStack {
                if activeSetting == .animation {
                    HStack {
                        Text("Animations")
                        Picker("Animation Speed", selection: $viewModel.animationSpeed) {
                            ForEach(AnimationTime.allCases, id: \.self) { speed in
                                Image(systemName: speed.iconName).tag(speed)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                } else if activeSetting == .digits {
                    VStack {
                        Stepper("# of digits: ", value: $viewModel.digits, in: 1...6)
                    }
                }
                Spacer()
            }
            Spacer()
        }.animation(.easeInOut, value: activeSetting)
            .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsHeaderView(viewModel: .init())
    }
}
