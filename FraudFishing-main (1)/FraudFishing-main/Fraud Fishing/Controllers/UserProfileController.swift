import Foundation

@MainActor
class UserProfileController: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userClient = HTTPUsuario()

    // --- Cargar Perfil (Sin cambios) ---
    func fetchUserProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            self.userProfile = try await userClient.getUserProfile()
        } catch {
            self.errorMessage = "Error al cargar el perfil: \(error.localizedDescription)"
        }
    }
    
    // --- ✅ SOLUCIÓN: Actualizar Nombre ahora devuelve Bool ---
    func updateName(_ newName: String) async -> Bool { // <-- 1. Añadimos el tipo de retorno
        guard !newName.isEmpty else {
            self.errorMessage = "El nombre no puede estar vacío."
            return false // <-- 2. Retornamos 'false' en caso de error de validación
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let updatedProfile = try await userClient.updateUserProfile(
                name: newName,
                email: nil,
                password: nil
            )
            self.userProfile = updatedProfile
            return true // <-- 3. Retornamos 'true' si todo fue exitoso
        } catch {
            self.errorMessage = "Error al actualizar el nombre: \(error.localizedDescription)"
            return false // <-- 4. Retornamos 'false' si hubo un error en la red
        }
    }
    
    func updatePassword(newPassword: String, confirmation: String) async -> Bool {
        guard !newPassword.isEmpty else {
            self.errorMessage = "La contraseña no puede estar vacía."
            return false
        }
        guard newPassword == confirmation else {
            self.errorMessage = "Las contraseñas no coinciden."
            return false
        }
        // Aquí podrías agregar más validaciones (ej: longitud mínima).
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Llamamos a la misma función de la red, pero solo con el campo de la contraseña.
            _ = try await userClient.updateUserProfile(
                name: nil,
                email: nil,
                password: newPassword
            )
            // No necesitamos actualizar el perfil en la UI, ya que la contraseña no se muestra.
            return true
        } catch {
            self.errorMessage = "Error al actualizar la contraseña."
            return false
        }
    }
    
    func updateEmail(_ newEmail: String) async -> Bool {
        // Validación básica del formato del correo
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        guard emailPredicate.evaluate(with: newEmail) else {
            self.errorMessage = "El formato del correo no es válido."
            return false
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Llamamos a la red solo con el campo del correo.
            let updatedProfile = try await userClient.updateUserProfile(
                name: nil,
                email: newEmail,
                password: nil
            )
            // Actualizamos la UI con la respuesta del servidor.
            self.userProfile = updatedProfile
            return true
        } catch {
            self.errorMessage = "Error al actualizar el correo."
            return false
        }
    }
}
