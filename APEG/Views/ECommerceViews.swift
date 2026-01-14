import SwiftUI

struct CartView: View {
    @StateObject private var cartManager = CartManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showCheckout = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if cartManager.items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart.badge.minus")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("Tu carrito está vacío")
                            .font(Theme.Typography.title3)
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Text("Ir a comprar")
                                .font(Theme.Typography.button)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Theme.primary)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal, 40)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(cartManager.items) { item in
                                CartItemRow(item: item)
                            }
                        }
                        .padding()
                    }
                    VStack(spacing: 20) {
                        Divider()
                        HStack {
                            Text("Total")
                                .font(Theme.Typography.title3)
                            Spacer()
                            Text("$\(Int(cartManager.total))")
                                .font(Theme.Typography.title2)
                                .foregroundColor(Theme.primary)
                        }
                        .padding(.horizontal)
                        
                        Button(action: { 
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            showCheckout = true 
                        }) {
                            Text("Finalizar Compra")
                                .font(Theme.Typography.button)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Theme.primary)
                                .cornerRadius(15)
                        }
                        .navigationDestination(isPresented: $showCheckout) {
                            CheckoutView()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .background(Theme.pureWhite)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
                }
            }
            .navigationTitle("Mi Carrito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}

struct CartItemRow: View {
    let item: CartManager.CartItem
    @StateObject private var cartManager = CartManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Image Placeholder or AsyncImage
            Group {
                if let urlString = item.product.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                } else {
                    Color.gray.opacity(0.1)
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                }
            }
            .frame(width: 80, height: 80)
            .cornerRadius(15)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(Theme.Typography.body)
                Text("$\(Int(item.product.price))")
                    .font(.caption)
                    .foregroundColor(Theme.primary)
                
                HStack(spacing: 15) {
                    Button(action: { cartManager.updateQuantity(product: item.product, quantity: item.quantity - 1) }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(.gray)
                    }
                    Text("\(item.quantity)")
                        .font(Theme.Typography.body)
                    Button(action: { cartManager.updateQuantity(product: item.product, quantity: item.quantity + 1) }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(Theme.primary)
                    }
                }
                .padding(.top, 4)
            }
            
            Spacer()
            
            Button(action: { cartManager.removeFromCart(product: item.product) }) {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.7))
            }
        }
        .padding()
        .background(Theme.pureWhite)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
}

struct CheckoutView: View {
    @StateObject private var cartManager = CartManager.shared
    @State private var address = ""
    @State private var isProcessing = false
    @State private var showSuccess = false
    @State private var error: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dirección de Envío")
                        .font(Theme.Typography.headline)
                    TextEditor(text: $address)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Método de Pago")
                        .font(Theme.Typography.headline)
                    
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text("Tarjeta de Crédito (Simulado)")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.primary)
                    }
                    .padding()
                    .background(Theme.primary.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.primary.opacity(0.2), lineWidth: 1))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Resumen")
                        .font(Theme.Typography.headline)
                    
                    HStack {
                        Text("Subtotal")
                            .font(Theme.Typography.body)
                        Spacer()
                        Text("$\(Int(cartManager.total))")
                    }
                    HStack {
                        Text("Envío")
                        Spacer()
                        Text("Gratis")
                    }
                    Divider()
                    HStack {
                        Text("Total")
                            .font(Theme.Typography.headline)
                        Spacer()
                        Text("$\(Int(cartManager.total))")
                            .font(Theme.Typography.title2)
                            .foregroundColor(Theme.primary)
                    }
                }
                .padding()
                .background(Theme.pureWhite)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(Theme.Typography.caption)
                        .padding(.top, 10)
                }
                
                Button(action: processPayment) {
                    if isProcessing {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Pagar Ahora")
                            .font(Theme.Typography.button)
                    }
                }
                .disabled(address.isEmpty || isProcessing)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(address.isEmpty ? Color.gray : Theme.primary)
                .cornerRadius(15)
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Pago")
        .fullScreenCover(isPresented: $showSuccess) {
            OrderSuccessView()
        }
    }
    
    func processPayment() {
        isProcessing = true
        error = nil
        
        // Simular retardo de red
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            cartManager.placeOrder(shippingAddress: address) { result in
                isProcessing = false
                switch result {
                case .success:
                    showSuccess = true
                case .failure(let err):
                    error = err.localizedDescription
                }
            }
        }
    }
}

struct OrderSuccessView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 150, height: 150)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 12) {
                Text("¡Compra Exitosa!")
                    .font(Theme.Typography.largeTitle)
                Text("Tu pedido ha sido procesado y está en camino a tu dirección.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            Button(action: {
                // Dimiss all and go back to shop
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.dismiss(animated: true)
                }
            }) {
                Text("Volver a la Tienda")
                    .font(Theme.Typography.button)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.primary)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 60)
            .padding(.top, 40)
        }
    }
}

struct MyOrdersView: View {
    @State private var orders: [OrderResponse] = []
    @State private var isLoading = true
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if orders.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart.badge.questionmark")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("Aún no tienes pedidos")
                            .font(Theme.Typography.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 100)
                } else {
                    ForEach(orders) { order in
                        OrderRow(order: order)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Mis Pedidos")
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.background.ignoresSafeArea())
        .onAppear(perform: loadOrders)
    }
    
    func loadOrders() {
        SupabaseManager.shared.fetchOrders { result in
            DispatchQueue.main.async {
                self.isLoading = false
                if case .success(let fetchedOrders) = result {
                    self.orders = fetchedOrders
                }
            }
        }
    }
}

struct OrderRow: View {
    let order: OrderResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pedido #\(order.id.uuidString.prefix(8).uppercased())")
                        .font(Theme.Typography.headline)
                    Text(order.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(Theme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(order.status.uppercased())
                    .font(Theme.Typography.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            Divider()
            
            HStack {
                Text("\(order.orderItems.count) artículos")
                    .font(Theme.Typography.body)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Total: $\(Int(order.totalAmount))")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.primary)
            }
        }
        .padding()
        .background(Theme.pureWhite)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
    
    var statusColor: Color {
        switch order.status.lowercased() {
        case "completed": return .green
        case "pending": return .orange
        case "cancelled": return .red
        default: return .blue
        }
    }
}

#Preview {
    CartView()
}
