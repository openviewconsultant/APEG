import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @State private var quantity = 1
    @State private var showAddedToCart = false
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var reviewManager = ReviewManager.shared
    @StateObject private var chatManager = ChatManager.shared
    @State private var navigateToChat: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                // Image Carousel
                TabView {
                    if let images = product.images, !images.isEmpty {
                        ForEach(images, id: \.self) { urlString in
                             AsyncImage(url: URL(string: urlString)) { phase in
                                switch phase {
                                case .empty: ProgressView()
                                case .success(let image): 
                                    image.resizable().aspectRatio(contentMode: .fill).clipped()
                                case .failure: placeholderImage
                                @unknown default: placeholderImage
                                }
                            }
                        }
                    } else if let urlString = product.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image): image.resizable().aspectRatio(contentMode: .fill).clipped()
                            default: placeholderImage
                            }
                        }
                    } else {
                        placeholderImage
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
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
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Text(Theme.formatCurrency(product.price))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Theme.primary)
                        }
                        
                        Text(product.description ?? "No hay descripción disponible.")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                    // Seller Section
                    if let sellerId = product.sellerId {
                        NavigationLink(destination: SellerProfileView(sellerId: sellerId)) {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(Theme.primary.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                    .overlay(Image(systemName: "person.fill").foregroundColor(Theme.primary))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Vendido por Socio APEG")
                                        .font(Theme.Typography.headline)
                                        .foregroundColor(.white)
                                    Text("Ver perfil y calificaciones")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.lightGray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Theme.lightGray)
                            }
                            .padding(20)
                            .background(Theme.cardBackground)
                            .cornerRadius(32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Theme.softGreenBorder.opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Chat Button
                        Button(action: startChat) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Chatear con el Vendedor")
                            }
                            .font(Theme.Typography.button)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.05))
                            .foregroundColor(.white)
                            .cornerRadius(32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // Reviews Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Opiniones")
                            .font(.headline).foregroundColor(.white)
                        
                        if reviewManager.reviews.isEmpty {
                            Text("Aún no hay opiniones.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(reviewManager.reviews) { review in
                                ReviewCard(review: review)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Theme.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 20) {
                     // Quantity
                    HStack(spacing: 15) {
                        Button(action: { if quantity > 1 { quantity -= 1 } }) { Image(systemName: "minus") }
                        Text("\(quantity)").font(.headline).frame(width: 20)
                        Button(action: { quantity += 1 }) { Image(systemName: "plus") }
                    }
                    .foregroundColor(.white)
                    .frame(height: 64)
                    .padding(.horizontal, 16)
                    .background(Theme.cardBackground)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1)))
                    
                    // Add to Cart
                    Button(action: addToCart) {
                        Text(showAddedToCart ? "¡AÑADIDO!" : "AÑADIR AL CARRITO")
                            .tracking(1)
                            .font(Theme.Typography.button)
                            .foregroundColor(Theme.deepBlack)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(showAddedToCart ? Color.green : Theme.primary)
                            .cornerRadius(32)
                            .shadow(color: (showAddedToCart ? Color.green : Theme.primary).opacity(0.3), radius: 15, x: 0, y: 8)
                    }
                }
                .padding()
                .background(Theme.background.opacity(0.95))
                .padding(.bottom, 60)
            }
            
            // Invisible link for programmatic navigation
            if let chatId = navigateToChat {
                 NavigationLink(destination: ChatDetailView(chat: Chat(id: chatId, productId: product.id, buyerId: nil, sellerId: product.sellerId, createdAt: Date(), product: product)), isActive: Binding(get: { true }, set: { _ in navigateToChat = nil })) { EmptyView() }
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .onAppear {
            reviewManager.fetchReviews(productId: product.id)
        }
    }
    
    private func addToCart() {
        CartManager.shared.addToCart(product: product, quantity: quantity)
        withAnimation { showAddedToCart = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { showAddedToCart = false } }
    }
    
    private func startChat() {
        chatManager.startChat(product: product) { chatId in
            if let id = chatId {
                self.navigateToChat = id
            }
        }
    }
    
    private var placeholderImage: some View {
        Rectangle().fill(Color.gray.opacity(0.1)).frame(height: 400)
            .overlay(Image(systemName: "photo").font(.system(size: 60)).foregroundColor(.white.opacity(0.2)))
    }
}

#Preview {
    ProductDetailView(product: Product(id: UUID(), name: "Stealth 2", brand: "TaylorMade", description: "Driver Test", price: 600, category: "Palos", imageUrl: nil, stockQuantity: 5, sellerId: UUID(), images: []))
}
