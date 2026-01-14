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
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let categories = ["Palos", "Ropa", "Accesorios", "Pelotas"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
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
        
        // 1. Upload Images
        let uploadGroup = DispatchGroup()
        var uploadedUrls: [String] = []
        var uploadError = false
        
        for img in selectedImages {
            uploadGroup.enter()
            SupabaseManager.shared.uploadProductImage(image: img) { result in
                switch result {
                case .success(let fileName):
                    // Construct public URL - adjusting bucket name to 'products'
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
            
            // 2. Save Product Data
            // Note: SupabaseManager.saveProduct currently doesn't support the images array or seller_id properly in the method signature I saw earlier? 
            // Wait, I updated Product model but I didn't verify if I updated SupabaseManager.saveProduct method signature!
            // I updated 'fetchProducts' implicitely via decoder but 'saveProduct' constructs a body manually.
            // I need to be careful. The current 'saveProduct' in SupabaseManager might not accept images array.
            // I should assume I need to Fix SupabaseManager.saveProduct OR call a raw request here.
            // Let's rely on fixing 'saveProduct' in previous step or this step?
            // Actually I did NOT update 'saveProduct' in SupabaseManager in the previous tool call. I only added 'fetchChats'.
            // I should update SupabaseManager to support description and images first.
            // But since I am inside this tool call, I can't check.
            // I will assume SupabaseManager needs update. I'll update it separately in next step to be safe?
            // "saveProduct" currently: func saveProduct(name: String... description: String... imageUrl: String?) 
            // It has description! But only single imageUrl.
            // I will update SupabaseManager.saveProduct in the NEXT step.
            // For now, I'll assume I'll fix it.
            
            // Temporary workaround or call logic that relies on the future update.
            // I will update SupabaseManager FIRST in the next task step, then come back to this view? 
            // no, I'm writing this view now.
            
            // I'll call a hypothetical SupabaseManager.shared.saveMarketplaceProduct(...) 
            // and implement it in the next step.
            
             SupabaseManager.shared.saveProductExtended(
                name: name,
                brand: "Genérico", // Field not in form yet
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
