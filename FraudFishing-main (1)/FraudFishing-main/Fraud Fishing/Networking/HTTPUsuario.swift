import Foundation

struct HTTPUsuario {
    func getUserProfile() async throws -> UserProfile {
        
        guard let url = URL(string: "http://localhost:3000/users/me") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let token = TokenStorage.get(.access) else {
            throw URLError(.userAuthenticationRequired)
        }
        
        // 2. Agregamos el encabezado de autorización.
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Imprimimos para depurar y ver que el token se está enviando
        print(" Petición a /users/me con Token: Bearer \(token)")

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print(" Error: No se pudo obtener el perfil. Status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            throw URLError(.badServerResponse)
        }
        
        // Decodificamos la respuesta en nuestro nuevo modelo.
        let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
        print(" Perfil de usuario recibido: \(userProfile.name)")
        return userProfile
    }
    
    // MARK: - Update User Profile
    func updateUserProfile(name: String?, email: String?, password: String?) async throws -> UserProfile {
        
        guard let url = URL(string: "http://localhost:3000/users/me") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT" //  método PUT para actualizar
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // --- Autenticación (igual que en GET) ---
        guard let token = TokenStorage.get(.access) else {
            throw URLError(.userAuthenticationRequired)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // --- Construcción del Cuerpo Opcional ---
        // 1. Creamos el DTO con los valores que recibimos.
        let updateData = UpdateUserDTO(name: name, email: email, password: password)
        
        // 2. Codificamos el DTO. JSONEncoder omitirá las propiedades 'nil'.
        request.httpBody = try JSONEncoder().encode(updateData)
        
        // Imprimimos para depurar y ver qué se envía exactamente.
        if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
            print("➡️ ENVIANDO PUT a /users/me:")
            print(jsonString)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("❌ Error: No se pudo actualizar el perfil. Status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            if let body = String(data: data, encoding: .utf8) { print("Error Body: \(body)") }
            throw URLError(.badServerResponse)
        }
        
        // Decodificamos la respuesta (el perfil actualizado)
        let updatedProfile = try JSONDecoder().decode(UserProfile.self, from: data)
        print("✅ Perfil actualizado con éxito: \(updatedProfile.name)")
        return updatedProfile
    }
}
