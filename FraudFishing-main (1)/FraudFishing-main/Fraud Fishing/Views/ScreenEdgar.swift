import SwiftUI

struct ScreenEdgar: View {
    @State private var categoria: String = "Categoría"
    let categorias = ["Categoría", "Bancos", "Becas", "Asaltos"]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemBackground),
                    Color(red: 0.73, green: 0.92, blue: 0.93) // toque aqua abajo
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Reportes Destacados")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    // Campanita de notificaciones
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.teal)
                        Circle()
                            .fill(Color.red)
                            .frame(width: 16, height: 16)
                            .overlay(Text("1").font(.system(size: 10)).foregroundColor(.white))
                            .offset(x: 6, y: -6)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)

                // Selector de categoría (estilo pastilla)
                Menu {
                    ForEach(categorias, id: \.self) { cat in
                        Button(cat) { categoria = cat }
                    }
                } label: {
                    HStack {
                        Text(categoria)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 48)
                    .background(Color.teal)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                }
                .padding(.horizontal, 20)

                // Tres contenedores vacíos
                HStack(spacing: 16) {
                    EmptyPill()
                    EmptyPill()
                    EmptyPill()
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)

                // Tarjeta 1
                ReportCard(
                    titulo: "PaginaFake.com",
                    descripcion: "Esta es una pagina falsa que vende productos",
                    hashtags: "#Venta #Cobro #Envio"
                )
                .padding(.horizontal, 20)

                // Tarjeta 2
                ReportCard(
                    titulo: "TuEstafa.com",
                    descripcion: "Blog de recomendaciones con links llenos de virus",
                    hashtags: "#Blog #Desinformacion"
                )
                .padding(.horizontal, 20)

                Spacer(minLength: 0)

                // Barra inferior
                BottomBar()
                    .padding(.horizontal, 28)
                    .padding(.bottom, 12)
            }
        }
    }
}

// MARK: - Subviews

/// Contenedor vacío (los 3 de arriba)
struct EmptyPill: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(.secondarySystemBackground))
            .frame(height: 90)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

/// Tarjeta de reporte con título + descripción + hashtags
struct ReportCard: View {
    var titulo: String
    var descripcion: String
    var hashtags: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Text(titulo)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(Color(#colorLiteral(red: 0.06, green: 0.11, blue: 0.28, alpha: 1))) // azul marino
                Spacer()
            }

            // Área de contenido de ejemplo (imagen + texto)
            HStack(alignment: .top, spacing: 14) {
                // placeholder de miniatura
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 120, height: 80)

                VStack(alignment: .leading, spacing: 6) {
                    Text(descripcion)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(hashtags)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(#colorLiteral(red: 0.06, green: 0.11, blue: 0.28, alpha: 1)))
                }
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(#colorLiteral(red: 0.06, green: 0.11, blue: 0.28, alpha: 1)), lineWidth: 1)
                )
        )
    }
}

/// Barra inferior con 3 íconos (stats, home, settings)
struct BottomBar: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Image(systemName: "chart.bar")
                    .font(.system(size: 18, weight: .semibold))
                Circle().frame(width: 0, height: 0).opacity(0)
            }
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(#colorLiteral(red: 0.11, green: 0.20, blue: 0.44, alpha: 1)))
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)

                Image(systemName: "house.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .bold))
            }
            .offset(y: -10)

            Spacer()
            VStack(spacing: 4) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                Circle().frame(width: 0, height: 0).opacity(0)
            }
            Spacer()
        }
        .padding(.top, 8)
    }
}

#Preview {
    ScreenEdgar()
}
