import Foundation
import UIKit

class SupabaseManager {
    static let shared = SupabaseManager()
    
    private let supabaseURL = "https://drqyvhwgnuvrcmwthwwn.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRycXl2aHdnbnV2cmNtd3Rod3duIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3ODQyNTUsImV4cCI6MjA4MzM2MDI1NX0.0wFIEqDhh9VfhMmktkRmqvErasLmZTkze3whmp54s3o"
    
    private init() {}
    
    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "supabaseAccessToken") }
        set { UserDefaults.standard.set(newValue, forKey: "supabaseAccessToken") }
    }
    
    var currentUserId: String? {
        get { UserDefaults.standard.string(forKey: "supabaseUserId") }
        set { UserDefaults.standard.set(newValue, forKey: "supabaseUserId") }
    }
    
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
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let accessToken = json["access_token"] as? String,
                   let user = json["user"] as? [String: Any],
                   let userId = user["id"] as? String {
                    
                    self.accessToken = accessToken
                    self.currentUserId = userId
                    completion(.success(true))
                } else {
                    // Fallback if structure is different, though this is standard Supabase
                    completion(.success(true))
                }
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
        
        // Use a generic name or keep using cedula.jpg. Ideally should be unique per upload if history matters.
        let fileName = "\(userId)/cedula_\(Int(Date().timeIntervalSince1970)).jpg"
        
        guard let url = URL(string: "\(supabaseURL)/storage/v1/object/id-documents/\(fileName)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        // Use the token if we have it, otherwise fallback to anon (though RLS might block anon)
        if let token = accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.addValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        }
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            completion(.success(fileName))
        }.resume()
    }
    
    func fetchProfile(completion: @escaping (Result<UserProfile, SupabaseError>) -> Void) {
        guard let userId = currentUserId, let token = accessToken else {
            completion(.failure(.authError("No active session")))
            return
        }
        
        guard let url = URL(string: "\(supabaseURL)/rest/v1/profiles?id=eq.\(userId)&select=*") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.decodingError))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                // Supabase standard format for timestamp is ISO8601
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS+00:00" 
                
                let profiles = try decoder.decode([UserProfile].self, from: data)
                if let profile = profiles.first {
                    completion(.success(profile))
                } else {
                    completion(.failure(.networkError("Profile not found")))
                }
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func updateProfile(userId: String, fullName: String, federationCode: String, email: String, completion: @escaping (Result<Bool, SupabaseError>) -> Void) {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/profiles?id=eq.\(userId)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        if let token = accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.addValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        let body: [String: Any] = [
            "full_name": fullName,
            "federation_code": federationCode,
            "email": email, 
            "updated_at": ISO8601DateFormatter().string(from: Date())
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
                    let message = json["message"] as? String ?? json["msg"] as? String ?? "Unknown error"
                    completion(.failure(.authError(message)))
                } else {
                    completion(.failure(.authError("Status code \(httpResponse.statusCode)")))
                }
            }
        }.resume()
    }
    
    func fetchPlayerStats(userId: String, completion: @escaping (Result<PlayerStats?, SupabaseError>) -> Void) {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/player_stats?user_id=eq.\(userId)&select=*") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        if let token = accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.addValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.decodingError))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let stats = try decoder.decode([PlayerStats].self, from: data)
                completion(.success(stats.first))
            } catch {
                print("Decoding stats error: \(error)")
                completion(.success(nil)) 
            }
        }.resume()
    }
}
