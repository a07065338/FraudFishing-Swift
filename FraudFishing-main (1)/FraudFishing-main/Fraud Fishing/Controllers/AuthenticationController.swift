import Foundation
import Combine

class AuthenticationController: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
        // Cargar usuario guardado al inicializar
        loadSavedUser()
    }
    
    // MARK: - Registro de Usuario (Corregido)
    @MainActor
    func registerUser(name: String, email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        // defer garantiza que isLoading se apague sin importar cómo termine la función.
        defer { isLoading = false }
        
        let request = UserRegisterRequest(name: name, email: email, password: password)
        
        do {
            // Esta función no devuelve nada, solo puede lanzar un error.
            try await httpClient.UserRegistration(request)
            // Si no hubo error, el registro fue exitoso.
        } catch {
            // Si hubo un error de red o de status code, lo capturamos.
            self.errorMessage = error.localizedDescription
            print("🛑 ERROR en registerUser: \(error)")
            throw error // Lo volvemos a lanzar para que la vista muestre la alerta.
        }
    }
    
    // MARK: - Inicio de Sesión de Usuario (Corregido)
    @MainActor
    func loginUser(email: String, password: String) async throws -> Bool {
        isLoading = true
        errorMessage = nil
        
        // Usamos defer aquí también para consistencia y seguridad.
        defer { isLoading = false }
        
        do {
            let loginResponse = try await httpClient.UserLogin(email: email, password: password)
            
            // Guardamos los tokens de forma segura
            let accessTokenSaved = TokenStorage.set(.access, value: loginResponse.accessToken)
            let refreshTokenSaved = TokenStorage.set(.refresh, value: loginResponse.refreshToken)
            
            // Guardamos la información del usuario
            if accessTokenSaved && refreshTokenSaved {
                saveUser(loginResponse.user)
                self.currentUser = loginResponse.user
            }
            
            return accessTokenSaved && refreshTokenSaved
            
        } catch {
            self.errorMessage = error.localizedDescription
            throw error // Re-lanzamos el error para que la vista lo capture
        }
    }
    
    // MARK: - Gestión de Usuario
    private func saveUser(_ user: User) {
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    private func loadSavedUser() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
        }
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
        self.currentUser = nil
    }
    
    func getCurrentUserId() -> Int? {
        return currentUser?.id
    }
    
    func getAccessToken() -> String? {
        TokenStorage.get(.access)
    }
    
    func getRefreshToken() -> String? {
        TokenStorage.get(.refresh)
    }
}
