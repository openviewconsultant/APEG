import SwiftUI

struct ShopView: View {
    @State private var products: [Product] = []
    @State private var isLoading = true
    @State private var isPremium = false
    @State private var showAddProduct = false
    
    @StateObject private var cartManager = CartManager.shared
    @State private var showCart = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Tienda Pro")
                            .font(Theme.Typography.largeTitle)
                            .foregroundColor(Color(hex: "1A1A1A"))
                        Spacer()
                        
                        if isPremium {
                            Button(action: { showAddProduct = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.primary)
                            }
                            .padding(.trailing, 8)
                        }
                        
                        Button(action: { showCart = true }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "cart")
                                    .font(.title3)
                                    .foregroundColor(.black)
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                
                                if cartManager.itemCount > 0 {
                                    Text("\(cartManager.itemCount)")
                                        .font(.caption2.bold())
                                        .foregroundColor(.white)
                                        .frame(width: 18, height: 18)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 4, y: -4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    if isLoading {
                        ProductSkeletonGrid()
                    } else if products.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bag")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No hay productos disponibles")
                                .font(Theme.Typography.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(products) { product in
                                NavigationLink(destination: ProductDetailView(product: product)) {
                                    ProductCard(
                                        title: product.name,
                                        price: product.price,
                                        imageUrl: product.imageUrl,
                                        brand: product.brand,
                                        plusAction: {
                                            CartManager.shared.addToCart(product: product)
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 22)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(hex: "F8F9FA").ignoresSafeArea())
            .sheet(isPresented: $showAddProduct) {
                AddProductView().onDisappear {
                    loadProducts() // Refresh list when modal closes
                }
            }
            .sheet(isPresented: $showCart) {
                CartView()
            }
            .onAppear {
                checkPremiumStatus()
                loadProducts()
            }
            .navigationBarHidden(true)
        }
    }
    
    private func checkPremiumStatus() {
        SupabaseManager.shared.fetchProfile { result in
            if case .success(let profile) = result {
                DispatchQueue.main.async {
                    self.isPremium = profile.isPremium ?? false
                }
            }
        }
    }
    
    private func loadProducts() {
        SupabaseManager.shared.fetchProducts { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let fetchedProducts):
                    self.products = fetchedProducts
                case .failure(let error):
                    print("Error fetching products: \(error)")
                }
            }
        }
    }
}

// Skeleton Loading
struct ProductSkeletonGrid: View {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 160)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ShopView()
}
