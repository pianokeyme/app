//
//  ApiService.swift
//  KeyMe
//
//  Created by Roman Koval on 2022-12-01.
//

import Foundation

struct Recording: Codable {
    let audio_id: Int
    let audio_url: String
    let audio_version: Int
    let created_at: String
    let created_by: Int
    let id: Int
    let is_preprocessed: Bool
    let name: String
}

struct Preferences: Codable {
    let size: String
    let scheme: String
    let color: String
}

class ApiService: ObservableObject {
    private static let BASE_URL = "http://192.168.1.155:5001"
    
    static let shared = ApiService()
    
    @Published var recordings: [Recording] = []
    
    private init() {
    }
    
    func getAllRecordings() {
        let url = URL(string: ApiService.BASE_URL + "/api/recordings")!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                NSLog("error when sending request")
                return
            }

            guard let data = data else {
                return
            }
            
            do {
                let recordings = try JSONDecoder().decode([Recording].self, from: data)
                DispatchQueue.main.async {
                    self.recordings = recordings
                }
            } catch {
                NSLog("error when decoding data")
            }
        })

        task.resume()
    }
    
    func removeRecording(_ recording: Recording) {
        let url = URL(string: "\(ApiService.BASE_URL)/api/recording/\(recording.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                NSLog("error when sending request")
                return
            }
        }
        
        task.resume()
    }
    
    func savePreferences(_ preferences: Preferences) {
        guard let data = try? JSONEncoder().encode(preferences) else {
            return
        }
        
        let url = URL(string: "\(ApiService.BASE_URL)/api/preferences")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                NSLog("error when sending request")
                return
            }
        })
        
        task.resume()
    }
}
