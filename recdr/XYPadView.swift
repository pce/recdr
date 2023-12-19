//
//  XYPadView.swift
//  recdr
//
//  Created by Patrick on 13.12.23.
//

import SwiftUI

struct XYPadView: View {
    @Binding var position: CGPoint
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle().fill(Color.gray.opacity(0.2))
                Circle()
                    .frame(width: 20, height: 20)
                    .offset(x: position.x * geometry.size.width - geometry.size.width / 2,
                            y: position.y * geometry.size.height - geometry.size.height / 2)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        var x = value.location.x / geometry.size.width
                        var y = value.location.y / geometry.size.height
                        // Clamp values that pointer's position is in bounds of the Pad
                        x = max(0, min(x, 1))
                        y = max(0, min(y, 1))
                        
                        position = CGPoint(x: x, y: y)
                    }
            )
        }
    }
}


//#Preview {
//    XYPadView()
//}
