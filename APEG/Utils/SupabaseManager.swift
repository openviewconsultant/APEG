import Foundation
import UIKit

class SupabaseManager {
    static let shared = SupabaseManager()
    
    private let supabaseURL = "https://drqyvhwgnuvrcmwthwwn.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRycXl2aHdnbnV2cmNtd3Rod3duIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3ODQyNTUsImV4cCI6MjA4MzM2MDI1NX0.0wFIEqDhh9VfhMmktkRmqvErasLmZTkze3whmp54s3o"
    
    private init() {}
    
    enum SupabaseError: Error {
        case invalidURL
        case networkError(String)
        case decodingError
        case authError(String)
    }
    
    func signUp(email: String, password: String, fullName: String, federationCode: String, idImage: UIImage?, completion: @escaping (Result<Bool, SupabaseError>) -> Void) {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/signup") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "data": [
                "full_name": fullName,
                "federation_code": federationCode
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError("Invalid response")))
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                // Success - If there's an image, upload it
                if let image = idImage, let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let user = json["user"] as? [String: Any],
                   let userId = user["id"] as? String {
                    self.uploadIDPhoto(userId: userId, image: image) { _ in
                        completion(.success(true))
                    }
                } else {
                    completion(.success(true))
                }
            } else {
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let message = json["msg"] as? String ?? "Unknown error"
                    completion(.failure(.authError(message)))
                } else {
                    completion(.failure(.authError("Status code \(httpResponse.statusCode)")))
                }
            }
        }.resume()
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Bool, SupabaseError>) -> Void) {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError("Invalid response")))
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                completion(.success(true))
            } else {
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let message = json["error_description"] as? String ?? json["msg"] as? String ?? "Unknown error"
                    completion(.failure(.authError(message)))
                } else {
                    completion(.failure(.authError("Status code \(httpResponse.statusCode)")))
                }
            }
        }.resume()
    }
    
    private func uploadIDPhoto(userId: String, image: UIImage, completion: @escaping (Result<String, SupabaseError>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(.networkError("Could not process image")))
            return
        }
        
        let fileName = "\(userId)/cedula.jpg"
        guard let url = URL(string: "\(supabaseURL)/storage/v1/object/id-documents/\(fileName)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization") // Note: In a real app, use the actual user session token
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            // Even if storage fails, we already have the user created
            completion(.success(fileName))
        }.resume()
    }
}
