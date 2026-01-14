//
//  ContentView.swift
//  APEG
//
//  Created by Edgar A. Barragán G. on 8/01/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some View {
        if isLoggedIn {
            MainTabView()
                .onAppear {
                    // Pre-emptively refresh token if we have one
                    SupabaseManager.shared.refreshSession { result in
                        if case .failure = result {
                            // If refresh fails, we might still be able to use current token 
                            // or we might need to logout. For safety, let's just log failure.
                            print("Refreshing session failed or not needed")
                        }
                    }
                }
        } else {
            AuthView()
        }
    }
}

#Preview {
    ContentView()
}
