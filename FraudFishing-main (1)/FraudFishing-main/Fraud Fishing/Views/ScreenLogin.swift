import SwiftUI

enum LoginRoute: Hashable {
    case home
}

struct ScreenLogin: View {
    // 1. Recibimos el controlador compartido usando @EnvironmentObject.
    @EnvironmentObject private var authController: AuthenticationController
    
    // Estados locales solo para los campos del formulario.
    @State private var emailOrUsername: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    
    // Estados para manejar alertas y la navegación.
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navPath: [LoginRoute] = []

    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                // MARK: Fondo (sin cambios)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                        Color(red: 0.043, green: 0.067, blue: 0.173)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    // MARK: - Título (sin cambios)
                    Text("Iniciar Sesión")
                        .font(.poppinsMedium(size: 34)) // Se mantiene tu fuente personalizada
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 30)

                    // MARK: - Campo de Correo (sin cambios en UI)
                    customLoginTextField(
                        label: "Correo",
                        icon: "envelope",
                        placeholder: "ejemplo@email.com",
                        text: $emailOrUsername,
                        isSecure: false
                    )
                    .padding(.bottom, 20)

                    // MARK: - Campo de Contraseña (sin cambios en UI)
                    customLoginTextField(
                        label: "Contraseña",
                        icon: "lock",
                        placeholder: "••••••••",
                        text: $password,
                        isSecure: !isPasswordVisible,
                        isPasswordToggle: true,
                        isPasswordVisible: $isPasswordVisible
                    )
                    .padding(.bottom, 20)

                    // MARK: - Botón Iniciar Sesión
                    Button(action: {
                        Task { await login() }
                    }) {
                        HStack {
                            // 2. Reaccionamos al estado de carga DEL CONTROLADOR.
                            if authController.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Iniciar Sesión")
                                    .font(.poppinsBold(size: 20))
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(authController.isLoading ? Color.gray : Color(red: 0.0, green: 0.2, blue: 0.4))
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                    }
                    // Deshabilitamos el botón si el controlador está ocupado.
                    .disabled(authController.isLoading)
                    .padding(.bottom, 10)

                    // MARK: - Enlace a Registro
                    HStack {
                        Text("Soy un nuevo usuario.")
                            .font(.poppinsRegular(size: 17))
                            .foregroundColor(.white.opacity(0.8))
                        
                        // 3. Pasamos el environmentObject a la vista de registro.
                        NavigationLink(destination: ScreenRegister().environmentObject(authController)) {
                            Text("Registrarme")
                                .font(.poppinsBold(size: 17))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 170)
                }
            }

            // MARK: - Navegación y Alertas
            .ignoresSafeArea(.keyboard)
            .navigationBarHidden(true)
            .alert("Inicio de Sesión", isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            .navigationDestination(for: LoginRoute.self) { route in
                if route == .home {
                    // ScreenHome también necesitará el controlador.
                    ScreenHome()
                        .environmentObject(authController)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }

    // MARK: - Lógica de Inicio de Sesión
    @MainActor
    private func login() async {
        // La vista ya no maneja 'isLoading', lo hace el controlador.
        do {
            let success = try await authController.loginUser(email: emailOrUsername, password: password)
            if success {
                // Si el login es exitoso y los tokens se guardan, navegamos.
                navPath.append(.home)
            } else {
                // Este caso es raro, pero cubre si el guardado de tokens falla.
                alertMessage = "No se pudo guardar la sesión de forma segura."
                showAlert = true
            }
        } catch {
            // Si el controlador lanza un error, lo mostramos.
            alertMessage = "Credenciales inválidas. Por favor, inténtalo de nuevo."
            showAlert = true
        }
    }
    
    // MARK: - Componente de Campo de Texto Reutilizable (para mantener formato)
    @ViewBuilder
    func customLoginTextField(
        label: String,
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool,
        isPasswordToggle: Bool = false,
        isPasswordVisible: Binding<Bool>? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.poppinsSemiBold(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 30)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.leading, 30)

                ZStack(alignment: .leading) {
                    if text.wrappedValue.isEmpty {
                        Text(placeholder)
                            .font(.poppinsRegular(size: 18))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    if isSecure {
                        SecureField("", text: text)
                            .font(.poppinsRegular(size: 18))
                            .foregroundColor(.white)
                    } else {
                        TextField("", text: text)
                            .font(.poppinsRegular(size: 18))
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                }
                
                if isPasswordToggle, let isVisible = isPasswordVisible {
                    Button(action: { isVisible.wrappedValue.toggle() }) {
                        Image(systemName: isVisible.wrappedValue ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.trailing, 30)
                    }
                }
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 30)
        }
    }
}

// MARK: - Vista Previa
#Preview {
    // 4. Arreglamos la vista previa para que funcione.
    NavigationStack {
        ScreenLogin()
            .environmentObject(AuthenticationController(httpClient: HTTPClient()))
    }
}
