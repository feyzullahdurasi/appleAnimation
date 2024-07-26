//
//  BraceletDetailView.swift
//  animation
//
//  Created by Feyzullah Durası on 25.07.2024.
//

import SwiftUI

struct BraceletDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var balloons: [Balloon] = []
    @State private var selectedBalloonId: UUID?
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
            
            ZStack {
                // Çizim alanı
                Canvas { context, size in
                    let path = Path { path in
                        let width = size.width
                        let height = size.height
                        let midY = height / 2
                        let frequency: CGFloat = -2 * .pi / width
                        let amplitude: CGFloat = height / 15
                        
                        path.move(to: CGPoint(x: 0, y: midY))
                        
                        for x in stride(from: 0, to: width, by: 1) {
                            let y = midY - amplitude * sin(frequency * x)
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    let strokeColor = Color.purple.opacity(0.5)
                    context.stroke(path, with: .color(strokeColor), lineWidth: 8)
                }
                
                // Balonlar
                                ForEach(balloons) { balloon in
                                    Circle()
                                        .fill(Color.purple)
                                        .frame(width: balloon.size, height: balloon.size)
                                        .overlay(
                                            Text(balloon.letter)
                                                .foregroundColor(.white)
                                                .font(.system(size: balloon.size / 2, weight: .bold))
                                        )
                                        .position(x: balloon.x, y: balloon.y)
                                        .offset(y: selectedBalloonId == balloon.id ? -50 : 0)
                                        .animation(.easeInOut(duration: 0.5), value: selectedBalloonId)
                                        .onTapGesture {
                                            selectBalloon(balloon)
                                        }
                                }
                
            }
            .padding()
            .onAppear {
                addBalloons()
            }
            
            
            
            ZStack {
                HStack {
                    ForEach(balloons) { balloon in
                        
                        Circle()
                            .fill(Color.purple)
                            .frame(width: balloon.size, height: balloon.size)
                            .overlay(
                                Text(balloon.letter)
                                    .foregroundColor(.white)
                                    .font(.system(size: balloon.size / 2, weight: .bold))
                            )
                            .offset(y: selectedBalloonId == balloon.id ? -300 : 0) // Yukarı hareket
                            .animation(.easeInOut(duration: 1), value: selectedBalloonId)
                            .onTapGesture {
                                selectBalloon(balloon)
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 100)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                .padding()
                .padding()
                
                BoxWrapper(isOpen: $isBoxOpen)
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .offset(y: isBoxOpen ? -100 : 0)
                    .rotation3DEffect(
                        .degrees(isBoxOpen ? -90 : 0),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .bottom
                    )
                    .animation(.easeInOut(duration: 0.8), value: isBoxOpen)
                    .zIndex(1)
                    .cornerRadius(10)
                    .padding()
                    .padding()
                    
            }
            .onTapGesture {
                // HStack'e tıklanınca Box'ı yukarı kaldır
                isBoxOpen.toggle()
            }
            
            Spacer()
        }
    }
    
    func addBalloons() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let frequency: CGFloat = -2 * .pi / width
        let amplitude: CGFloat = height / 15
        
        // Örnek baloncuklar ekleyelim
        for i in stride(from: 0, to: width, by: 60) {
            let y = (height / 5 ) - amplitude * sin(frequency * i)
            let size: CGFloat = 30
            let letter = String(UnicodeScalar(Int.random(in: 65...90))!) // A-Z arası rastgele harf
            balloons.append(Balloon(x: i, y: y, size: size, letter: letter))
        }
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

struct Balloon: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let letter: String
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
    BraceletDetailView()
}
