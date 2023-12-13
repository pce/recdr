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
                        let x = value.location.x / geometry.size.width
                        let y = value.location.y / geometry.size.height
                        position = CGPoint(x: x, y: y)
                    }
            )
        }
    }
}


//#Preview {
//    XYPadView()
//}
