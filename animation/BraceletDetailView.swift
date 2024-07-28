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
                // Canvas, özel çizimler yapmak için kullanılır
                Canvas { context, size in
                    let path = createBraceletPath(size: size)
                    // Bu verilen boyutlara göre bir yol (Path) oluşturur. Bu yol, üzerinde çizim yapılacak şekli tanımlar.
                    let strokeColor = bracelet.braceletColor.opacity(0.5)
                    context.stroke(path, with: .color(strokeColor), lineWidth: 8)
                }
                
                // Seçilmiş balonlar
                GeometryReader { geometry in
                    // geometry parametresi aracılığıyla kapsayıcı görünümün boyut ve konum bilgilerini sağlar. Bu, dinamik olarak boyutları hesaplamak ve kullanmak için kullanılır.
                    ZStack {
                        ForEach(selectedBalloons.indices, id: \.self) { index in
                            balloonView(for: selectedBalloons[index], at: index, in: geometry.size)
                                .onTapGesture {
                                    deselectBalloon(selectedBalloons[index])
                                }
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
                        balloonView2(for: balloon)
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
    
    // CGFloat, Swift'te bir kayan nokta sayısı türüdür ve genellikle grafiksel hesaplamalar ve UI tasarımı için kullanılır.
    
    // CGPoint, Core Graphics ve SwiftUI'da iki boyutlu bir noktayı temsil eden bir yapıdır. X ve Y koordinatlarını içerir ve genellikle grafiksel işlemlerde, kullanıcı arayüzü düzenlemelerinde veya animasyonlarda kullanılır.
    
    private func createBraceletPath(size: CGSize) -> Path {
        Path { path in
            let width = size.width
            let height = size.height
            let midY = height / 2
            let frequency: CGFloat = 2 * .pi / width // Frekansı hesaplar
            let amplitude: CGFloat = height / CGFloat(bracelet.angle) // Genliği hesaplar
            
            path.move(to: CGPoint(x: 0, y: midY)) // (x, y) noktasına bir çizgi çizer. Bu işlem tüm x değerleri için tekrarlanır ve dalga şeklindeki yolu oluşturur.
            
            for x in stride(from: 0, to: width, by: 1) {
                let y = midY - amplitude * sin(frequency * x)
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
    }
    
    private func balloonView2(for balloon: Balloon) -> some View {
        Circle()
            .fill(bracelet.braceletColor)
            .frame(width: balloon.size, height: balloon.size)
            .overlay(
                Text(balloon.letter)
                    .foregroundColor(.white)
                    .font(.system(size: balloon.size / 2, weight: .bold))
            )
        
    }
    
    // CGSize, iOS ve macOS uygulamalarında genişlik ve yüksekliği temsil eden bir yapıdır.
    private func balloonView(for balloon: Balloon, at index: Int, in size: CGSize) -> some View {
        let path = createBraceletPath(size: size)
        let totalWidth = size.width
        let step: CGFloat
        
        if selectedBalloons.count <= 10 {
            // 10 balon için eşit aralıklar
            step = totalWidth / CGFloat(selectedBalloons.count)
        } else {
            let remainingBalloons = max(selectedBalloons.count - 5, 1)
            let firstPartWidth = totalWidth / CGFloat(5)
            let secondPartWidth = totalWidth / CGFloat(remainingBalloons)
            
            // İndeks 0-9 arasındaysa, ilk düzeni kullan
            if index < 5 {
                step = firstPartWidth
            } else {
                step = secondPartWidth
            }
        }
        
        let xPosition: CGFloat
        if selectedBalloons.count <= 5 {
            // İlk 5 balon için basit eşit aralık
            xPosition = CGFloat(index) * step
        } else {
            // İlk 5 balon sonrasında, kalan balonlar için genişletilmiş aralık
            if index < 5 {
                xPosition = CGFloat(index) * step
            } else {
                let adjustedIndex = CGFloat(index - 5)
                xPosition = (CGFloat(5) * step) + (adjustedIndex * step)
            }
        }
        
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
        let frequency: CGFloat = 2 * .pi / width
        let amplitude: CGFloat = height / CGFloat(bracelet.angle)
        
        // X koordinatına karşılık gelen Y koordinatını hesaplayalım
        let y = midY - amplitude * sin(frequency * x)
        return y
    }
    
    private var boxView: some View {
        BoxWrapper(isOpen: $isBoxOpen)
            .frame(maxWidth: .infinity, maxHeight: 100)
            .offset(y: isBoxOpen ? -100 : 0)
            .rotation3DEffect(
                .degrees(isBoxOpen ? -90 : 0),
                axis: (x: 0, y: 1, z: 0),
                anchor: .top
            ) // rotation3DEffect, 3D dönüşüm uygular. Burada, isBoxOpen true ise kutu -90 derece döner (y ekseninde döner). anchor: .top ifadesi, dönüşümün üstten yapılmasını sağlar.
            .animation(.easeInOut(duration: 0.7), value: isBoxOpen) // easeInOut animasyon türü, animasyonun yumuşak bir şekilde başlayıp ve bitmesini sağlar.
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
    } // Bu, iki Balloon örneğini karşılaştırmak için kullanılan parametrelerdir. lhs (left-hand side) ve rhs (right-hand side) terimleri, karşılaştırmanın sol ve sağ tarafındaki nesneleri temsil eder.
}

struct BoxWrapper: UIViewRepresentable {
    // UIViewRepresentable, SwiftUI'da UIKit bileşenlerini kullanmanıza olanak tanır.
    @Binding var isOpen: Bool
    
    func makeUIView(context: Context) -> Box {
        Box()
    }
    
    func updateUIView(_ box: Box, context: Context) {
        UIView.animate(withDuration: 0.8, animations: {
            box.lid.transform = self.isOpen ? CGAffineTransform(translationX: 0, y: -50)
                .concatenating(CGAffineTransform(rotationAngle: .pi / 2)) : .identity
        })
    } // Eğer isOpen true ise, box.lid'i yukarı doğru kaydırır ve 90 derece döndürür. Eğer false ise, dönüşüm sıfırlanır. Bu animasyon, 0.8 saniye süren bir geçişle uygulanır.
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
    } // NSCoder sınıfı, bir nesneyi veri olarak kodlamak ve decode etmek için kullanılır.
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lid.frame = CGRect(x: 0, y: 0, width: bounds.width , height: 100) // lid bileşeninin CGRect içinde tanımlanan konum ve boyutlarını belirtir
        
    } // layoutSubviews, view'ın boyutları değiştiğinde veya alt bileşenlerin konumları güncellenmesi gerektiğinde çağrılır. Bu metodun override edilmesi, alt bileşenlerin uygun şekilde yeniden düzenlenmesini sağlar.
}

#Preview {
    BraceletDetailView(bracelet: Bracelet(word: "AHMET", braceletColor: Color.green, angle: -12))
}
