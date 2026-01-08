import SwiftUI

struct CaddieSelectionView: View {
    @State private var selectedFilter = "Todos"
    let filters = ["Todos", "Mejor Calificados", "Hándicap Bajo", "Nivel Pro"]
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    locationSummary
                    
                    filtersSection
                    
                    // Featured Caddie
                    CaddieCard(
                        name: "Michael T.",
                        rating: 4.9,
                        specialty: "Especialista de Campo",
                        hcp: 4,
                        price: 120,
                        rounds: 500,
                        isHorizontal: true
                    )
                    .padding(.horizontal)
                    
                    Text("Caddies Disponibles")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        CaddieCard(
                            name: "Sarah J.",
                            rating: 5.0,
                            specialty: "PGA Associate",
                            hcp: 2,
                            price: 150,
                            rounds: nil,
                            isHorizontal: false
                        )
                        
                        CaddieCard(
                            name: "David K.",
                            rating: 4.8,
                            specialty: "Leyenda Local",
                            hcp: 5,
                            price: 110,
                            rounds: nil,
                            isHorizontal: false
                        )
                        
                        CaddieCard(
                            name: "Emma R.",
                            rating: 5.0,
                            specialty: "Tour Exp.",
                            hcp: 0,
                            price: 200,
                            rounds: nil,
                            isHorizontal: false
                        )
                        
                        CaddieCard(
                            name: "James L.",
                            rating: 4.7,
                            specialty: "Caddie Master",
                            hcp: 7,
                            price: 100,
                            rounds: nil,
                            isHorizontal: false
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
                .padding(.vertical)
            }
        }
        .background(Color(hex: "F8F9FA").ignoresSafeArea())
    }
    
    private var header: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
                    .font(.title2)
            }
            
            Spacer()
            
            Text("Seleccionar Caddie")
                .font(.system(size: 18, weight: .bold))
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "calendar")
                    .foregroundColor(.black)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white)
    }
    
    private var locationSummary: some View {
        HStack(spacing: 16) {
            Image(systemName: "mappin.and.ellipse")
                .foregroundColor(Theme.primary)
                .padding(12)
                .background(Theme.primary.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text("UBICACIÓN Y HORA")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                Text("Pebble Beach • Mañana, 8:00 AM")
                    .font(.system(size: 14, weight: .bold))
            }
            
            Spacer()
            
            Button("Editar") {
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(Theme.primary)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(24)
        .padding(.horizontal)
        .shadow(color: Theme.Shadows.soft.color, radius: Theme.Shadows.soft.radius, x: Theme.Shadows.soft.x, y: Theme.Shadows.soft.y)
    }
    
    private var filtersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters, id: \.self) { filter in
                    Button(action: { selectedFilter = filter }) {
                        Text(filter)
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedFilter == filter ? Color.black : Color.white)
                            .foregroundColor(selectedFilter == filter ? .white : .black)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    CaddieSelectionView()
}
