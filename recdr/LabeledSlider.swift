//
//  LabeledSlider.swift
//  recdr
//
//  Created by Patrick on 13.12.23.
//

import SwiftUI
import AVFoundation


struct LabeledSlider: View {
    var title: String
    @Binding var value: AUValue
    var range: ClosedRange<AUValue>
    var step: AUValue
    var valueFormat: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            HStack {
                Slider(
                    value: Binding(
                        get: { Double(self.value) },
                        set: { self.value = AUValue($0) }
                    ),
                    in: Double(range.lowerBound)...Double(range.upperBound),
                    step: Double(step)
                )
                Text(String(format: valueFormat, self.value))
                    .frame(width: 50, alignment: .trailing)
            }
        }
    }
}
