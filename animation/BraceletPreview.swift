//
//  BraceletPreview.swift
//  animation
//
//  Created by Feyzullah Durası on 25.07.2024.
//

import SwiftUI

struct BraceletPreview: View {
    let bracelet: Bracelet
    let namespace: Namespace.ID

    @State private var balloons: [Balloon] = []
    
    var body: some View {
        ZStack {
            braceletCanvas
            balloonsView
        }
        .matchedGeometryEffect(id: bracelet.id, in: namespace)
        .padding()
        .onAppear(perform: createBalloons)
    }
    
    private var braceletCanvas: some View {
        Canvas { context, size in
            let path = createBraceletPath(size: size)
            let strokeColor = bracelet.braceletColor.opacity(0.5)
            context.stroke(path, with: .color(strokeColor), lineWidth: 5)
        }
    }
    
    private func createBraceletPath(size: CGSize) -> Path {
        Path { path in
            let width = size.width
            let height = size.height
            let midY = height / 2
            let frequency: CGFloat = -2 * .pi / width
            let amplitude: CGFloat = height / 8
            
            path.move(to: CGPoint(x: 0, y: midY))
            
            for x in stride(from: 0, to: width, by: 1) {
                let y = midY - amplitude * sin(frequency * x)
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
    }
    
    private var balloonsView: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(balloons.indices, id: \.self) { index in
                    balloonView(for: balloons[index], at: index, in: geometry.size)
                }
            }
        }
    }
    
    private func balloonView(for balloon: Balloon, at index: Int, in size: CGSize) -> some View {
        let path = createBraceletPath(size: size)
        let totalWidth = size.width
        let step = totalWidth / CGFloat(balloons.count)
        let xPosition = CGFloat(index) * step
        let yPosition = yPositionOnPath(x: xPosition, in: path, size: size)
        
        return Text(balloon.letter)
            .foregroundColor(.white)
            .font(.system(size: balloon.size / 2, weight: .bold))
            .frame(width: balloon.size, height: balloon.size)
            .background(
                Circle()
                    .fill(bracelet.braceletColor)
            )
            .position(x: xPosition, y: yPosition)
    }
    
    private func yPositionOnPath(x: CGFloat, in path: Path, size: CGSize) -> CGFloat {
        // Path'ten Y koordinatını almak için daha hassas bir yöntem
        let width = size.width
        let height = size.height
        let midY = height / 2
        let frequency: CGFloat = -2 * .pi / width
        let amplitude: CGFloat = height / 8
        
        // X koordinatına karşılık gelen Y koordinatını hesaplayalım
        let y = midY - amplitude * sin(frequency * x)
        return y
    }
    
    private func createBalloons() {
        let limitedWord = String(bracelet.word.prefix(5))
        balloons = limitedWord.enumerated().map { (index, letter) in
            Balloon(size: 20, letter: String(letter))
        }
    }
}

#Preview {
    @Namespace var namespace
    return BraceletPreview(bracelet: Bracelet(word: "AHMET", braceletColor: Color.green), namespace: namespace)
}
