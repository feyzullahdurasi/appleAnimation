//
//  ContentView.swift
//  animation
//
//  Created by Feyzullah Durası on 25.07.2024.
//

import SwiftUI

struct ContentView: View {
    @Namespace private var namespace
    @State private var selectedBracelet: Bracelet?
    @State private var isBeadBoxOpen = false
    
    let bracelets: [Bracelet] = [
        Bracelet(name: "Classic Bracelet", description: "A classic bracelet with elegant design.", imageName: "bracelet1"),
        Bracelet(name: "Sport Bracelet", description: "A sporty bracelet for active individuals.", imageName: "bracelet2"),
        Bracelet(name: "Luxury Bracelet", description: "A luxury bracelet with premium materials.", imageName: "bracelet3"),
        Bracelet(name: "Classic Bracelet", description: "A classic bracelet with elegant design.", imageName: "bracelet1"),
        Bracelet(name: "Sport Bracelet", description: "A sporty bracelet for active individuals.", imageName: "bracelet2"),
        Bracelet(name: "Luxury Bracelet", description: "A luxury bracelet with premium materials.", imageName: "bracelet3")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(bracelets) { bracelet in
                        BraceletPreview(bracelet: bracelet, namespace: namespace)
                            .frame(height: 120)
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(10)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    selectedBracelet = bracelet
                                }
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Bracelets")
            .fullScreenCover(item: $selectedBracelet) { bracelet in
                BraceletDetailView()
            }
        }
    }
}

#Preview {
    ContentView()
}
