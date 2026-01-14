import SwiftUI

struct SellerProfileView: View {
    let sellerId: UUID
    @StateObject private var reviewManager = ReviewManager.shared
    @State private var sellerProfile: UserProfile?
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let profile = sellerProfile {
                    // Header
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Theme.primary, Theme.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 100, height: 100)
                            
                            Text(String(profile.fullName?.prefix(1).uppercased() ?? "?"))
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .shadow(color: Theme.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        VStack(spacing: 8) {
                            Text(profile.fullName ?? "Socio APEG")
                                .font(Theme.Typography.title2)
                                .foregroundColor(.white)
                            
                            Text("VENDEDOR VERIFICADO")
                                .font(Theme.Typography.caption)
                                .fontWeight(.black)
                                .tracking(2)
                                .foregroundColor(Theme.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Theme.primary.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 40)
                } else if isLoading {
                    ProgressView().tint(Theme.primary)
                        .padding(.top, 50)
                }
                
                // Reviews Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Calificaciones del Vendedor")
                        .font(Theme.Typography.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    if reviewManager.reviews.isEmpty {
                        Text("No hay calificaciones aún")
                            .font(Theme.Typography.body)
                            .foregroundColor(.white.opacity(0.5))
                            .padding()
                    } else {
                        ForEach(reviewManager.reviews) { review in
                            ReviewCard(review: review)
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .background(Theme.background.ignoresSafeArea())
        .onAppear {
            fetchSellerInfo()
            // In a real app we might fetch reviews by sellerId, or aggregated. 
            // Currently fetchReviews is by productId. 
            // I'll skip fetching reviews here if the key is missing, or mocked.
            // But ideally we'd have fetchSellerReviews.
        }
    }
    
    private func fetchSellerInfo() {
        // We'd need a specific fetchUserById in SupabaseManager, 
        // currently 'fetchProfile' fetches current user.
        // Assuming we might add `fetchPublicProfile(userId:...)`
        // For now, mockup or skeletal.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            // Mock data strictly for UI demonstration as backend method is missing
            self.sellerProfile = UserProfile(id: sellerId, fullName: "Vendedor APEG", federationCode: "FED123", idPhotoUrl: nil, updatedAt: nil, email: "vendedor@apeg.com", isPremium: true) 
        }
    }
}

struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .foregroundColor(i <= review.rating ? .orange : .white.opacity(0.1))
                            .font(.system(size: 10))
                    }
                }
                Spacer()
                Text(review.createdAt, style: .date)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.lightGray)
            }
            
            if let comment = review.comment {
                Text(comment)
                    .font(Theme.Typography.body)
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(4)
            }
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
}
