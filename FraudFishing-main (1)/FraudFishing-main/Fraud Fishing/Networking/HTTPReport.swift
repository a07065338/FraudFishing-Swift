import Foundation

final class HTTPReport {
    private let executor = RequestExecutor()

    func searchReports(byURL urlString: String) async throws -> [ReportResponse] {
        var components = URLComponents(string: "http://localhost:3000/reports")
        components?.queryItems = [
            URLQueryItem(name: "url", value: urlString),
            URLQueryItem(name: "include", value: "tags"),
            URLQueryItem(name: "include", value: "category"),
            URLQueryItem(name: "limit", value: "50")
        ]
        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, _) = try await executor.send(request, requiresAuth: false)
        return try JSONDecoder().decode([ReportResponse].self, from: data)
    }
    
    // MARK: - Búsqueda avanzada de reportes
    /// Busca reportes con filtros avanzados
    /// - Parameters:
    ///   - status: Estado del reporte (opcional)
    ///   - userId: ID del usuario (opcional)
    ///   - categoryId: ID de la categoría (opcional)
    ///   - url: URL específica (opcional)
    ///   - sort: Tipo de ordenamiento ("popular" o "recent")
    ///   - include: Datos adicionales a incluir (["category", "tags", "status", "user"])
    ///   - page: Número de página (opcional)
    ///   - limit: Límite de resultados (opcional)
    /// - Returns: Array de reportes que coinciden con los filtros
    func searchReports(
        status: String? = nil,
        userId: Int? = nil,
        categoryId: Int? = nil,
        url: String? = nil,
        sort: String? = nil,
        include: [String]? = nil,
        page: Int? = nil,
        limit: Int? = nil
    ) async throws -> [ReportResponse] {
        
        var components = URLComponents(string: "http://localhost:3000/reports")
        var queryItems: [URLQueryItem] = []
        
        if let status = status { queryItems.append(URLQueryItem(name: "status", value: status)) }
        if let userId = userId { queryItems.append(URLQueryItem(name: "userId", value: String(userId))) }
        if let categoryId = categoryId { queryItems.append(URLQueryItem(name: "categoryId", value: String(categoryId))) }
        if let url = url { queryItems.append(URLQueryItem(name: "url", value: url)) }
        if let sort = sort { queryItems.append(URLQueryItem(name: "sort", value: sort)) }
        if let page = page { queryItems.append(URLQueryItem(name: "page", value: String(page))) }
        if let limit = limit { queryItems.append(URLQueryItem(name: "limit", value: String(limit))) }
        
        // Manejar el array de include como parámetros múltiples
        if let include = include {
            for item in include {
                queryItems.append(URLQueryItem(name: "include", value: item))
            }
        }
        
        components?.queryItems = queryItems
        
        guard let finalUrl = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        
        // Agregar autenticación si es necesario
        if let token = TokenStorage.get(.access) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                throw NSError(domain: "ServerError", code: serverError.statusCode, userInfo: [NSLocalizedDescriptionKey: serverError.message])
            } else {
                throw URLError(.badServerResponse, userInfo: [
                    NSLocalizedDescriptionKey: "Solicitud fallida. Código de estado: \(httpResponse.statusCode)",
                    "StatusCode": httpResponse.statusCode
                ])
            }
        }
        
        return try JSONDecoder().decode([ReportResponse].self, from: data)
    }

    func createReport(reportData: CreateReportRequest) async throws -> ReportResponse {
        guard let url = URL(string: "http://localhost:3000/reports") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = TokenStorage.get(.access) else {
            throw URLError(.userAuthenticationRequired)
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(reportData)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                throw NSError(domain: "ServerError", code: serverError.statusCode, userInfo: [NSLocalizedDescriptionKey: serverError.message])
            } else {
                throw URLError(.badServerResponse, userInfo: [
                    NSLocalizedDescriptionKey: "Solicitud fallida. Código de estado: \(httpResponse.statusCode)",
                    "StatusCode": httpResponse.statusCode
                ])
            }
        }
        
        if httpResponse.statusCode != 201 && httpResponse.statusCode != 200 {
             throw URLError(.badServerResponse, userInfo: [
                NSLocalizedDescriptionKey: "Respuesta de éxito inesperada. Código: \(httpResponse.statusCode). Se esperaba 201 o 200."
             ])
        }

        return try JSONDecoder().decode(ReportResponse.self, from: data)
    }
    
    // MARK: - Obtener reportes del usuario autenticado
    /// Obtiene los reportes del usuario autenticado filtrados por estado
    /// - Parameter status: 1 para pendientes, 2 para verificados
    /// - Returns: Array de reportes
    func getMyReports(status: Int) async throws -> [ReportResponse] {
        // Obtener el userId del token almacenado
        guard let userId = getUserIdFromToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        // Construir URL con query parameters
        var components = URLComponents(string: "http://localhost:3000/reports")
        components?.queryItems = [
            URLQueryItem(name: "status", value: "\(status)"),
            URLQueryItem(name: "userId", value: "\(userId)")
        ]
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let token = TokenStorage.get(.access) else {
            throw URLError(.userAuthenticationRequired)
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                throw NSError(domain: "ServerError", code: serverError.statusCode, userInfo: [NSLocalizedDescriptionKey: serverError.message])
            } else {
                throw URLError(.badServerResponse, userInfo: [
                    NSLocalizedDescriptionKey: "Solicitud fallida. Código de estado: \(httpResponse.statusCode)",
                    "StatusCode": httpResponse.statusCode
                ])
            }
        }

        return try JSONDecoder().decode([ReportResponse].self, from: data)
    }
    
    // MARK: - Helper para obtener userId del token
    /// Extrae el userId del token JWT almacenado
    /// - Returns: El ID del usuario o nil si no se puede extraer
    private func getUserIdFromToken() -> Int? {
        guard let token = TokenStorage.get(.access) else { return nil }
        
        // Dividir el token JWT en sus partes
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { return nil }
        
        // Decodificar el payload (segunda parte)
        let payload = parts[1]
        
        // Agregar padding si es necesario para Base64
        var paddedPayload = payload
        let remainder = payload.count % 4
        if remainder > 0 {
            paddedPayload += String(repeating: "=", count: 4 - remainder)
        }
        
        // Decodificar Base64
        guard let data = Data(base64Encoded: paddedPayload) else { return nil }
        
        // Parsear JSON
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let sub = json["sub"] as? String,
               let userId = Int(sub) {
                return userId
            }
        } catch {
            print("Error parsing JWT payload: \(error)")
        }
        
        return nil
    }
    
    
    // MARK: - Obtener todas las categorías disponibles
    func getCategories() async throws -> [CategoryDTO] {
        guard let url = URL(string: "http://localhost:3000/categories") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Agregar token si es necesario (depende de tu API)
        if let token = TokenStorage.get(.access) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                throw NSError(domain: "ServerError", code: serverError.statusCode,
                             userInfo: [NSLocalizedDescriptionKey: serverError.message])
            } else {
                throw URLError(.badServerResponse, userInfo: [
                    NSLocalizedDescriptionKey: "Error al obtener categorías. Código: \(httpResponse.statusCode)"
                ])
            }
        }
        
        return try JSONDecoder().decode([CategoryDTO].self, from: data)
    }

    // MARK: - Obtener categoría de un reporte específico
    func getReportCategory(reportId: Int) async throws -> ReportCategoryResponse {
        let url = URL(string: "http://localhost:3000/reports/\(reportId)/category")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = TokenStorage.get(.access) else {
            throw URLError(.userAuthenticationRequired)
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode,
                             userInfo: [NSLocalizedDescriptionKey: serverError.message])
            }
            throw URLError(.badServerResponse)
        }
        
        let categoryResponse = try JSONDecoder().decode(ReportCategoryResponse.self, from: data)
        return categoryResponse
    }
    
    // MARK: - Obtener tags de un reporte específico
    /// Obtiene las tags asociadas a un reporte
    /// - Parameter reportId: ID del reporte
    /// - Returns: Array de tags
    func getReportTags(reportId: Int) async throws -> [TagResponse] {
        guard let url = URL(string: "http://localhost:3000/reports/\(reportId)/tags") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let token = TokenStorage.get(.access) else {
            throw URLError(.userAuthenticationRequired)
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                throw NSError(domain: "ServerError", code: serverError.statusCode, userInfo: [NSLocalizedDescriptionKey: serverError.message])
            } else {
                throw URLError(.badServerResponse, userInfo: [
                    NSLocalizedDescriptionKey: "Solicitud fallida. Código de estado: \(httpResponse.statusCode)",
                    "StatusCode": httpResponse.statusCode
                ])
            }
        }
        
        return try JSONDecoder().decode([TagResponse].self, from: data)
    }
    
    // MARK: - Votar en un reporte
    /// Alterna el voto del usuario en un reporte específico
    /// - Parameter reportId: ID del reporte a votar
    /// - Returns: VoteResponse con el nuevo estado de votación
    func voteReport(reportId: Int) async throws -> VoteResponse {
        guard let url = URL(string: "http://localhost:3000/reports/\(reportId)/vote") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = TokenStorage.get(.access) else {
            throw URLError(.userAuthenticationRequired)
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                throw NSError(domain: "ServerError", code: serverError.statusCode, userInfo: [NSLocalizedDescriptionKey: serverError.message])
            } else {
                throw URLError(.badServerResponse, userInfo: [
                    NSLocalizedDescriptionKey: "Error al procesar el voto. Código de estado: \(httpResponse.statusCode)",
                    "StatusCode": httpResponse.statusCode
                ])
            }
        }
        
        return try JSONDecoder().decode(VoteResponse.self, from: data)
    }
}
