//
//  NotificacionController.swift
//  Fraud Fishing
//
//  Created by Usuario on 15/10/25.
//
import Foundation

@MainActor
final class NotificacionesController: ObservableObject {
    @Published var notificaciones: [NotificacionDTO] = []
    @Published var notificacionesAgrupadas: [(date: Date, items: [NotificacionDTO])] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasError = false
    
    private let client = HTTPClient()
    
    // MARK: - Public Methods
    
    /// Carga todas las notificaciones del usuario con paginación
    /// - Parameters:
    ///   - userId: ID del usuario
    ///   - limit: Límite de resultados (por defecto 50)
    ///   - offset: Desplazamiento para paginación (por defecto 0)
    ///   - forceRefresh: Si debe forzar la recarga (por defecto false)
    func cargarNotificaciones(userId: Int, limit: Int = 50, offset: Int = 0, forceRefresh: Bool = false) async {
        // Si ya estamos cargando, no hacer nada
        guard !isLoading || forceRefresh else { return }
        
        isLoading = true
        errorMessage = nil
        hasError = false
        
        do {
            let result = try await client.fetchNotificaciones(userId: userId, limit: limit, offset: offset)
            
            // Si es offset 0, reemplazar; si no, agregar
            if offset == 0 {
                self.notificaciones = result
            } else {
                self.notificaciones.append(contentsOf: result)
            }
            
            self.notificacionesAgrupadas = agruparPorFecha(self.notificaciones)
            print("✅ Notificaciones cargadas exitosamente: \(result.count)")
            
        } catch {
            print("❌ Error al obtener notificaciones: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            self.hasError = true
            
            // Si es la primera carga y falla, limpiar datos
            if offset == 0 {
                self.notificaciones = []
                self.notificacionesAgrupadas = []
            }
        }
        
        isLoading = false
    }
    
    /// Carga solo las notificaciones no leídas
    /// - Parameter userId: ID del usuario
    func cargarNotificacionesNoLeidas(userId: Int) async {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        do {
            let result = try await client.fetchUnreadNotifications(userId: userId)
            self.notificaciones = result
            self.notificacionesAgrupadas = agruparPorFecha(result)
            print("✅ Notificaciones no leídas cargadas: \(result.count)")
            
        } catch {
            print("❌ Error al obtener notificaciones no leídas: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            self.hasError = true
            self.notificaciones = []
            self.notificacionesAgrupadas = []
        }
        
        isLoading = false
    }
    
    /// Obtiene el conteo de notificaciones no leídas
    /// - Parameter userId: ID del usuario
    func obtenerConteoNoLeidas(userId: Int) async {
        do {
            let count = try await client.getUnreadNotificationsCount(userId: userId)
            self.unreadCount = count
            print("✅ Conteo de no leídas actualizado: \(count)")
            
        } catch {
            print("❌ Error al obtener conteo de no leídas: \(error.localizedDescription)")
            // No mostrar error para el conteo, solo loggearlo
        }
    }
    
    /// Refresca todas las notificaciones
    /// - Parameter userId: ID del usuario
    func refrescarNotificaciones(userId: Int) async {
        await cargarNotificaciones(userId: userId, forceRefresh: true)
        await obtenerConteoNoLeidas(userId: userId)
    }
    
    /// Limpia el estado de error
    func limpiarError() {
        errorMessage = nil
        hasError = false
    }
    
    /// Resetea todos los datos
    func reset() {
        notificaciones = []
        notificacionesAgrupadas = []
        unreadCount = 0
        errorMessage = nil
        hasError = false
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    /// Agrupa las notificaciones por fecha
    /// - Parameter items: Array de NotificacionDTO
    /// - Returns: Array de tuplas con fecha y notificaciones agrupadas
    private func agruparPorFecha(_ items: [NotificacionDTO]) -> [(Date, [NotificacionDTO])] {
        let calendar = Calendar.current
        let formatter = ISO8601DateFormatter()
        
        // Agrupar por día (sin hora)
        let grouped = Dictionary(grouping: items) { notification in
            let date = formatter.date(from: notification.createdAt) ?? Date()
            return calendar.startOfDay(for: date)
        }
        
        // Convertir a array de tuplas y ordenar por fecha descendente
        return grouped
            .map { (date, notifications) in
                // Ordenar notificaciones dentro del grupo por fecha descendente
                let sortedNotifications = notifications.sorted { 
                    let date1 = formatter.date(from: $0.createdAt) ?? Date()
                    let date2 = formatter.date(from: $1.createdAt) ?? Date()
                    return date1 > date2
                }
                return (date, sortedNotifications)
            }
            .sorted { $0.0 > $1.0 } // Orden descendente (hoy primero)
    }
}
