import SwiftUI
import PhotosUI

struct ProductEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var price = ""
    @State private var description = ""
    @State private var category = "Palos"
    @State private var stock = "1"
    
    // Images
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @AppStorage("isPremiumUser") private var isPremium = false
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let categories = ["Palos", "Ropa", "Accesorios", "Pelotas"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if !isPremium {
                    VStack(spacing: 20) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        Text("Membresía Gold Requerida")
                            .font(Theme.Typography.title2)
                            .foregroundColor(.white)
                        Text("Solo los socios Gold pueden vender productos.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        Button("Cerrar") {
                            dismiss()
                        }
                        .padding()
                        .background(Theme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Section: Information
                            VStack(alignment: .leading, spacing: 20) {
                                Text("INFORMACIÓN BÁSICA")
                                    .font(Theme.Typography.caption)
                                    .kerning(4)
                                    .foregroundColor(.white.opacity(0.4))
                                    .padding(.horizontal, 10)
                                
                                VStack(spacing: 16) {
                                    CustomTextField(icon: "tag", placeholder: "Nombre del Producto", text: $name)
                                    CustomTextField(icon: "dollarsign.circle", placeholder: "Precio", text: $price)
                                        .keyboardType(.decimalPad)
                                    
                                    HStack {
                                        Image(systemName: "list.bullet")
                                            .foregroundColor(.white.opacity(0.6))
                                            .frame(width: 20)
                                        Picker("", selection: $category) {
                                            ForEach(categories, id: \.self) { cat in
                                                Text(cat).tag(cat)
                                            }
                                        }
                                        .accentColor(.white)
                                    }
                                    .padding(20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Theme.cardBackground)
                                    .cornerRadius(20)
                                }
                            }
                            
                            // Section: Detail
                            VStack(alignment: .leading, spacing: 20) {
                                Text("DESCRIPCIÓN")
                                    .font(Theme.Typography.caption)
                                    .kerning(4)
                                    .foregroundColor(.white.opacity(0.4))
                                    .padding(.horizontal, 10)
                                
                                TextEditor(text: $description)
                                    .frame(height: 120)
                                    .padding(16)
                                    .background(Theme.cardBackground)
                                    .cornerRadius(24)
                                    .foregroundColor(.white)
                                    .overlay(
                                        Text("Describe tu producto en detalle...")
                                            .foregroundColor(.white.opacity(0.2))
                                            .padding(20)
                                            .opacity(description.isEmpty ? 1 : 0),
                                        alignment: .topLeading
                                    )
                            }
                            
                            // Section: Photos
                            VStack(alignment: .leading, spacing: 20) {
                                Text("FOTOS (MÁX 3)")
                                    .font(Theme.Typography.caption)
                                    .kerning(4)
                                    .foregroundColor(.white.opacity(0.4))
                                    .padding(.horizontal, 10)
                                
                                HStack(spacing: 12) {
                                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 3, matching: .images) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                                .font(.title2)
                                            Text("Añadir")
                                                .font(Theme.Typography.caption)
                                        }
                                        .frame(width: 100, height: 100)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(24)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        )
                                    }
                                    
                                    ForEach(selectedImages, id: \.self) { img in
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 24))
                                    }
                                }
                            }
                            
                            // Publish Button
                            Button(action: saveProduct) {
                                ZStack {
                                    if isUploading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("PUBLICAR PRODUCTO")
                                            .tracking(1)
                                            .font(Theme.Typography.button)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(name.isEmpty || price.isEmpty ? Color.gray : Theme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(32)
                                .shadow(color: Theme.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                            }
                            .disabled(name.isEmpty || price.isEmpty || isUploading)
                            .padding(.top, 20)
                        }
                        .padding(25)
                    }
                }
            }
            .navigationTitle("VENDER")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.white)
                }
            }
            .onChange(of: selectedItems) { newItems in
                Task {
                    selectedImages = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImages.append(image)
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Estado"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    if alertMessage.contains("exitosamente") {
                        dismiss()
                    }
                })
            }
        }
    }
    
    private func saveProduct() {
        guard let priceVal = Double(price), let stockVal = Int(stock) else {
            alertMessage = "Precio o stock inválido"
            showAlert = true
            return
        }
        
        isUploading = true
        
        let uploadGroup = DispatchGroup()
        var uploadedUrls: [String] = []
        var uploadError = false
        
        for img in selectedImages {
            uploadGroup.enter()
            SupabaseManager.shared.uploadProductImage(image: img) { result in
                switch result {
                case .success(let fileName):
                    let publicUrl = "https://drqyvhwgnuvrcmwthwwn.supabase.co/storage/v1/object/public/products/\(fileName)"
                    uploadedUrls.append(publicUrl)
                case .failure:
                    uploadError = true
                }
                uploadGroup.leave()
            }
        }
        
        uploadGroup.notify(queue: .main) {
            if uploadError {
                isUploading = false
                alertMessage = "Error al subir imágenes"
                showAlert = true
                return
            }
            
            SupabaseManager.shared.saveProductExtended(
                name: name,
                brand: "Genérico",
                price: priceVal,
                category: category,
                description: description,
                stock: stockVal,
                images: uploadedUrls,
                sellerId: SupabaseManager.shared.currentUserId ?? ""
            ) { result in
                isUploading = false
                switch result {
                case .success:
                    alertMessage = "Producto publicado exitosamente"
                    showAlert = true
                case .failure(let error):
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}
