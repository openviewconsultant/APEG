import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @State private var quantity = 1
    @State private var showAddedToCart = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                // Image
                Group {
                    if let urlString = product.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 400)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 400)
                                    .clipped()
                            case .failure:
                                placeholderImage
                            @unknown default:
                                placeholderImage
                            }
                        }
                    } else {
                        placeholderImage
                    }
                }
                .frame(height: 400)
                
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
                .padding()
                .padding(.top, 40)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                if let brand = product.brand {
                                    Text(brand.uppercased())
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Theme.primary)
                                }
                                
                                Text(product.name)
                                    .font(.system(size: 32, weight: .bold))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("$\(Int(product.price))")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Theme.primary)
                            }
                        }
                        
                        Text(product.description ?? "No hay descripción disponible para este producto.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Detalles del Producto")
                            .font(.system(size: 18, weight: .bold))
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Categoría")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(product.category ?? "General")
                                    .font(.body)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Disponibilidad")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(product.stockQuantity ?? 0) uds")
                                    .font(.body)
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(32)
                    .padding(.horizontal)
                    .shadow(color: Theme.Shadows.soft.color, radius: Theme.Shadows.soft.radius, x: Theme.Shadows.soft.x, y: Theme.Shadows.soft.y)
                }
                .padding(.vertical)
            }
            
            // Bottom Bar
            HStack(spacing: 20) {
                HStack(spacing: 20) {
                    Button(action: { if quantity > 1 { quantity -= 1 } }) { Image(systemName: "minus") }
                    Text("\(quantity)")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 30)
                    Button(action: { quantity += 1 }) { Image(systemName: "plus") }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.black.opacity(0.05))
                .cornerRadius(20)
                
                Button(action: {
                    CartManager.shared.addToCart(product: product, quantity: quantity)
                    withAnimation {
                        showAddedToCart = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showAddedToCart = false
                        }
                    }
                }) {
                    HStack {
                        Text(showAddedToCart ? "¡Añadido!" : "Añadir al Carrito")
                        Spacer()
                        Text("$\(Int(product.price * Double(quantity)))")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .background(showAddedToCart ? Color.green : Theme.primary)
                    .cornerRadius(20)
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.1))
            .frame(height: 400)
            .overlay(
                Image(systemName: "figure.golf")
                    .font(.system(size: 100))
                    .foregroundColor(.black.opacity(0.1))
            )
    }
}

#Preview {
    ProductDetailView(product: Product(id: UUID(), name: "Stealth 2 Plus Driver", brand: "TaylorMade", description: "El mejor driver para tu juego.", price: 599.0, category: "Drivers", imageUrl: nil, stockQuantity: 10))
}
