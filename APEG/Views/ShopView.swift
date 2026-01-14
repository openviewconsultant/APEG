import SwiftUI

struct ShopView: View {
    @State private var isLoading = true
    @AppStorage("isPremiumUser") private var isPremium = false
    @State private var showAddProduct = false
    @State private var products: [Product] = []
    
    @StateObject private var cartManager = CartManager.shared
    @State private var showCart = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    @State private var searchText = ""
    @State private var selectedCategory = "Todos"
    let categories = ["Todos", "Palos", "Ropa", "Accesorios", "Pelotas"]
    
    var filteredProducts: [Product] {
        var result = products
        
        // Filter by category
        if selectedCategory != "Todos" {
            // Since we don't have a category field in Product yet, we'll simulate or just return all for now.
            // In a real app, you'd filter: result = result.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tienda Pro")
                                    .font(Theme.Typography.largeTitle)
                                    .foregroundColor(.white)
                                Text("Equipamiento Premium")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                    .tracking(1)
                            }
                            
                            Spacer()
                            
                            if isPremium {
                                Button(action: { showAddProduct = true }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Theme.deepBlack)
                                        .padding(10)
                                        .background(Theme.primary)
                                        .clipShape(Circle())
                                }
                                .padding(.trailing, 8)
                            }
                            
                            Button(action: { showCart = true }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "cart")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Theme.cardBackground)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                    
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
                        .padding(.top, 20)
                        
                        // Search Bar
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.4))
                            TextField("Buscar productos...", text: $searchText)
                                .foregroundColor(.white)
                                .accentColor(Theme.primary)
                        }
                        .padding(16)
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                        .padding(.horizontal, 25)
                        
                        // Category Filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        withAnimation {
                                            selectedCategory = category
                                        }
                                    }) {
                                        Text(category)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(selectedCategory == category ? Theme.deepBlack : .white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(selectedCategory == category ? Theme.primary : Theme.cardBackground)
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(selectedCategory == category ? Theme.primary : Color.white.opacity(0.05), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 25)
                        }
                        
                        // Products Grid
                        if isLoading {
                            ProductSkeletonGrid()
                        } else if filteredProducts.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.2))
                                Text("No se encontraron productos")
                                    .font(Theme.Typography.body)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        } else {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(filteredProducts) { product in
                                    NavigationLink(destination: ProductDetailView(product: product)) {
                                        MarketingProductCard(
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
                            .padding(.bottom, 100) // Space for tab bar
                        }
                    }
                }
            }
            // Use .background here directly on the ZStack or outermost content, but ZStack already has background.
            // .background(Theme.background.ignoresSafeArea()) <--- already in ZStack
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
