import Foundation
import SwiftUI
import Combine

class ChatManager: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var currentMessages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    static let shared = ChatManager()
    
    private let supabase = SupabaseManager.shared
    
    func fetchChats() {
        guard let userId = supabase.currentUserId else { return }
        
        isLoading = true
        supabase.fetchChats(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let fetchedChats):
                    self?.chats = fetchedChats
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchMessages(chatId: UUID) {
        isLoading = true // don't clear messages immediately to avoid flicker, or do if preferred
        supabase.fetchMessages(chatId: chatId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let messages):
                    self?.currentMessages = messages
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func sendMessage(chatId: UUID, content: String) {
        guard let userId = supabase.currentUserId, let senderId = UUID(uuidString: userId) else { return }
        
        // Optimistic update could go here
        
        supabase.sendMessage(chatId: chatId, senderId: senderId, content: content) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Refresh messages to get the server-generated one (timestamp, id)
                    self?.fetchMessages(chatId: chatId)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func startChat(product: Product, completion: @escaping (UUID?) -> Void) {
        guard let userId = supabase.currentUserId, 
              let buyerId = UUID(uuidString: userId),
              let sellerId = product.sellerId else {
            completion(nil)
            return
        }
        
        // Optimistic check: if chat already exists locally? (Logic is simpler to just ask backend or check local list)
        if let existing = chats.first(where: { $0.productId == product.id }) {
            completion(existing.id)
            return
        }
        
        supabase.createChat(productId: product.id, sellerId: sellerId, buyerId: buyerId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let chatId):
                    self?.fetchChats() // Refresh list
                    completion(chatId)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(nil)
                }
            }
        }
    }
}
