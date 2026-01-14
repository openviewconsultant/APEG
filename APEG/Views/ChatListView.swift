import SwiftUI

struct ChatListView: View {
    @StateObject private var chatManager = ChatManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            if chatManager.isLoading {
                ProgressView().tint(Theme.primary)
            } else if chatManager.chats.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.15))
                    
                    Text("No tienes conversaciones activas")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.lightGray)
                        .tracking(0.5)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatManager.chats) { chat in
                            NavigationLink(destination: ChatDetailView(chat: chat)) {
                                ChatRow(chat: chat)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("MENSAJES")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            chatManager.fetchChats()
        }
    }
}

struct ChatRow: View {
    let chat: Chat
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.1))
                    .frame(width: 52, height: 52)
                
                Text(chat.product?.name.prefix(1).uppercased() ?? "?")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(Theme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.product?.name ?? "Producto Desconocido")
                    .font(Theme.Typography.headline)
                    .foregroundColor(.white)
                
                Text("Toca para ver mensajes")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.lightGray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.lightGray.opacity(0.5))
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Theme.softGreenBorder.opacity(0.1), lineWidth: 1)
        )
    }
}
