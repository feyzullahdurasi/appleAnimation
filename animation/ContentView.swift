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
        Bracelet(word: "FEYZULLAH", braceletColor: Color.indigo),
        Bracelet(word: "FERDI", braceletColor: Color.blue),
        Bracelet(word: "ERDI", braceletColor: Color.red),
        Bracelet(word: "AHMET", braceletColor: Color.green),
        Bracelet(word: "TAYLAN", braceletColor: Color.orange),
        Bracelet(word: "MUHAMMED", braceletColor: Color.yellow),
        Bracelet(word: "YASEMIN", braceletColor: Color.black),
        Bracelet(word: "HIZIR", braceletColor: Color.brown)
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
                BraceletDetailView(bracelet: Bracelet(word: bracelet.word, braceletColor: bracelet.braceletColor))
            }
        }
    }
}

#Preview {
    ContentView()
}
