import SwiftUI

struct ScreenRegister: View {
    @EnvironmentObject private var authController: AuthenticationController
    
    @State private var nombre: String = ""
    @State private var correo: String = ""
    @State private var contrasena: String = ""
    @State private var confirmarContrasena: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var registroExitoso: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Fondo de la vista
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                    Color(red: 0.043, green: 0.067, blue: 0.173)
                ]),
                startPoint: UnitPoint(x: 0.5, y: 0.1),
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 25) {
                    Text("Registrarse")
                        .font(.largeTitle).fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 70)
                        .padding(.leading, 30)

                    // MARK: - Campos de Texto
                    // Aquí se llama a la función customTextField
                    customTextField(
                        label: "Nombre Completo",
                        icon: "person",
                        placeholder: "Ingresa tu nombre completo",
                        text: $nombre,
                        isSecure: false
                    )
                    
                    customTextField(
                        label: "Correo",
                        icon: "envelope",
                        placeholder: "ejemplo@correo.com",
                        text: $correo,
                        isSecure: false,
                        keyboardType: .emailAddress
                    )
                    
                    customTextField(
                        label: "Contraseña",
                        icon: "lock",
                        placeholder: "••••••••",
                        text: $contrasena,
                        isSecure: !isPasswordVisible,
                        trailingIcon: isPasswordVisible ? "eye.fill" : "eye.slash.fill",
                        onTrailingTap: { isPasswordVisible.toggle() }
                    )
                    
                    if !contrasena.isEmpty {
                        PasswordStrengthView(password: contrasena)
                    }

                    customTextField(
                        label: "Confirmar Contraseña",
                        icon: "lock",
                        placeholder: "••••••••",
                        text: $confirmarContrasena,
                        isSecure: !isConfirmPasswordVisible,
                        trailingIcon: isConfirmPasswordVisible ? "eye.fill" : "eye.slash.fill",
                        onTrailingTap: { isConfirmPasswordVisible.toggle() }
                    )

                    if !confirmarContrasena.isEmpty && contrasena != confirmarContrasena {
                        Text("Las contraseñas no coinciden")
                            .font(.caption).foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 38)
                    }

                    // MARK: - Botón Registrarse
                    Button(action: { Task { await registrarUsuario() } }) {
                        HStack {
                            if authController.isLoading {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Registrarse").fontWeight(.bold).font(.system(size: 20))
                            }
                        }
                        .foregroundColor(.white).padding().frame(maxWidth: .infinity)
                        .background(formularioValido() && !authController.isLoading ? Color(red: 0.0, green: 0.2, blue: 0.4) : Color.gray)
                        .cornerRadius(10).padding(.horizontal, 30)
                    }
                    .disabled(!formularioValido() || authController.isLoading)
                    .padding(.top, 10)

                    // MARK: - Link a Iniciar Sesión
                    HStack {
                        Text("¿Ya tienes una cuenta?").foregroundColor(.white.opacity(0.8))
                        Button(action: { dismiss() }) {
                            Text("Iniciar Sesión").fontWeight(.bold).foregroundColor(.white)
                        }
                    }
                    .font(.system(size: 17)).padding(.top, 8).padding(.bottom, 80)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.1)).frame(width: 36, height: 36)
                        Image(systemName: "chevron.left").foregroundColor(.white).font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }
        .alert("Registro", isPresented: $showAlert) {
            Button(registroExitoso ? "Continuar" : "OK") {
                if registroExitoso { dismiss() }
            }
        } message: {
            Text(alertMessage)
        }
    }

    @ViewBuilder
    func customTextField(
        label: String,
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool,
        trailingIcon: String? = nil,
        keyboardType: UIKeyboardType = .default,
        onTrailingTap: (() -> Void)? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 30)

            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20) // Alineación
                    .padding(.leading, 30)

                ZStack(alignment: .leading) {
                    if text.wrappedValue.isEmpty {
                        Text(placeholder)
                            .font(.poppinsRegular(size: 18))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    
                    if isSecure {
                        SecureField("", text: text)
                            .foregroundColor(.white)
                            .keyboardType(keyboardType)
                    } else {
                        TextField("", text: text)
                            .foregroundColor(.white)
                            .keyboardType(keyboardType)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                }

                if let trailingIcon = trailingIcon {
                    Button(action: { onTrailingTap?() }) {
                        Image(systemName: trailingIcon)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.trailing, 30)
                    }
                } else {
                    // Espaciador para alinear con los campos que sí tienen ícono
                    Spacer().frame(width: 20).padding(.trailing, 30)
                }
            }
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 30)
        }
        .font(.system(size: 16))
    }

    private func formularioValido() -> Bool {
        return !nombre.trimmingCharacters(in: .whitespaces).isEmpty &&
               validarCorreo() &&
               contrasena.count >= 6 &&
               contrasena.rangeOfCharacter(from: .decimalDigits) != nil &&
               contrasena == confirmarContrasena
    }

    private func validarCorreo() -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", regex)
            .evaluate(with: correo.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    @MainActor
    private func registrarUsuario() async {
        do {
            try await authController.registerUser(
                name: nombre.trimmingCharacters(in: .whitespacesAndNewlines),
                email: correo.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                password: contrasena
            )
            registroExitoso = true
            alertMessage = "¡Registro exitoso! Ahora puedes iniciar sesión."
        } catch {
            registroExitoso = false
            alertMessage = "Error en el registro: \(error.localizedDescription)"
        }
        showAlert = true
    }
}

// MARK: - Componente para Fortaleza de Contraseña
struct PasswordStrengthView: View {
    let password: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            RequirementView(isMet: password.count >= 6, text: "Al menos 6 caracteres")
            RequirementView(isMet: password.rangeOfCharacter(from: .decimalDigits) != nil, text: "Al menos un número")
        }
        .font(.caption).foregroundColor(.white.opacity(0.7))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 38)
    }
}

struct RequirementView: View {
    let isMet: Bool
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .red)
            Text(text)
        }
    }
}

// MARK: - Vista Previa
#Preview {
    NavigationStack {
        ScreenRegister()
            .environmentObject(AuthenticationController(httpClient: HTTPClient()))
    }
}
