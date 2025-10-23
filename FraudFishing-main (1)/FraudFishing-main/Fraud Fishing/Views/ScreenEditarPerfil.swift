import SwiftUI

// MARK: - Vista Principal: Editar Perfil
struct ScreenEditarPerfil: View {
    @StateObject private var profileController = UserProfileController()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: Tab = .profile
    
    // Estados para las vistas modales y alertas.
    @State private var showChangeNameSheet: Bool = false
    @State private var showChangePasswordSheet: Bool = false
    @State private var showChangeEmailSheet: Bool = false
    @State private var showLogoutAlert: Bool = false
    @State private var navigateToLogin: Bool = false
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Fondo
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                    Color(red: 0.043, green: 0.067, blue: 0.173)
                ]),
                startPoint: .top, endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // MARK: - Header con Botón de Ajustes
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white).padding(10)
                            .background(Color.white.opacity(0.1)).clipShape(Circle())
                    }
                    Spacer()
                    Text("Perfil").font(.title2).fontWeight(.bold).foregroundColor(.white)
                    Spacer()
                    // Botón que navega a Ajustes
                    NavigationLink(destination: ScreenAjustes()) {
                        Image("ajustes")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .padding(10)
                    }
                }
                .padding(.horizontal).padding(.top)
                
                // MARK: - Contenido Dinámico
                if profileController.isLoading && profileController.userProfile == nil {
                    Spacer()
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                } else if let profile = profileController.userProfile {
                    UserProfileContentView(profile: profile,
                                           showChangeNameSheet: $showChangeNameSheet,
                                           showChangePasswordSheet: $showChangePasswordSheet,
                                           showChangeEmailSheet: $showChangeEmailSheet)
                    
                    // Botón de Cerrar Sesión
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Cerrar Sesión")
                        }
                        .fontWeight(.bold).foregroundColor(.red)
                        .padding().frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.15)).cornerRadius(10)
                    }
                    Spacer()
                    
                } else if let errorMessage = profileController.errorMessage {
                    Spacer()
                    Text(errorMessage).foregroundColor(.red).padding().multilineTextAlignment(.center)
                    Spacer()
                }
            }
            .padding(.bottom, 140) // Espacio para la tab bar
            
            // Capa 2: CustomTabBar superpuesta
            CustomTabBar(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
        .task { await profileController.fetchUserProfile() }
        .sheet(isPresented: $showChangeNameSheet) { ChangeNameView(profileController: profileController) }
        .sheet(isPresented: $showChangePasswordSheet) { ChangePasswordView(profileController: profileController) }
        .sheet(isPresented: $showChangeEmailSheet) { ChangeEmailView(profileController: profileController) }
        .alert("Cerrar Sesión", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Confirmar", role: .destructive) { cerrarSesion() }
        } message: {
            Text("¿Estás seguro de que quieres cerrar sesión?")
        }
        .background(
            NavigationLink(destination: ScreenLogin().navigationBarBackButtonHidden(true),
                           isActive: $navigateToLogin) {
                               EmptyView()
                           }
        )
    }
    
    private func cerrarSesion() {
        TokenStorage.clearSession()
        print("Sesión cerrada y tokens eliminados.")
        navigateToLogin = true
    }
}

// MARK: - Vista del Contenido del Perfil
struct UserProfileContentView: View {
    let profile: UserProfile
    @Binding var showChangeNameSheet: Bool
    @Binding var showChangePasswordSheet: Bool
    @Binding var showChangeEmailSheet: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image("mascotaFF")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 4))
                .shadow(radius: 5)
            
            Text(profile.name)
                .font(.title).fontWeight(.bold).foregroundColor(.white)
            
            VStack(spacing: 0) {
                ProfileRow(title: "Nombre", value: profile.name, action: { showChangeNameSheet = true })
                ProfileRow(title: "Correo", value: profile.email, action: { showChangeEmailSheet = true })
                ProfileRow(title: "Contraseña", value: "••••••••", action: { showChangePasswordSheet = true })
            }
            .background(Color.white.opacity(0.1)).cornerRadius(10).padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
    }
}

// MARK: - Componente Reutilizable
struct ProfileRow: View {
    let title: String
    let value: String
    var action: (() -> Void)?
    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 0) {
                HStack {
                    Text(title).foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text(value).foregroundColor(.white).lineLimit(1)
                    if action != nil {
                        Image(systemName: "chevron.right").foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding()
                Divider().background(Color.white.opacity(0.2)).padding(.leading)
            }
        }
        .disabled(action == nil)
    }
}

// MARK: - Vistas Modales (Sheets)
struct ChangeNameView: View {
    @ObservedObject var profileController: UserProfileController
    @Environment(\.dismiss) private var dismiss
    @State private var newName: String = ""

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88), Color(red: 0.043, green: 0.067, blue: 0.173)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("Cambiar Nombre").font(.title2).fontWeight(.bold).foregroundColor(.white).padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nuevo Nombre")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    TextField("Escribe tu nuevo nombre", text: $newName)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                }
                Button("Guardar") {
                    Task {
                        let success = await profileController.updateName(newName)
                        if success { dismiss() }
                    }
                }
                .font(.headline).fontWeight(.bold).foregroundColor(.white)
                .padding().frame(maxWidth: .infinity)
                .background(Color(red: 0.0, green: 0.2, blue: 0.4))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .onAppear { self.newName = profileController.userProfile?.name ?? "" }
            .overlay { if profileController.isLoading { Color.black.opacity(0.4).ignoresSafeArea(); ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)) } }
        }
    }
}

struct ChangePasswordView: View {
    @ObservedObject var profileController: UserProfileController
    @Environment(\.dismiss) private var dismiss
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88), Color(red: 0.043, green: 0.067, blue: 0.173)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                Text("Cambiar Contraseña").font(.title2).fontWeight(.bold).foregroundColor(.white).padding()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nueva Contraseña")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        SecureField("Escribe tu nueva contraseña", text: $newPassword)
                            .foregroundColor(.white).padding()
                            .background(Color.white.opacity(0.1)).cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirmar Contraseña")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        SecureField("Confirma tu nueva contraseña", text: $confirmPassword)
                            .foregroundColor(.white).padding()
                            .background(Color.white.opacity(0.1)).cornerRadius(10)
                    }
                }
                
                if let errorMessage = profileController.errorMessage { Text(errorMessage).foregroundColor(.red).font(.caption) }
                Button("Guardar") {
                    Task {
                        let success = await profileController.updatePassword(newPassword: newPassword, confirmation: confirmPassword)
                        if success { dismiss() }
                    }
                }
                .font(.headline).fontWeight(.bold).foregroundColor(.white).padding().frame(maxWidth: .infinity).background(Color(red: 0.0, green: 0.2, blue: 0.4)).cornerRadius(10)
                Spacer()
            }
            .padding()
            .overlay { if profileController.isLoading { Color.black.opacity(0.4).ignoresSafeArea(); ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)) } }
        }
    }
}

struct ChangeEmailView: View {
    @ObservedObject var profileController: UserProfileController
    @Environment(\.dismiss) private var dismiss
    @State private var newEmail: String = ""

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88), Color(red: 0.043, green: 0.067, blue: 0.173)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                Text("Cambiar Correo").font(.title2).fontWeight(.bold).foregroundColor(.white).padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nuevo Correo Electrónico")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    TextField("Escribe tu nuevo correo", text: $newEmail)
                        .foregroundColor(.white).padding()
                        .background(Color.white.opacity(0.1)).cornerRadius(10)
                        .keyboardType(.emailAddress).autocapitalization(.none)
                }

                if let errorMessage = profileController.errorMessage { Text(errorMessage).foregroundColor(.red).font(.caption) }
                Button("Guardar") {
                    Task {
                        let success = await profileController.updateEmail(newEmail)
                        if success { dismiss() }
                    }
                }
                .font(.headline).fontWeight(.bold).foregroundColor(.white).padding().frame(maxWidth: .infinity).background(Color(red: 0.0, green: 0.2, blue: 0.4)).cornerRadius(10)
                Spacer()
            }
            .padding()
            .onAppear { self.newEmail = profileController.userProfile?.email ?? "" }
            .overlay { if profileController.isLoading { Color.black.opacity(0.4).ignoresSafeArea(); ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)) } }
        }
    }
}

// MARK: - Vista Previa
#Preview {
    let hardcodedToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxNiIsInR5cGUiOiJhY2Nlc3MiLCJwcm9maWxlIjp7ImlkIjoiMTYiLCJlbWFpbCI6Im51ZXZvQHlhLmNvbSIsIm5hbWUiOiJOdWV2byIsImlzX2FkbWluIjowLCJpc19zdXBlcl9hZG1pbiI6MH0sImlhdCI6MTc2MDczNDE1NSwiZXhwIjoxNzYwNzM0NzU1fQ.GHJbCXL7KWhOMkPZD0wEKjJzzHZISn8BhUNS1MtbzKA"
    let _ = TokenStorage.set(.access, value: hardcodedToken)
    
    return NavigationStack {
        ScreenEditarPerfil()
    }
}
