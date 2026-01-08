import SwiftUI

struct ProductCard: View {
    let title: String
    let price: Double
    let imageName: String
    let brand: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(height: 160)
                    .shadow(color: Theme.Shadows.soft.color, radius: Theme.Shadows.soft.radius, x: Theme.Shadows.soft.x, y: Theme.Shadows.soft.y)
                    .overlay(
                        Image(systemName: "golfball")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.primary.opacity(0.3))
                    )
                
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.primary)
                        .padding(10)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                if let brand = brand {
                    Text(brand.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.primary)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("$\(Int(price))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 4)
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
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(10)
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(specialty.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Theme.primary)
                
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                
                Text("HCP \(hcp)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("$\(price) /ronda")
                        .font(.system(size: 14, weight: .bold))
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
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Theme.Shadows.soft.color, radius: Theme.Shadows.soft.radius, x: Theme.Shadows.soft.x, y: Theme.Shadows.soft.y)
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
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    if isFeatured {
                        Text("DESTACADO")
                            .font(.system(size: 10, weight: .bold))
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
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.primary)
                
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                
                Text(location)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("INSCRIPCIÓN")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        Text("$\(fee)")
                            .font(.system(size: 20, weight: .bold))
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack {
                            Text("Reservar")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(25)
                    }
                }
                .padding(.top, 10)
            }
            .padding(20)
            .background(Color.black.opacity(0.05))
        }
        .cornerRadius(24)
        .shadow(color: Theme.Shadows.soft.color, radius: Theme.Shadows.soft.radius, x: Theme.Shadows.soft.x, y: Theme.Shadows.soft.y)
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
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 32, weight: .bold))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Theme.Shadows.soft.color, radius: Theme.Shadows.soft.radius, x: Theme.Shadows.soft.x, y: Theme.Shadows.soft.y)
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
                    .font(.system(size: 14, weight: .bold))
                Text("\(time) lectura")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Theme.Shadows.soft.color, radius: Theme.Shadows.soft.radius, x: Theme.Shadows.soft.x, y: Theme.Shadows.soft.y)
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
            RoundedRectangle(cornerRadius: 35)
                .fill(color)
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 300, height: 300)
                        .offset(x: 150, y: -100)
                )
                .overlay(
                    Circle()
                        .fill(Theme.primary.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .offset(x: -100, y: 100)
                )
                .clipShape(RoundedRectangle(cornerRadius: 35))
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(tag.uppercased())
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Theme.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text(title)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .lineSpacing(2)
                    
                    HStack(spacing: 15) {
                        Text(price)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Button(action: {}) {
                            HStack {
                                Text("Comprar")
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.top, 5)
                }
                .padding(28)
                
                Spacer()
                
                ZStack {
                    Image(systemName: imageName)
                        .font(.system(size: 100))
                        .foregroundColor(.white.opacity(0.15))
                        .rotationEffect(.degrees(-15))
                }
                .padding(.trailing, 20)
            }
        }
        .shadow(color: color.opacity(0.3), radius: 20, x: 0, y: 12)
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
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 15, x: 0, y: 8)
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct PlayActionCard: View {
    var action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Theme.primary)
                            .frame(width: 8, height: 8)
                        Text("ESTADO DEL CAMPO")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.primary)
                    }
                    Text("Listo para Jugar")
                        .font(.system(size: 28, weight: .bold))
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Theme.primary.opacity(0.1))
                        .frame(width: 54, height: 54)
                    Image(systemName: "golfball")
                        .foregroundColor(Theme.primary)
                        .font(.title2)
                }
            }
            
            HStack(spacing: 12) {
                PlaySubItem(icon: "sun.max.fill", label: "22°C", subLabel: "Soleado")
                PlaySubItem(icon: "mappin.and.ellipse", label: "Pebble Beach", subLabel: "Cambiar")
                PlaySubItem(icon: "list.bullet.clipboard", label: "Scorecard", subLabel: "Registrar")
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    action()
                }
            }) {
                HStack {
                    Text("EMPEZAR RONDA")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "play.fill")
                        .font(.system(size: 14))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(colors: [Theme.primary, Theme.primary.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(20)
                .shadow(color: Theme.primary.opacity(0.4), radius: 12, x: 0, y: 8)
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 35)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 25, x: 0, y: 15)
        )
        .scaleEffect(isPressed ? 0.97 : 1)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.2)) {
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
