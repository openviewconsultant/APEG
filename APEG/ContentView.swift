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
        } else {
            AuthView()
        }
    }
}

#Preview {
    ContentView()
}
