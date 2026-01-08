import SwiftUI

struct ProductDetailView: View {
    @State private var selectedColor = 0
    let colors = [Color.red, Color.green, Color.black]
    let colorNames = ["Stealth Red", "Emerald Green", "Midnight Black"]
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                // Image Gallery Placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 400)
                    .overlay(
                        VStack {
                            Image(systemName: "figure.golf")
                                .font(.system(size: 150))
                                .foregroundColor(.black.opacity(0.1))
                        }
                    )
                
                HStack {
                    Button(action: {}) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Image(systemName: "heart")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(index == 0 ? Color.white : Color.white.opacity(0.5))
                                .frame(width: index == 0 ? 20 : 6, height: 6)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .frame(height: 400)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TAYLORMADE")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Theme.primary)
                                
                                Text("Stealth 2 Plus\nDriver")
                                    .font(.system(size: 32, weight: .bold))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("$599")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Theme.primary)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Theme.accent)
                                    Text("4.9")
                                        .font(.system(size: 12, weight: .bold))
                                    Text("(128)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Text("Diseñado con una cara de torsión de carbono de 60X para un rendimiento más ligero, rápido y tolerante.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(colorNames[selectedColor])
                            .font(.system(size: 14, weight: .bold))
                        
                        HStack(spacing: 16) {
                            ForEach(0..<colors.count, id: \.self) { index in
                                Circle()
                                    .fill(colors[index])
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black, lineWidth: selectedColor == index ? 2 : 0)
                                            .padding(-4)
                                    )
                                    .onTapGesture {
                                        selectedColor = index
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Descripción")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("El Stealth 2 Plus conserva la cara de torsión de carbono 60X pero agrega un nuevo anillo compuesto reforzado con carbono para mayor durabilidad. La pista de peso deslizante le permite ajustar la forma de su tiro preferida, desde fade hasta draw, brindándole una personalización de nivel de tour.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineSpacing(6)
                        
                        Button(action: {}) {
                            HStack {
                                Text("Leer especificaciones completas")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Theme.primary)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(32)
                    .padding(.horizontal)
                    .shadow(color: Theme.Shadows.soft.color, radius: Theme.Shadows.soft.radius, x: Theme.Shadows.soft.x, y: Theme.Shadows.soft.y)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Completa el Look")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 140, height: 140)
                                        .overlay(Image(systemName: "tshirt").font(.largeTitle).foregroundColor(.gray))
                                    Text("Tour Polo")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("$85.00")
                                        .font(.system(size: 14))
                                        .foregroundColor(Theme.primary)
                                }
                                
                                VStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 140, height: 140)
                                        .overlay(Image(systemName: "hat.cap").font(.largeTitle).foregroundColor(.gray))
                                    Text("Performance Cap")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("$35.00")
                                        .font(.system(size: 14))
                                        .foregroundColor(Theme.primary)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            
            // Bottom Bar
            HStack(spacing: 20) {
                HStack(spacing: 20) {
                    Button(action: {}) { Image(systemName: "minus") }
                    Text("1")
                        .font(.system(size: 18, weight: .bold))
                    Button(action: {}) { Image(systemName: "plus") }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.black.opacity(0.05))
                .cornerRadius(20)
                
                Button(action: {}) {
                    HStack {
                        Text("Añadir al Carrito")
                        Spacer()
                        Text("$599")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .background(Theme.primary)
                    .cornerRadius(20)
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    ProductDetailView()
}
