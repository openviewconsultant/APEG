import SwiftUI

struct ChatDetailView: View {
    let chat: Chat
    @StateObject private var chatManager = ChatManager.shared
    @State private var newMessageText = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack(spacing: 16) {
                Button(action: { dismiss() }) {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay(Image(systemName: "chevron.left").foregroundColor(.white))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(chat.product?.name ?? "Producto")
                        .font(Theme.Typography.headline)
                        .foregroundColor(.white)
                    Text("Chat con vendedor")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.lightGray)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(BlurView(style: .systemUltraThinMaterialDark))
            
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatManager.currentMessages) { message in
                            MessageBubble(message: message, isCurrentUser: message.senderId.uuidString == SupabaseManager.shared.currentUserId)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatManager.currentMessages.count) { _ in
                    if let last = chatManager.currentMessages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Area
            HStack(spacing: 12) {
                TextField("Escribe un mensaje...", text: $newMessageText)
                    .padding(16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(24)
                    .foregroundColor(.white)
                
                Button(action: sendMessage) {
                    Circle()
                        .fill(Theme.primary)
                        .frame(width: 50, height: 50)
                        .overlay(Image(systemName: "paperplane.fill").foregroundColor(.white))
                        .shadow(color: Theme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(newMessageText.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(BlurView(style: .systemUltraThinMaterialDark))
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            chatManager.fetchMessages(chatId: chat.id)
        }
    }
    
    private func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        chatManager.sendMessage(chatId: chat.id, content: newMessageText)
        newMessageText = ""
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            Text(message.content)
                .font(Theme.Typography.body)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(isCurrentUser ? Theme.primary : Color.white.opacity(0.1))
                .foregroundColor(.white)
                .cornerRadius(20)
                .cornerRadius(isCurrentUser ? 4 : 20, corners: .bottomRight)
                .cornerRadius(!isCurrentUser ? 4 : 20, corners: .bottomLeft)
            
            if !isCurrentUser { Spacer() }
        }
    }
}


