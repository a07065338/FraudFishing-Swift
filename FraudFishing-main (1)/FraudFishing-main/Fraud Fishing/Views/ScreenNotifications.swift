//
//  ScreenNotifications.swift
//  Fraud Fishing
//
//  Created by Ferro Ramos on 01/10/25.
//

import SwiftUI

struct Notification: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let description: String
    let date: String
    let isRead: Bool
}

enum NotificationType {
    case approved
    case inReview
    case denied
    
    var icon: String {
        switch self {
        case .approved:
            return "checkmark.circle.fill"
        case .inReview:
            return "clock.fill"
        case .denied:
            return "xmark.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .approved:
            return .green
        case .inReview:
            return .blue
        case .denied:
            return .red
        }
    }
}

struct ScreenNotifications: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller = NotificacionesController()
    @State private var showingUnreadOnly = false
    @State private var isRefreshing = false
    
    // Obtener el AuthController del environment
    @EnvironmentObject var authController: AuthenticationController

    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                headerView
                
                if controller.hasError {
                    errorView
                } else {
                    contentView
                }
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .refreshable {
                await refreshNotifications()
            }
        }
        .task {
            await loadInitialData()
        }
        .alert("Error", isPresented: $controller.hasError) {
            Button("Reintentar") {
                Task {
                    await loadInitialData()
                }
            }
            Button("Cancelar", role: .cancel) {
                controller.limpiarError()
            }
        } message: {
            Text(controller.errorMessage ?? "Error desconocido")
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.043, green: 0.090, blue: 0.205, opacity: 0.89),
                Color(red: 0.043, green: 0.067, blue: 0.31)
            ]),
            startPoint: UnitPoint(x: 0.5, y: 0.7),
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                backButton
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notificaciones")
                        .font(.poppinsMedium(size: 28))
                        .foregroundColor(.white)
                    
                    if controller.unreadCount > 0 {
                        Text("\(controller.unreadCount) sin leer")
                            .font(.poppinsRegular(size: 14))
                            .foregroundColor(Color(red: 0.0, green: 0.71, blue: 0.737))
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Botón de filtro
                filterButton
            }
            
            // Indicador de filtro activo
            if showingUnreadOnly {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .foregroundColor(Color(red: 0.0, green: 0.71, blue: 0.737))
                    Text("Mostrando solo no leídas")
                        .font(.poppinsRegular(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top)
        .padding(.bottom, 20)
    }
    
    private var backButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color(red: 0.0, green: 0.71, blue: 0.737))
                .clipShape(Circle())
        }
        .padding(.leading)
    }
    
    private var filterButton: some View {
        Button(action: {
            showingUnreadOnly.toggle()
            Task {
                guard let userId = authController.getCurrentUserId() else {
                    controller.errorMessage = "No se pudo obtener el ID del usuario"
                    controller.hasError = true
                    return
                }
                
                if showingUnreadOnly {
                    await controller.cargarNotificacionesNoLeidas(userId: userId)
                } else {
                    await controller.cargarNotificaciones(userId: userId, forceRefresh: true)
                }
            }
        }) {
            Image(systemName: showingUnreadOnly ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                .font(.title2)
                .foregroundColor(showingUnreadOnly ? Color(red: 0.0, green: 0.71, blue: 0.737) : .white)
                .padding()
                .background(Color.white.opacity(showingUnreadOnly ? 0.15 : 0.1))
                .clipShape(Circle())
        }
        .padding(.trailing)
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red.opacity(0.7))
            
            Text("Error al cargar notificaciones")
                .font(.poppinsMedium(size: 18))
                .foregroundColor(.white)
            
            Text(controller.errorMessage ?? "Error desconocido")
                .font(.poppinsRegular(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Reintentar") {
                Task {
                    await loadInitialData()
                }
            }
            .font(.poppinsMedium(size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(red: 0.0, green: 0.71, blue: 0.737))
            .cornerRadius(8)
        }
        .padding(.top, 80)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if controller.isLoading && controller.notificacionesAgrupadas.isEmpty {
            loadingView
        } else if controller.notificacionesAgrupadas.isEmpty {
            EmptyNotificationsView(showingUnreadOnly: showingUnreadOnly)
        } else {
            notificationsList
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color(red: 0.0, green: 0.71, blue: 0.737))
                .scaleEffect(1.2)
            
            Text("Cargando notificaciones...")
                .font(.poppinsRegular(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 80)
    }
    
    private var notificationsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(controller.notificacionesAgrupadas, id: \.date) { group in
                    NotificationGroupView(
                        date: group.date,
                        items: group.items,
                        header: header(for: group.date)
                    )
                }
                
                // Indicador de carga al final si hay más datos
                if controller.isLoading && !controller.notificacionesAgrupadas.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(Color(red: 0.0, green: 0.71, blue: 0.737))
                        Text("Cargando más...")
                            .font(.poppinsRegular(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                    }
                    .padding()
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Helper Methods
    
    private func loadInitialData() async {
        guard let userId = authController.getCurrentUserId() else {
            controller.errorMessage = "No se pudo obtener el ID del usuario"
            controller.hasError = true
            return
        }
        
        await controller.cargarNotificaciones(userId: userId)
        await controller.obtenerConteoNoLeidas(userId: userId)
    }
    
    private func refreshNotifications() async {
        guard let userId = authController.getCurrentUserId() else {
            controller.errorMessage = "No se pudo obtener el ID del usuario"
            controller.hasError = true
            return
        }
        
        isRefreshing = true
        await controller.refrescarNotificaciones(userId: userId)
        isRefreshing = false
    }
    
    private func header(for date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Hoy" }
        if cal.isDateInYesterday(date) { return "Ayer" }

        let fmt = DateFormatter()
        fmt.dateFormat = "d 'de' MMMM"
        fmt.locale = Locale(identifier: "es_ES")
        return fmt.string(from: date)
    }
}

// MARK: - Notification Group View
struct NotificationGroupView: View {
    let date: Date
    let items: [NotificacionDTO]
    let header: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(header)
                .font(.poppinsSemiBold(size: 18))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.top, 8)
            
            groupContent
        }
    }
    
    private var groupContent: some View {
        VStack(spacing: 0) {
            ForEach(items, id: \.id) { noti in
                notificationItem(noti)
                
                if noti.id != items.last?.id {
                    itemDivider
                }
            }
        }
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
    
    private func notificationItem(_ noti: NotificacionDTO) -> some View {
        NotificationRow(
            notification: Notification(
                type: mapNotificationType(from: noti),
                title: noti.title,
                description: noti.message,
                date: noti.createdAt,
                isRead: noti.isRead
            )
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            noti.isRead ? 
            Color.white.opacity(0.03) : 
            Color(red: 0.0, green: 0.71, blue: 0.737).opacity(0.08)
        )
    }
    
    // MARK: - Helper Methods
    
    /// Mapea el tipo de notificación basado en el contenido
    private func mapNotificationType(from noti: NotificacionDTO) -> NotificationType {
        let message = noti.message.lowercased()
        let title = noti.title.lowercased()
        
        if message.contains("aprobado") || message.contains("approved") || 
           title.contains("aprobado") || title.contains("approved") {
            return .approved
        } else if message.contains("rechazado") || message.contains("rejected") || 
                  title.contains("rechazado") || title.contains("rejected") {
            return .denied
        } else {
            return .inReview
        }
    }
    
    private var itemDivider: some View {
        Divider()
            .background(Color.white.opacity(0.1))
            .padding(.leading, 75)
    }
}

// MARK: - Notification Row
struct NotificationRow: View {
    let notification: Notification
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 15) {
            iconView
            textContent
            Spacer()
            
            VStack {
                chevronIcon
                Spacer()
                if !notification.isRead {
                    unreadIndicator
                }
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            // TODO: Implementar navegación al detalle de la notificación
            print("Tapped notification: \(notification.title)")
        }
    }
    
    private var iconView: some View {
        Image(systemName: notification.type.icon)
            .font(.title2)
            .foregroundColor(notification.type.iconColor)
            .frame(width: 44, height: 44)
            .background(notification.type.iconColor.opacity(0.15))
            .clipShape(Circle())
    }
    
    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(notification.title)
                .font(.poppinsSemiBold(size: 16))
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text(notification.description)
                .font(.poppinsRegular(size: 14))
                .foregroundColor(.gray)
                .lineLimit(3)
            
            Text(timeAgo(from: notification.date))
                .font(.poppinsRegular(size: 12))
                .foregroundColor(.gray.opacity(0.7))
        }
    }
    
    private var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 14))
            .foregroundColor(.gray.opacity(0.5))
    }
    
    private var unreadIndicator: some View {
        Circle()
            .fill(Color(red: 0.0, green: 0.71, blue: 0.737))
            .frame(width: 8, height: 8)
    }
    
    // MARK: - Helper Methods
    
    private func timeAgo(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return "Fecha inválida"
        }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "Ahora"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "Hace \(minutes)m"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "Hace \(hours)h"
        } else {
            let days = Int(timeInterval / 86400)
            return "Hace \(days)d"
        }
    }
}

// MARK: - Empty State
struct EmptyNotificationsView: View {
    let showingUnreadOnly: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("ClearNoti")
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
            
            Text(showingUnreadOnly ? "No tienes notificaciones sin leer" : "No tienes notificaciones nuevas")
                .font(.poppinsMedium(size: 22))
                .foregroundColor(.white)
                .padding(.top, 20)
                .multilineTextAlignment(.center)
            
            Text(showingUnreadOnly ? 
                 "¡Perfecto! Has leído todas\ntus notificaciones." :
                 "Tus notificaciones aparecerán\naquí cuando las recibas.")
                .font(.poppinsRegular(size: 16))
                .foregroundColor(Color(red: 0.0, green: 0.71, blue: 0.737))
                .multilineTextAlignment(.center)
                .padding(.top, 2)
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    ScreenNotifications()
}
