//
//  BraceletDetailView.swift
//  animation
//
//  Created by Feyzullah Durası on 25.07.2024.
//

import SwiftUI

struct BraceletDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    var bracelet: Bracelet
    @State private var balloons: [Balloon] = []
    @State private var selectedBalloons: [Balloon] = []
    @State private var isBoxOpen: Bool = false
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Geri")
                    .font(.headline)
                    .padding()
            }
            .padding()
            Spacer()
            
            ZStack {
                // Çizim alanı
                Canvas { context, size in
                    let path = createBraceletPath(size: size)
                    let strokeColor = bracelet.braceletColor.opacity(0.5)
                    context.stroke(path, with: .color(strokeColor), lineWidth: 8)
                }
                
                // Seçilmiş balonlar
                ZStack {
                    ForEach(selectedBalloons.indices, id: \.self) { index in
                        let balloon = selectedBalloons[index]
                        balloonView(for: balloon, index: index)
                            .onTapGesture {
                                deselectBalloon(balloon)
                            }
                    }
                }
                .animation(.spring(), value: selectedBalloons)
            }
            .frame(height: 300)
            .padding()
            
            Spacer()
            // Alt kısımdaki balonlar
            ZStack {
                HStack(spacing: 10) {
                                    ForEach(balloons) { balloon in
                                        balloonView(for: balloon)
                                            .onTapGesture { selectBalloon(balloon) }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: 100)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                                .padding()
                
                boxView
            }
            .onTapGesture {
                isBoxOpen.toggle()
            }
            
        }
        .onAppear {
            addBalloons()
        }
    }
    
    private func createBraceletPath(size: CGSize) -> Path {
        Path { path in
            let width = size.width
            let height = size.height
            let midY = height / 2
            let frequency: CGFloat = -2 * .pi / width
            let amplitude: CGFloat = height / 12
            
            path.move(to: CGPoint(x: 0, y: midY))
            
            for x in stride(from: 0, to: width, by: 1) {
                let y = midY - amplitude * sin(frequency * x)
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
    }
    
    private func balloonView(for balloon: Balloon, index: Int? = nil) -> some View {
        let balloonIndex = index ?? balloons.firstIndex(where: { $0.id == balloon.id }) ?? 0
        let step = screenWidth / CGFloat(balloons.count)
        let xPosition = CGFloat(balloonIndex) * step
        let yPosition = yPositionOnPath(x: xPosition)
        
        return Circle()
            .fill(bracelet.braceletColor)
            .frame(width: balloon.size, height: balloon.size)
            .overlay(
                Text(balloon.letter)
                    .foregroundColor(.white)
                    .font(.system(size: balloon.size / 2, weight: .bold))
            )
            .offset(y: -sin(CGFloat(balloonIndex) * .pi / 5) * 10)
            .position(x: xPosition, y: yPosition)
    }
    
    private func yPositionOnPath(x: CGFloat) -> CGFloat {
        let width = screenWidth
        let height = screenHeight
        let midY = height / 2
        let frequency: CGFloat = -2 * .pi / width
        let amplitude: CGFloat = height / 12
        
        return midY - amplitude * sin(frequency * x)
    }
    
    private var boxView: some View {
        BoxWrapper(isOpen: $isBoxOpen)
            .frame(maxWidth: .infinity, maxHeight: 100)
            .offset(y: isBoxOpen ? -100 : 0)
            .rotation3DEffect(
                .degrees(isBoxOpen ? -90 : 0),
                axis: (x: 0, y: 1, z: 0),
                anchor: .top
            )
            .animation(.easeInOut(duration: 0.7), value: isBoxOpen)
            .cornerRadius(10)
            .padding()
            
    }
    
    func addBalloons() {
        balloons = bracelet.word.map { Balloon(size: 30, letter: String($0)) }
                balloons.shuffle() // Balonları karıştır
    }
    
    func selectBalloon(_ balloon: Balloon) {
        if let index = balloons.firstIndex(where: { $0.id == balloon.id }) {
            let selectedBalloon = balloons.remove(at: index)
            selectedBalloons.append(selectedBalloon)
        }
    }
    
    func deselectBalloon(_ balloon: Balloon) {
        if let index = selectedBalloons.firstIndex(where: { $0.id == balloon.id }) {
            let deselectedBalloon = selectedBalloons.remove(at: index)
            balloons.append(deselectedBalloon)
        }
    }
}

struct Balloon: Identifiable, Equatable {
    let id = UUID()
    let size: CGFloat
    let letter: String
    
    static func == (lhs: Balloon, rhs: Balloon) -> Bool {
        lhs.id == rhs.id
    }
}

struct BoxWrapper: UIViewRepresentable {
    @Binding var isOpen: Bool
    
    func makeUIView(context: Context) -> Box {
        Box()
    }
    
    func updateUIView(_ box: Box, context: Context) {
        UIView.animate(withDuration: 0.8, animations: {
            box.lid.transform = self.isOpen ? CGAffineTransform(translationX: 0, y: -50).concatenating(CGAffineTransform(rotationAngle: .pi / 2)) : .identity
        })
    }
}

class Box: UIView {
    let lid = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        lid.addSubview(blurEffectView)
        
        lid.backgroundColor = UIColor.clear
        addSubview(lid)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lid.frame = CGRect(x: 0, y: 0, width: bounds.width , height: 100)
        
    }
}

#Preview {
    BraceletDetailView(bracelet: Bracelet(word: "AHMET", braceletColor: Color.green))
}
