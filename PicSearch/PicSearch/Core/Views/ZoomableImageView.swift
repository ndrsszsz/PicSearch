//
//  ZoomableImageView.swift
//  PicSearch
//
//  Created by Andras Szasz on 2025. 09. 29..
//


import SwiftUI

struct ZoomableImageView<Content: View>: View {
    let content: () -> Content

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            content()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = min(max(1.0, lastScale * value), 5.0)
                            }
                            .onEnded { _ in
                                lastScale = scale
                            },
                        DragGesture()
                            .onChanged { value in
                                guard scale > 1 else { return }
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                )
                .animation(.easeInOut(duration: 0.2), value: scale)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onTapGesture(count: 2) {
                    withAnimation {
                        reset()
                    }
                }
        }
    }

    private func reset() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
    }
}
