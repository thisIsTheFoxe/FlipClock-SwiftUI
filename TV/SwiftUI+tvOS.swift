//
//  SwiftUI+tvOS.swift
//  TV
//
//  Created by Henrik Storch on 13.10.22.
//  Copyright © 2022 Maciej Gomółka. All rights reserved.
//

import SwiftUI
public struct Stepper : View {
    var title: LocalizedStringKey
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    public var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(title)
                HStack {
                    Button {
                        value -= 1
                    } label: {
                        Text("-")
                    }
                    Button {
                        value += 1
                    } label: {
                        Text("+")
                    }
                }
            }
            Spacer()
        }
        .focusSection()
    }

    public init(_ titleKey: LocalizedStringKey, value: Binding<Int>, in bounds: ClosedRange<Int>) {
        self.title = titleKey
        self._value = value
        self.range = bounds
    }
}

public struct Menu<Label, Content> : View where Label : View, Content : View {
    let content: () -> Content
    let label: () -> Label

    public init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder label: @escaping () -> Label) {
        self.content = content
        self.label = label
    }
    
    @FocusState var isFocused: Bool
    
    public var body: some View {
        label()
            .padding()
            .hoverEffect(isFocused ? .lift : .automatic)
            .background(isFocused ? .white : .gray)
            .foregroundColor(isFocused ? .black : nil)
            .focusable()
            .focused($isFocused, equals: true)
            .contextMenu(menuItems: content)

    }
}
