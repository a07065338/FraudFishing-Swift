//
//  HTTPNoti.swift
//  Fraud Fishing
//
//  Created by Usuario on 15/10/25.
//

import Foundation

// MARK: - Notification Errors
enum NotificationError: LocalizedError {
    case invalidUserId
    case unauthorized
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int, String?)
    
    var errorDescription: String? {
        switch self {
        case .invalidUserId:
            return "ID de usuario inválido"
        case .unauthorized:
            return "No autorizado. Por favor, inicia sesión nuevamente"
        case .networkError(let error):
            return "Error de conexión: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Error al procesar datos: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Error del servidor (\(code)): \(message ?? "Error desconocido")"
        }
    }
}

extension HTTPClient {
    
    // MARK: - Fetch All Notifications
    /// Obtiene todas las notificaciones de un usuario con paginación
    /// - Parameters:
    ///   - userId: ID del usuario
    ///   - limit: Límite de resultados (por defecto 50)
    ///   - offset: Desplazamiento para paginación (por defecto 0)
    /// - Returns: Array de NotificacionDTO
    func fetchNotificaciones(userId: Int, limit: Int = 50, offset: Int = 0) async throws -> [NotificacionDTO] {
        guard userId > 0 else {
            throw NotificationError.invalidUserId
        }
        
        // Construir URL con parámetros de consulta
        var components = URLComponents(string: "\(baseURL)/notifications/user/\(userId)")
        components?.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Agregar token de autenticación
        if let token = TokenStorage.get(.access) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NotificationError.unauthorized
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NotificationError.networkError(URLError(.badServerResponse))
            }

            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                // Debug: Imprimir la respuesta cruda del servidor
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Respuesta del servidor: \(jsonString)")
                }
                
                do {
                    let notificaciones = try decoder.decode([NotificacionDTO].self, from: data)
                    print("✅ Notificaciones cargadas exitosamente: \(notificaciones.count)")
                    return notificaciones
                } catch {
                    print("❌ Error decodificando notificaciones: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("❌ JSON que causó el error: \(jsonString)")
                    }
                    throw NotificationError.decodingError(error)
                }
                
            case 401:
                throw NotificationError.unauthorized
                
            case 403:
                let errorMessage = String(data: data, encoding: .utf8)
                throw NotificationError.serverError(403, errorMessage ?? "Acceso denegado")
                
            default:
                let errorMessage = String(data: data, encoding: .utf8)
                print("❌ Error HTTP [\(httpResponse.statusCode)]: \(errorMessage ?? "Sin mensaje")")
                throw NotificationError.serverError(httpResponse.statusCode, errorMessage)
            }
            
        } catch let error as NotificationError {
            throw error
        } catch {
            print("❌ Error de red: \(error)")
            throw NotificationError.networkError(error)
        }
    }
    
    // MARK: - Fetch Unread Notifications
    /// Obtiene solo las notificaciones no leídas de un usuario
    /// - Parameter userId: ID del usuario
    /// - Returns: Array de NotificacionDTO no leídas
    func fetchUnreadNotifications(userId: Int) async throws -> [NotificacionDTO] {
        guard userId > 0 else {
            throw NotificationError.invalidUserId
        }
        
        guard let url = URL(string: "\(baseURL)/notifications/user/\(userId)/unread") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Agregar token de autenticación
        if let token = TokenStorage.get(.access) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NotificationError.unauthorized
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NotificationError.networkError(URLError(.badServerResponse))
            }

            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                // Debug: Imprimir la respuesta cruda del servidor
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Respuesta del servidor (unread): \(jsonString)")
                }
                
                do {
                    let notificaciones = try decoder.decode([NotificacionDTO].self, from: data)
                    print("✅ Notificaciones no leídas cargadas: \(notificaciones.count)")
                    return notificaciones
                } catch {
                    print("❌ Error decodificando notificaciones no leídas: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("❌ JSON que causó el error (unread): \(jsonString)")
                    }
                    throw NotificationError.decodingError(error)
                }
                
            case 401:
                throw NotificationError.unauthorized
                
            case 403:
                let errorMessage = String(data: data, encoding: .utf8)
                throw NotificationError.serverError(403, errorMessage ?? "Acceso denegado")
                
            default:
                let errorMessage = String(data: data, encoding: .utf8)
                print("❌ Error HTTP [\(httpResponse.statusCode)]: \(errorMessage ?? "Sin mensaje")")
                throw NotificationError.serverError(httpResponse.statusCode, errorMessage)
            }
            
        } catch let error as NotificationError {
            throw error
        } catch {
            print("❌ Error de red: \(error)")
            throw NotificationError.networkError(error)
        }
    }
    
    // MARK: - Get Unread Count
    /// Obtiene el conteo de notificaciones no leídas
    /// - Parameter userId: ID del usuario
    /// - Returns: Número de notificaciones no leídas
    func getUnreadNotificationsCount(userId: Int) async throws -> Int {
        guard userId > 0 else {
            throw NotificationError.invalidUserId
        }
        
        guard let url = URL(string: "\(baseURL)/notifications/user/\(userId)/unread-count") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Agregar token de autenticación
        if let token = TokenStorage.get(.access) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NotificationError.unauthorized
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NotificationError.networkError(URLError(.badServerResponse))
            }

            switch httpResponse.statusCode {
            case 200:
                do {
                    let countResponse = try JSONDecoder().decode(UnreadCountResponse.self, from: data)
                    print("✅ Conteo de no leídas obtenido: \(countResponse.count)")
                    return countResponse.count
                } catch {
                    print("❌ Error decodificando conteo: \(error)")
                    throw NotificationError.decodingError(error)
                }
                
            case 401:
                throw NotificationError.unauthorized
                
            case 403:
                let errorMessage = String(data: data, encoding: .utf8)
                throw NotificationError.serverError(403, errorMessage ?? "Acceso denegado")
                
            default:
                let errorMessage = String(data: data, encoding: .utf8)
                print("❌ Error HTTP [\(httpResponse.statusCode)]: \(errorMessage ?? "Sin mensaje")")
                throw NotificationError.serverError(httpResponse.statusCode, errorMessage)
            }
            
        } catch let error as NotificationError {
            throw error
        } catch {
            print("❌ Error de red: \(error)")
            throw NotificationError.networkError(error)
        }
    }
}

// MARK: - Response Models
struct UnreadCountResponse: Codable {
    let count: Int
}
