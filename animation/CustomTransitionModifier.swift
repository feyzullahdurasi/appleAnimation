//
//  CustomTransitionModifier.swift
//  animation
//
//  Created by Feyzullah Durası on 25.07.2024.
//

import SwiftUI

struct CustomTransitionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .transition(.scale)
            .animation(.easeInOut(duration: 0.5), value: UUID())
    }
}

extension View {
    func customTransition() -> some View {
        self.modifier(CustomTransitionModifier())
    }
}

