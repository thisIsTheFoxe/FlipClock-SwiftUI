//
//  SimpleFlipView.swift
//  FlipClock
//
//  Created by Henrik Storch on 15.09.22.
//  Copyright © 2022 Maciej Gomółka. All rights reserved.
//

import SwiftUI
import WidgetKit

struct SimpleFlipView: View {
    let text: String

    var body: some View {
        VStack(spacing: 0) {
            SingleFlipView(text: text, type: .top, isBig: false)
            Color.separator
                .frame(height: 1)
            SingleFlipView(text: text, type: .bottom, isBig: false)
        }.fixedSize()
    }
}

struct SimpleFlipView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleFlipView(text: "X")
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
