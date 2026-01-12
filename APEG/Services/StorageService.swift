import Foundation
import UIKit

class StorageService {
    static let shared = StorageService()
    
    private let supabaseURL = "https://drqyvhwgnuvrcmwthwwn.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRycXl2aHdnbnV2cmNtd3Rod3duIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3ODQyNTUsImV4cCI6MjA4MzM2MDI1NX0.0wFIEqDhh9VfhMmktkRmqvErasLmZTkze3whmp54s3o"
    private let bucketName = "product-images"
    
    private init() {}
    
    /// Sube una imagen al bucket de Supabase Storage
    /// - Parameters:
    ///   - image: La imagen UIImage a subir
    ///   - productId: ID del producto (se usa para nombrar el archivo)
    /// - Returns: La URL pública de la imagen subida
    func uploadProductImage(_ image: UIImage, productId: UUID) async throws -> String {
        // Comprimir la imagen a JPEG con calidad 0.8
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.imageCompressionFailed
        }
        
        // Crear nombre único para el archivo
        let fileName = "\(productId.uuidString).jpg"
        
        // URL para subir el archivo
        guard let url = URL(string: "\(supabaseURL)/storage/v1/object/\(bucketName)/\(fileName)") else {
            throw StorageError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        // Usar el token de acceso si está disponible
        if let token = SupabaseManager.shared.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.addValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        }
        
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.addValue("upsert", forHTTPHeaderField: "x-upsert") // Permite sobrescribir
        request.httpBody = imageData
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: StorageError.uploadFailed(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    continuation.resume(throwing: StorageError.uploadFailed(NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    // Construir la URL pública
                    let publicURL = "\(self.supabaseURL)/storage/v1/object/public/\(self.bucketName)/\(fileName)"
                    continuation.resume(returning: publicURL)
                } else {
                    let errorMessage = "Failed to upload image. Status code: \(httpResponse.statusCode)"
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Upload error response: \(responseString)")
                    }
                    continuation.resume(throwing: StorageError.uploadFailed(NSError(domain: "StorageService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
            }.resume()
        }
    }
    
    /// Elimina una imagen del bucket de Supabase Storage
    /// - Parameter imageUrl: La URL de la imagen a eliminar
    func deleteProductImage(imageUrl: String) async throws {
        // Extraer el nombre del archivo de la URL
        guard let fileName = extractFileName(from: imageUrl) else {
            throw StorageError.invalidURL
        }
        
        guard let url = URL(string: "\(supabaseURL)/storage/v1/object/\(bucketName)/\(fileName)") else {
            throw StorageError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        if let token = SupabaseManager.shared.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.addValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    continuation.resume(throwing: StorageError.deleteFailed(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    continuation.resume(throwing: StorageError.deleteFailed(NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    continuation.resume()
                } else {
                    let errorMessage = "Failed to delete image. Status code: \(httpResponse.statusCode)"
                    continuation.resume(throwing: StorageError.deleteFailed(NSError(domain: "StorageService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
            }.resume()
        }
    }
    
    /// Extrae el nombre del archivo de una URL de Supabase Storage
    private func extractFileName(from url: String) -> String? {
        // La URL tiene el formato: https://[project].supabase.co/storage/v1/object/public/product-images/[filename]
        let components = url.components(separatedBy: "/")
        return components.last
    }
}

// MARK: - Storage Errors
enum StorageError: LocalizedError {
    case imageCompressionFailed
    case uploadFailed(Error)
    case deleteFailed(Error)
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .imageCompressionFailed:
            return "No se pudo comprimir la imagen"
        case .uploadFailed(let error):
            return "Error al subir la imagen: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Error al eliminar la imagen: \(error.localizedDescription)"
        case .invalidURL:
            return "URL de imagen inválida"
        }
    }
}
