//
//  ScreenTerminosCondiciones.swift
//  Fraud Fishing
//
//  Created by Victor Bosquez on 01/10/25.
//

import SwiftUI

// MARK: - Pantalla de Términos y Condiciones

struct ScreenTerminosCondiciones: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // MARK: - Fondo
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                    Color(red: 0.043, green: 0.067, blue: 0.173)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // MARK: - Header Personalizado
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Términos y Condiciones")
                        .font(.title3).fontWeight(.bold).foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40) // Espaciador para centrar
                }
                .padding(.horizontal)
                .padding(.vertical)
                
                // MARK: - Contenido de Términos
                ScrollView {
                    VStack(spacing: 25) {
                        Text("Al descargar y utilizar Fraud Fishing, usted acepta los siguientes términos y condiciones:")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 10)

                        // --- Secciones de Términos ---
                        LegalSection(title: "USO DE LA APP") {
                            LegalRow(
                                title: "Finalidad",
                                content: "La App se proporciona para fines informativos y de servicio. Usted se compromete a usarla de manera legal y responsable."
                            )
                        }
                        
                        LegalSection(title: "PROPIEDAD INTELECTUAL") {
                            LegalRow(
                                title: "Derechos de Autor",
                                content: "Todo el contenido, diseño y funciones de la App son propiedad de Fraud Fishing. No está permitido copiar, modificar o distribuir dicho contenido sin autorización previa."
                            )
                        }
                        
                        LegalSection(title: "RESPONSABILIDAD") {
                            LegalRow(
                                title: "Limitación",
                                content: "La App se ofrece \"tal cual\". No garantizamos que esté libre de errores. Fraud Fishing no se hace responsable por daños derivados del uso de la App."
                            )
                        }
                        
                        LegalSection(title: "DATOS PERSONALES Y MODIFICACIONES") {
                            LegalRow(
                                title: "Privacidad",
                                content: "El uso de la App implica el tratamiento de datos personales conforme a nuestro Aviso de Privacidad."
                            )
                            Divider().background(Color.white.opacity(0.2)).padding(.leading, 20)
                            LegalRow(
                                title: "Actualizaciones",
                                content: "Podremos modificar estos Términos y Condiciones en cualquier momento, publicando las actualizaciones en la App."
                            )
                        }
                        
                        Text("Si no está de acuerdo con estos términos, le solicitamos no utilizar la App.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.vertical, 20)
                    }
                    .padding(.top)
                }
            }
        }
        .navigationBarHidden(true) // Ocultamos la barra de navegación original
    }
}

// MARK: - Pantalla de Aviso de Privacidad

struct ScreenAvisoPrivacidad: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // MARK: - Fondo
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                    Color(red: 0.043, green: 0.067, blue: 0.173)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // MARK: - Header Personalizado
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Aviso de Privacidad")
                        .font(.title3).fontWeight(.bold).foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40) // Espaciador para centrar
                }
                .padding(.horizontal)
                .padding(.vertical)
                
                // MARK: - Contenido de Privacidad
                ScrollView {
                    VStack(spacing: 25) {
                        Text("Respetamos y protegemos la privacidad de nuestros usuarios. Este aviso describe cómo recopilamos, usamos y protegemos su información personal.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 10)

                        // --- Secciones de Privacidad ---
                        LegalSection(title: "INFORMACIÓN RECOPILADA") {
                            LegalRow(
                                title: "Datos del Usuario",
                                content: "Recopilamos información que usted nos proporciona directamente, como nombre, correo electrónico y datos de registro, además de la información de los reportes que realiza."
                            )
                        }
                        
                        LegalSection(title: "USO Y PROTECCIÓN DE LA INFORMACIÓN") {
                            LegalRow(
                                title: "Finalidad",
                                content: "Utilizamos su información para proporcionar y mejorar nuestros servicios, procesar sus reportes, comunicarnos con usted y garantizar la seguridad de la plataforma."
                            )
                            Divider().background(Color.white.opacity(0.2)).padding(.leading, 20)
                            LegalRow(
                                title: "Seguridad",
                                content: "Implementamos medidas de seguridad técnicas y organizativas para proteger su información personal contra accesos no autorizados, pérdida o alteración."
                            )
                        }
                        
                        LegalSection(title: "SUS DERECHOS Y CONTACTO") {
                            LegalRow(
                                title: "Derechos ARCO",
                                content: "Usted tiene derecho a acceder, rectificar, cancelar u oponerse al tratamiento de sus datos. Puede contactarnos a través de la aplicación para ejercerlos."
                            )
                            Divider().background(Color.white.opacity(0.2)).padding(.leading, 20)
                            LegalRow(
                                title: "Contacto",
                                content: "Si tiene preguntas, puede contactarnos en: privacidad@fraudfishing.com"
                            )
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .navigationBarHidden(true) // Ocultamos la barra de navegación original
    }
}

// MARK: - Componentes Reutilizables para Estilo Legal

struct LegalSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct LegalRow: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4) // Mejora la legibilidad
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}


// MARK: - Previews

#Preview("Términos y Condiciones") {
    NavigationView {
        ScreenTerminosCondiciones()
    }
    .preferredColorScheme(.dark)
}

#Preview("Aviso de Privacidad") {
    NavigationView {
        ScreenAvisoPrivacidad()
    }
    .preferredColorScheme(.dark)
}
