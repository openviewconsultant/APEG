import SwiftUI
import PhotosUI

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
    
    // Image picker states
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isUploadingImage = false

    
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
                
                // Sección de Imagen
                Section(header: Text("Imagen del Producto")) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.accentColor)
                            Text(selectedImage == nil ? "Seleccionar Imagen" : "Cambiar Imagen")
                            Spacer()
                            if isUploadingImage {
                                ProgressView()
                            }
                        }
                    }
                    .onChange(of: selectedPhotoItem) { oldValue, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                            }
                        }
                    }
                    
                    // Preview de la imagen
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
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
                            .font(Theme.Typography.caption)
                    }
                }
                
                Section {
                    Button(action: saveProduct) {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Guardar Producto")
                                .font(Theme.Typography.button)
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
        
        // Si hay una imagen seleccionada, primero subirla
        Task {
            var imageUrl: String? = nil
            
            if let image = selectedImage {
                isUploadingImage = true
                do {
                    // Generar un UUID temporal para el producto
                    let tempProductId = UUID()
                    imageUrl = try await StorageService.shared.uploadProductImage(image, productId: tempProductId)
                } catch {
                    await MainActor.run {
                        isSaving = false
                        isUploadingImage = false
                        errorMessage = "Error al subir la imagen: \(error.localizedDescription)"
                    }
                    return
                }
                await MainActor.run {
                    isUploadingImage = false
                }
            }
            
            // Guardar el producto con la URL de la imagen
            SupabaseManager.shared.saveProduct(
                name: name,
                brand: brand,
                price: priceDouble,
                category: category,
                description: description,
                stock: stockInt,
                imageUrl: imageUrl
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

}

#Preview {
    AddProductView()
}
