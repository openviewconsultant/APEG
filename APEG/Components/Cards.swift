import SwiftUI

struct PlayActionCard: View {
    let temperature: String
    let condition: String
    let symbol: String
    let locationName: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ESTADO DEL CAMPO")
                        .font(Theme.Typography.caption)
                        .kerning(1.5)
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("Excelente para jugar")
                        .font(Theme.Typography.title3)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Label(temperature, systemImage: symbol)
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.secondary)
                        
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 4, height: 4)
                        
                        Text(locationName)
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Theme.primary)
                        .frame(width: 54, height: 54)
                        .shadow(color: Theme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white)
                }
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
            }
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(Theme.Typography.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
            }
        }
    }
}

struct PromoBannerCard: View {
    let title: String
    let subtitle: String
    let price: String
    let image: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 32)
                .fill(Theme.cardBackground)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("OFERTA ESPECIAL")
                    .font(Theme.Typography.caption)
                    .kerning(2)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Theme.Typography.title1)
                        .foregroundColor(.white)
                    Text(price)
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    HStack {
                        Text("Ver Más")
                        Image(systemName: "chevron.right")
                    }
                    .font(Theme.Typography.button)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Theme.primary)
                    .cornerRadius(20)
                }
            }
            .padding(24)
        }
        .padding(.vertical, 10)
    }
}

struct TipCard: View {
    let title: String
    let time: String
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: iconName)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.headline)
                    .foregroundColor(.white)
                Text(time + " lectura")
                    .font(Theme.Typography.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        }
        .frame(width: 240)
    }
}

// MARK: - Modern Caddie Card
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
            horizontalStyle
        } else {
            verticalStyle
        }
    }
    
    private var horizontalStyle: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.1))
                    .frame(width: 60, height: 60)
                Text(String(name.prefix(1)))
                    .font(.headline)
                    .foregroundColor(Theme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(Theme.Typography.headline)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", rating))
                    }
                    .font(Theme.Typography.caption)
                }
                
                Text(specialty)
                    .font(Theme.Typography.caption)
                    .foregroundColor(.white.opacity(0.5))
                
                HStack(spacing: 12) {
                    Label("HCP \(hcp)", systemImage: "figure.golf")
                    if let r = rounds {
                        Label("\(r)+ rondas", systemImage: "arrow.clockwise")
                    }
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Theme.secondary)
            }
            
            VStack(alignment: .trailing) {
                Text("$\(price)")
                    .font(Theme.Typography.title3)
                Text("/ronda")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            .foregroundColor(.white)
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
    
    private var verticalStyle: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(Theme.primary.opacity(0.1))
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: 10, weight: .bold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Theme.cardBackground)
                .clipShape(Capsule())
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(Theme.Typography.headline)
                    .foregroundColor(.white)
                Text(specialty)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                
                HStack {
                    Text("$\(price)")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.secondary)
                    Text("/h")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.top, 4)
            }
        }
        .padding(12)
        .background(Theme.cardBackground)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

// MARK: - Modern Card Background Utility
struct ModernCardBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(Theme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
    }
}

// MARK: - Modern Product Card
struct ProductCard: View {
    let title: String
    let price: Double
    let imageUrl: String?
    let brand: String?
    var plusAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                // Product Image
                if let urlString = imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 140)
                                .overlay(
                                    ProgressView()
                                        .tint(.white)
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 140)
                                .clipped()
                                .cornerRadius(24)
                        case .failure(_):
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 140)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.white.opacity(0.3))
                                )
                        @unknown default:
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 140)
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 140)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.3))
                        )
                }
                
                if let b = brand {
                    Text(b.uppercased())
                        .font(.system(size: 8, weight: .black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(10)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Typography.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack {
                    Text("$\(String(format: "%.0f", price))")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.secondary)
                        .fontWeight(.black)
                    
                    Spacer()
                    
                    Button(action: plusAction) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(Theme.cardBackground)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
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
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    if isFeatured {
                        Text("DESTACADO")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Theme.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.primary.opacity(0.1))
                            .cornerRadius(6)
                    }
                    
                    Text(title)
                        .font(Theme.Typography.title3)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                        Text(location)
                            .font(Theme.Typography.caption)
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(date)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.secondary)
                    Text("$\(fee)")
                        .font(Theme.Typography.title3)
                        .foregroundColor(.white)
                }
            }
            
            HStack {
                Spacer()
                Button(action: {}) {
                    Text("Ver Detalles")
                        .font(Theme.Typography.button)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Theme.primary)
                        .cornerRadius(20)
                }
            }
        }
        .padding(20)
        .background(Theme.cardBackground)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(isFeatured ? Theme.primary.opacity(0.3) : Color.white.opacity(0.05), lineWidth: isFeatured ? 2 : 1)
        )
        .shadow(color: isFeatured ? Theme.primary.opacity(0.2) : .clear, radius: 15, x: 0, y: 8)
    }
}

// MARK: - Marketing Product Card
struct MarketingProductCard: View {
    let title: String
    let price: Double
    let imageUrl: String?
    let brand: String?
    var plusAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                // Product Image
                if let urlString = imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 180)
                                .overlay(ProgressView().tint(.white))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                                .cornerRadius(24)
                        case .failure(_):
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 180)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.white.opacity(0.3))
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 180)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.3))
                        )
                }
                
                // Marketing Badge
                Text("NUEVO")
                    .font(.system(size: 8, weight: .black))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .foregroundColor(Theme.deepBlack)
                    .cornerRadius(8)
                    .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                if let b = brand {
                    Text(b.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.primary)
                        .tracking(1)
                }
                
                Text(title)
                    .font(Theme.Typography.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Precio")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                        Text("$\(String(format: "%.0f", price))")
                            .font(.title3)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: plusAction) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.deepBlack)
                            .padding(12)
                            .background(Theme.primary)
                            .clipShape(Circle())
                            .shadow(color: Theme.primary.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(Theme.cardBackground)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
