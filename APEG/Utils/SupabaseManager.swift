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

    // MARK: - Rounds & Scores
    
    func fetchRounds(userId: String, completion: @escaping (Result<[Round], SupabaseError>) -> Void) {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/rounds?user_id=eq.\(userId)&select=*&order=date_played.desc") else {
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
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS+00:00"
                
                decoder.dateDecodingStrategy = .custom { decoder in
                     let container = try decoder.singleValueContainer()
                     let dateString = try container.decode(String.self)
                     if let date = formatter.date(from: dateString) { return date }
                     formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+00:00"
                     if let date = formatter.date(from: dateString) { return date }
                     // Try another common one if needed, or simple fallback
                     formatter.dateFormat = "yyyy-MM-dd"
                     if let date = formatter.date(from: dateString) { return date }
                     
                     throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
                
                let rounds = try decoder.decode([Round].self, from: data)
                completion(.success(rounds))
            } catch {
                print("Decoding rounds error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }

    
    func saveRound(userId: String, courseName: String, scores: [Int: Int], completion: @escaping (Result<Void, SupabaseError>) -> Void) {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/rounds") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        if let token = accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.addValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("representation", forHTTPHeaderField: "Prefer") // To maintain consistency, though we need the ID back
        request.addValue("return=representation", forHTTPHeaderField: "Prefer")
        
        let totalScore = scores.values.reduce(0, +)
        
        let body: [String: Any] = [
            "user_id": userId,
            "course_name": courseName,
            "total_score": totalScore,
            "status": "completed",
            "date_played": ISO8601DateFormatter().string(from: Date())
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                  let roundId = json.first?["id"] as? String else {
                completion(.failure(.decodingError))
                return
            }
            
            // Now save individual scores
            self.saveScores(roundId: roundId, scores: scores, completion: completion)
            
        }.resume()
    }
    
    private func saveScores(roundId: String, scores: [Int: Int], completion: @escaping (Result<Void, SupabaseError>) -> Void) {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/round_scores") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        if let token = accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let scoreObjects = scores.map { (hole, score) -> [String: Any] in
            return [
                "round_id": roundId,
                "hole_number": hole,
                "score": score,
                "par": 4 // Simplified, ideally gets par from course data
            ]
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: scoreObjects)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                completion(.success(()))
            } else {
                completion(.failure(.networkError("Failed to save scores")))
            }
        }.resume()
    }
    
    // MARK: - Products
    
    func fetchProducts(completion: @escaping (Result<[Product], SupabaseError>) -> Void) {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/products?select=*") else {
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
                // Handle Supabase timestamp format
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS+00:00"
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    
                    // Fallback for different fractional seconds
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+00:00"
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
                
                let products = try decoder.decode([Product].self, from: data)
                completion(.success(products))
            } catch {
                print("Decoding products error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}
