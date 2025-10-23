//
//  NotificacionDTO.swift
//  Fraud Fishing
//
//  Created by Usuario on 15/10/25.
//

import Foundation

struct NotificacionDTO: Decodable, Identifiable {
    let id: Int                
    let userId: Int            
    let title: String          
    let message: String        
    let relatedId: Int?        
    let isRead: Bool                
    let createdAt: String         
    let updatedAt: String
    
    // Custom decoding para manejar isRead como número (0/1) del servidor
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case message
        case relatedId
        case isRead
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        message = try container.decode(String.self, forKey: .message)
        relatedId = try container.decodeIfPresent(Int.self, forKey: .relatedId)
        
        // Convertir isRead de número (0/1) a booleano
        if let isReadInt = try? container.decode(Int.self, forKey: .isRead) {
            isRead = isReadInt != 0
        } else if let isReadBool = try? container.decode(Bool.self, forKey: .isRead) {
            isRead = isReadBool
        } else {
            isRead = false // valor por defecto
        }
        
        // Las fechas vienen como strings ISO8601 del backend
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

