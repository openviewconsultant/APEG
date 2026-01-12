import Foundation
import SwiftUI
import Combine

class CartManager: ObservableObject {
    static let shared = CartManager()
    
    @Published var items: [CartItem] = []
    
    struct CartItem: Identifiable, Codable {
        let id: UUID
        let product: Product
        var quantity: Int
        
        var subtotal: Double {
            return product.price * Double(quantity)
        }
    }
    
    private init() {}
    
    var total: Double {
        items.reduce(0) { $0 + $1.subtotal }
    }
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    func addToCart(product: Product, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(id: UUID(), product: product, quantity: quantity))
        }
    }
    
    func removeFromCart(product: Product) {
        items.removeAll(where: { $0.product.id == product.id })
    }
    
    func updateQuantity(product: Product, quantity: Int) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity = quantity
            if items[index].quantity <= 0 {
                items.remove(at: index)
            }
        }
    }
    
    func clearCart() {
        items = []
    }
    
    func placeOrder(shippingAddress: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = SupabaseManager.shared.currentUserId else {
            completion(.failure(NSError(domain: "CartManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])))
            return
        }
        
        // 1. Create the order
        let totalAmount = self.total
        let orderBody: [String: Any] = [
            "user_id": userId,
            "status": "completed",
            "total_amount": totalAmount,
            "shipping_address": shippingAddress
        ]
        
        SupabaseManager.shared.createOrder(body: orderBody) { result in
            switch result {
            case .success(let orderId):
                // 2. Create order items
                let itemsBody = self.items.map { item in
                    return [
                        "order_id": orderId,
                        "product_id": item.product.id.uuidString,
                        "quantity": item.quantity,
                        "price_at_purchase": item.product.price
                    ]
                }
                
                SupabaseManager.shared.createOrderItems(items: itemsBody) { itemResult in
                    switch itemResult {
                    case .success:
                        self.clearCart()
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
