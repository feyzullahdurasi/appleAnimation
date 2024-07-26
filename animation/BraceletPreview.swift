//
//  BraceletPreview.swift
//  animation
//
//  Created by Feyzullah Durası on 25.07.2024.
//

import SwiftUI

struct BraceletPreview: View {
    var bracelet: Bracelet
    var namespace: Namespace.ID
    
    @State private var balloons: [Balloon] = []
    @State private var selectedBalloonId: UUID?
    
    var body: some View {
        ZStack {
            // Çizim alanı
            Canvas { context, size in
                let path = Path { path in
                    let width = size.width
                    let height = size.height
                    let midY = height / 2
                    let frequency: CGFloat = -2 * .pi / width
                    let amplitude: CGFloat = height / 4
                    
                    path.move(to: CGPoint(x: 0, y: midY))
                    
                    for x in stride(from: 0, to: width, by: 1) {
                        let y = midY - amplitude * sin(frequency * x)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                let strokeColor = Color.purple.opacity(0.5) // Saydamlık ekledik
                context.stroke(path, with: .color(strokeColor), lineWidth: 5)
            }
            
            // Baloncuklar
            ForEach(balloons) { balloon in
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: balloon.size, height: balloon.size)
                        .overlay(
                            Text(balloon.letter)
                                .foregroundColor(.white)
                                .font(.system(size: balloon.size / 2, weight: .bold))
                        )
                        .offset(y: selectedBalloonId == balloon.id ? -100 : 0) // Yukarı hareket
                        .animation(.easeInOut(duration: 1), value: selectedBalloonId)
                }
                .position(x: balloon.x, y: balloon.y) // Baloncukların konumu
                .onTapGesture {
                    selectBalloon(balloon)
                }
            }
        }
        
        .matchedGeometryEffect(id: bracelet.id, in: namespace)
        .padding()
    }
        
    
    func selectBalloon(_ balloon: Balloon) {
        if selectedBalloonId == balloon.id {
            // Aynı baloncu seçildiyse hareketi geri al
            selectedBalloonId = nil
        } else {
            // Yeni baloncu seçildiyse yukarı kaldır
            selectedBalloonId = balloon.id
        }
    }
}

#Preview {
    BraceletPreview(bracelet: Bracelet(name: "Classic", description: "A classic bracelet", imageName: "bracelet1"), namespace: Namespace().wrappedValue)
}
