//
//  SettingsHeaderView.swift
//  DaysSinceLast
//
//  Created by Henrik Storch on 13.03.22.
//

import SwiftUI

struct SettingsHeaderView: View {
    @ObservedObject var viewModel: CounterViewModel
    @State var showSpeed = false
    @State var showDigits = false
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    showSpeed.toggle()
                } label: {
                    Image(systemName: "timer")
                        .imageScale(.large)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(TintShapeStyle(), lineWidth: 3)
                        )
                }
                if showSpeed {
                    HStack {
                        Text("Animations")
                        Picker("Animation Speed", selection: $viewModel.animationSpeed) {
                            ForEach(AnimationTime.allCases, id: \.self) { speed in
                                Image(systemName: speed.iconName).tag(speed)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                Spacer()
            }
            HStack {
                Button {
                    showDigits.toggle()
                } label: {
                    Image(systemName: "number")
                        .imageScale(.large)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(TintShapeStyle(), lineWidth: 3)
                        )
                }
                if showDigits {
                    Stepper("# of digits: ", value: $viewModel.digits, in: 1...6)
                }
                Spacer()
            }
            Spacer()
        }.animation(.easeInOut, value: showDigits).animation(.easeInOut, value: showSpeed)
            .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsHeaderView(viewModel: .init())
    }
}
