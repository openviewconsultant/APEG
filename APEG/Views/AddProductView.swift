import SwiftUI

struct AddProductView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var brand = ""
    @State private var price = ""
    @State private var category = ""
    @State private var description = ""
    @State private var stock = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    let categories = ["Bolas", "Palos", "Calzado", "Tecnología", "Accesorios", "Ropa"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información Básica")) {
                    TextField("Nombre del Producto", text: $name)
                    TextField("Marca", text: $brand)
                    TextField("Precio", text: $price)
                        .keyboardType(.decimalPad)
                    
                    Picker("Categoría", selection: $category) {
                        Text("Seleccionar").tag("")
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
                
                Section(header: Text("Detalles")) {
                    TextField("Cantidad en Stock", text: $stock)
                        .keyboardType(.numberPad)
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text("Descripción del producto...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.leading, 4)
                                        .padding(.top, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                        alignment: .topLeading
                        )
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: saveProduct) {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Guardar Producto")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(name.isEmpty || price.isEmpty || isSaving)
                }
            }
            .navigationTitle("Nuevo Producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func saveProduct() {
        guard let priceDouble = Double(price) else {
            errorMessage = "El precio debe ser un número válido."
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let stockInt = Int(stock) ?? 0
        
        // Use SupabaseManager to save (we need to add this method or use a generic one)
        SupabaseManager.shared.saveProduct(
            name: name,
            brand: brand,
            price: priceDouble,
            category: category,
            description: description,
            stock: stockInt
        ) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    errorMessage = "Error al guardar: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    AddProductView()
}
