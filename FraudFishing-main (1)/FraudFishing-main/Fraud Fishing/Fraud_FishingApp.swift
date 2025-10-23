import SwiftUI
// 1. IMPORTAMOS EL FRAMEWORK DE NOTIFICACIONES
import UserNotifications

@main
struct Fraud_FishingApp: App {
    // Tu código existente
    @StateObject private var authController = AuthenticationController(httpClient: HTTPClient())
    @State private var isOnboardingFinished = false

    // 2. AÑADIMOS EL INICIALIZADOR
    /// El inicializador se ejecuta una vez cuando la app se lanza.
    /// Es el lugar perfecto para configurar servicios o solicitar permisos iniciales.
    init() {
        solicitarPermisoNotificaciones()
    }

    var body: some Scene {
        WindowGroup {
            if isOnboardingFinished {
                ScreenLogin()
                    .environmentObject(authController)
            } else {
                ScreenOnboarding(isOnboardingFinished: $isOnboardingFinished)
            }
        }
    }

    // 3. AÑADIMOS LA FUNCIÓN PARA SOLICITAR PERMISOS
    /// Esta función se comunica con iOS para mostrar la alerta estándar
    /// de solicitud de permiso para enviar notificaciones al usuario.
    func solicitarPermisoNotificaciones() {
        let center = UNUserNotificationCenter.current()
        
        // Solicitamos permiso para mostrar alertas, globos en el ícono (badges) y sonidos.
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                // Es una buena práctica registrar cualquier error, aunque raramente ocurra aquí.
                print("Error al solicitar permiso de notificaciones: \(error.localizedDescription)")
                return
            }

            if granted {
                print("El usuario ha concedido el permiso de notificaciones. ✅")
            } else {
                print("El usuario ha denegado el permiso de notificaciones. ❌")
            }
        }
    }
}
