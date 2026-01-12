import SwiftUI

// MARK: - Modern Design Shared Components

struct ModernCardBackground: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 35)
                .fill(Color.white)
                .overlay(
                    ZStack {
                        // Blobs de colores pastel difuminados (Refined for general use)
                        Circle()
                            .fill(Color(hex: "60A5FA").opacity(0.15)) // Blue
                            .frame(width: 300, height: 300)
                            .offset(x: 120, y: -80)
                            .blur(radius: 60)
                        
                        Circle()
                            .fill(Color(hex: "F472B6").opacity(0.12)) // Pink
                            .frame(width: 250, height: 250)
                            .offset(x: -60, y: 100)
                            .blur(radius: 50)
                        
                        Circle()
                            .fill(Theme.primary.opacity(0.1)) // Green
                            .frame(width: 220, height: 220)
                            .offset(x: 100, y: 80)
                            .blur(radius: 40)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 35))
                .shadow(color: Color.black.opacity(0.04), radius: 20, x: 0, y: 10)
        }
    }
}

struct ProductCard: View {
    let title: String
    let price: Double
    let imageUrl: String?
    let brand: String?
    
    var plusAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .frame(height: 170)
                    .overlay(
                        GeometryReader { geo in
                            Group {
                                if let urlString = imageUrl, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: geo.size.width, height: geo.size.height)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: geo.size.width, height: geo.size.height)
                                                .clipped()
                                        case .failure:
                                            placeholderImage
                                                .frame(width: geo.size.width, height: geo.size.height)
                                        @unknown default:
                                            placeholderImage
                                                .frame(width: geo.size.width, height: geo.size.height)
                                        }
                                    }
                                } else {
                                    placeholderImage
                                        .frame(width: geo.size.width, height: geo.size.height)
                                }
                            }
                        }
                        .cornerRadius(24)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black.opacity(0.03), lineWidth: 1)
                    )
                
                if let action = plusAction {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        action()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.black))
                    }
                    .padding(12)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let brand = brand {
                    Text(brand.uppercased())
                        .font(Theme.Typography.subheadline)
                        .kerning(1.2)
                        .foregroundColor(Theme.primary)
                }
                
                Text(title)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.deepBlack)
                    .lineLimit(1)
                
                Text("$\(Int(price))")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.deepBlack)
            }
            .padding(.horizontal, 6)
        }
        .padding(12)
        .background(ModernCardBackground())
    }
    
    private var placeholderImage: some View {
        ZStack {
            Color(hex: "F0F0F0")
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 30))
                .foregroundColor(Theme.primary.opacity(0.2))
        }
    }
}

// MARK: - Caddie Card

struct CaddieCard: View {
    let name: String
    let rating: Double
    let specialty: String
    let hcp: Int
    let price: Int
    let rounds: Int?
    let isHorizontal: Bool
    
    var body: some View {
        if isHorizontal {
            horizontalBody
        } else {
            verticalBody
        }
    }
    
    private var verticalBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                    )
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Theme.accent)
                    Text("\(rating, specifier: "%.1f")")
                        .font(Theme.Typography.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(10)
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(specialty.uppercased())
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.primary)
                
                Text(name)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.deepBlack)
                
                Text("HCP \(hcp)")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("$\(price) /ronda")
                        .font(Theme.Typography.body)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(ModernCardBackground())
    }
    
    private var horizontalBody: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(specialty.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Theme.primary)
                
                Text(name)
                    .font(.system(size: 18, weight: .bold))
                
                HStack {
                    Text("HCP \(hcp)")
                    Text("•")
                    Text("\(rounds ?? 0)+ Rondas")
                }
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                
                Text("$\(price) /ronda")
                    .font(.system(size: 16, weight: .bold))
            }
            
            Spacer()
            
            Button("Seleccionar") {
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Theme.primary)
            .cornerRadius(12)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Theme.Shadows.soft.color, radius: Theme.Shadows.soft.radius, x: Theme.Shadows.soft.x, y: Theme.Shadows.soft.y)
    }
}

// MARK: - Tournament Card

struct TournamentCard: View {
    let title: String
    let location: String
    let date: String
    let fee: Int
    let isFeatured: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [.black.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
                    .background(
                        Color.gray.opacity(0.2) // Placeholder for image
                    )
                    .frame(height: 200)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text(date)
                    }
                    .font(Theme.Typography.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    if isFeatured {
                        Text("DESTACADO")
                            .font(Theme.Typography.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Theme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(16)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("DIVISIÓN PRO")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.primary)
                
                Text(title)
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.deepBlack)
                
                Text(location)
                    .font(Theme.Typography.body)
                    .foregroundColor(.secondary)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("INSCRIPCIÓN")
                            .font(Theme.Typography.caption)
                            .foregroundColor(.secondary)
                        Text("$\(fee)")
                            .font(Theme.Typography.title3)
                            .foregroundColor(Theme.deepBlack)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack {
                            Text("Reservar")
                            Image(systemName: "arrow.right")
                        }
                        .font(Theme.Typography.button)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black)
                        .cornerRadius(25)
                    }
                }
                .padding(.top, 10)
            }
            .padding(20)
        }
        .background(ModernCardBackground())
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let trend: String?
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(Theme.primary)
                    .padding(10)
                    .background(Theme.primary.opacity(0.1))
                    .clipShape(Circle())
                
                Spacer()
                
                if let trend = trend {
                    Text(trend)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(Theme.Typography.title1)
                    .foregroundColor(Theme.deepBlack)
            }
        }
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ModernCardBackground())
    }
}

// MARK: - Tip Card

struct TipCard: View {
    let title: String
    let time: String
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .foregroundColor(color)
                .padding(12)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.deepBlack)
                Text("\(time) lectura")
                    .font(Theme.Typography.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(ModernCardBackground())
    }
}

// MARK: - Promo Banner Card

struct PromoBannerCard: View {
    let tag: String
    let title: String
    let price: String
    let imageName: String
    let color: Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            ModernCardBackground()
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 14) {
                    // Tag con estilo moderno y sutil
                    Text(tag.uppercased())
                        .font(Theme.Typography.caption)
                        .kerning(1.2)
                        .foregroundColor(Theme.deepBlack)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.4))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(Theme.Typography.title2)
                            .foregroundColor(Theme.deepBlack)
                            .lineLimit(2)
                        
                        Text(price)
                            .font(Theme.Typography.title3)
                            .foregroundColor(Theme.deepBlack.opacity(0.6))
                    }
                    
                    // Botón con alto contraste y diseño premium
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }) {
                        HStack(spacing: 8) {
                            Text("Comprar Ahora")
                            Image(systemName: "chevron.right")
                        }
                        .font(Theme.Typography.button)
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 14)
                        .background(Theme.deepBlack)
                        .cornerRadius(18)
                    }
                    .padding(.top, 5)
                }
                .padding(32)
                
                Spacer()
                
                Image(systemName: imageName)
                    .font(.system(size: 120))
                    .foregroundColor(Theme.deepBlack.opacity(0.07))
                    .rotationEffect(.degrees(-15))
                    .offset(x: 10, y: 15)
            }
        }
    }
}

// MARK: - Navigation Cards

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    var action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: { 
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.white)
                        .frame(width: 95, height: 95)
                        .shadow(color: .black.opacity(0.04), radius: 15, x: 0, y: 8)
                    
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.12))
                            .frame(width: 50, height: 50)
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(color)
                    }
                }
                
                Text(title)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.deepBlack)
            }
        }
        .scaleEffect(isPressed ? 0.94 : 1)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct PlayActionCard: View {
    let temperature: String
    let condition: String
    let symbol: String
    let locationName: String
    var action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Theme.primary)
                            .frame(width: 10, height: 10)
                            .shadow(color: Theme.primary.opacity(0.5), radius: 4, x: 0, y: 0)
                        Text("ESTADO DEL CAMPO")
                            .font(Theme.Typography.subheadline)
                            .kerning(1.2)
                            .foregroundColor(Theme.primary)
                    }
                    Text("Listo para Jugar")
                        .font(Theme.Typography.title1)
                        .foregroundColor(Theme.deepBlack)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Theme.primary.opacity(0.12))
                        .frame(width: 60, height: 60)
                    Image(systemName: "circle.hexagongrid.fill")
                        .foregroundColor(Theme.primary)
                        .font(.title)
                }
            }
            
            HStack(spacing: 12) {
                PlaySubItem(icon: symbol, label: temperature, subLabel: condition)
                PlaySubItem(icon: "mappin.and.ellipse", label: locationName, subLabel: "Cambiar")
                PlaySubItem(icon: "list.bullet.clipboard", label: "Scorecard", subLabel: "Registrar")
            }
            
            Button(action: {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                action()
            }) {
                HStack(spacing: 12) {
                    Text("EMPEZAR RONDA")
                        .font(Theme.Typography.button)
                        .kerning(1.0)
                    Image(systemName: "play.fill")
                        .font(.system(size: 14))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "68C36B"), Color(hex: "4CAF50")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(22)
                .shadow(color: Color(hex: "4CAF50").opacity(0.4), radius: 15, x: 0, y: 10)
            }
        }
        .padding(30)
        .background(ModernCardBackground())
        .scaleEffect(isPressed ? 0.97 : 1)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct PlaySubItem: View {
    let icon: String
    let label: String
    let subLabel: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.secondary)
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .bold))
                Text(subLabel)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}
