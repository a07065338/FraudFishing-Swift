//
//  HTTPClient.swift
//  Testeo2.0
//
//  Created by Usuario on 06/10/25.
//

import Foundation

struct HTTPClient {
    
    // MARK: - Base URL
    let baseURL = "http://localhost:3000"
    
    func UserRegistration(_ request: UserRegisterRequest) async throws {
        guard let url = URL(string: "\(baseURL)/users") else {
            throw URLError(.badURL)
        }
        
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        httpRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        httpRequest.httpBody = try JSONEncoder().encode(request)
        
        // DEBUG: Imprimir lo que se envía
        if let jsonString = String(data: httpRequest.httpBody!, encoding: .utf8) {
            print("➡️ ENVIANDO A /users (Registro):")
            print(jsonString)
        }

        let (data, response) = try await URLSession.shared.data(for: httpRequest)
        
        // DEBUG: Imprimir lo que se recibe
        if let http = response as? HTTPURLResponse {
            print("⬅️ RECIBIDO DE /users (Registro):")
            print("Status Code: \(http.statusCode)")
            if let bodyString = String(data: data, encoding: .utf8), !bodyString.isEmpty {
                print("Cuerpo de la Respuesta (Raw): \(bodyString)")
            } else {
                print("Cuerpo de la Respuesta: (Vacío)")
            }
        }
        
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            print("❌ Error: El registro falló con un status de error.")
            throw NSError(domain: "HTTPClient", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: "El servidor respondió con un error."])
        }
        
    }
    
    func UserLogin(email: String, password: String) async throws -> UserLoginResponse {
            
        let loginRequest = UserLoginRequest(email: email, password: password)
        
        guard let url = URL(string: "http://localhost:3000/auth/login") else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // ✅ 1. Usamos 'try' para capturar errores de codificación.
        urlRequest.httpBody = try JSONEncoder().encode(loginRequest)
        
        // ✅ 2. Imprimimos el JSON para depurar y verificar qué se está enviando.
        if let body = urlRequest.httpBody, let jsonString = String(data: body, encoding: .utf8) {
            print("➡️ ENVIANDO A /auth/login:")
            print(jsonString)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // Imprimimos la respuesta del servidor para tener más contexto.
        if let httpResponse = response as? HTTPURLResponse {
            print("⬅️ RESPUESTA DE /auth/login (Status: \(httpResponse.statusCode))")
            if let bodyString = String(data: data, encoding: .utf8) {
                print("Cuerpo: \(bodyString)")
            }
        }
        
        guard let httpresponse = response as? HTTPURLResponse,
              (200...299).contains(httpresponse.statusCode) else {
            // Este error se lanzará si el status no es 2xx (ej. 401 Unauthorized)
            throw URLError(.badServerResponse)
        }
        
        let loginResponse = try JSONDecoder().decode(UserLoginResponse.self, from: data)
        return loginResponse
    }
    
    func refreshAccessToken(refreshToken: String) async throws -> String{
        let refreshRequest = RefreshRequest(refreshToken: refreshToken)
        guard let url = URL(string: "http://localhost:3000/auth/refresh") else {
            throw URLError(.badURL)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(refreshRequest)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpresponse = response as? HTTPURLResponse,
              (200...299).contains(httpresponse.statusCode) else{
            throw URLError(.userAuthenticationRequired)
        }
        
        let decoded = try JSONDecoder().decode(RefreshResponse.self, from: data)
        return decoded.accessToken
        
        
    }
    
}
