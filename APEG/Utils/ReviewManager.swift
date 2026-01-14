import Foundation
import Combine

class ReviewManager: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    static let shared = ReviewManager()
    private let supabase = SupabaseManager.shared
    
    func fetchReviews(productId: UUID) {
        isLoading = true
        supabase.fetchReviews(productId: productId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let reviews):
                    self?.reviews = reviews
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Future: Add createReview method here
}
