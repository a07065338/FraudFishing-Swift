//
//  AjustesDTO.swift
//  Fraud Fishing
//
//  Creado a partir de ScreenAjustes.swift
//

import Foundation

/// DTO que representa la configuración de ajustes del usuario.
struct AjustesDTO: Codable {
    var usuarioId: String               // ID del usuario en la base de datos
    var notificacionesActivadas: Bool   // Estado de notificaciones
    var fechaUltimaActualizacion: Date? // Fecha opcional de última modificación
    
    // MARK: - Inicializador
    init(
        usuarioId: String,
        notificacionesActivadas: Bool,
        fechaUltimaActualizacion: Date? = nil
    ) {
        self.usuarioId = usuarioId
        self.notificacionesActivadas = notificacionesActivadas
        self.fechaUltimaActualizacion = fechaUltimaActualizacion
    }
}