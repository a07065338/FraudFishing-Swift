import SwiftUI

struct LoadingPreView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Círculos animados de fondo
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            Color(red: 0.0, green: 0.71, blue: 0.737).opacity(0.2),
                            lineWidth: 2
                        )
                        .frame(width: 80 + CGFloat(index * 20), height: 80 + CGFloat(index * 20))
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
                
                // Ícono de búsqueda
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.0, green: 0.71, blue: 0.737).opacity(0.3),
                                    Color(red: 0.0, green: 0.71, blue: 0.737).opacity(0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "magnifyingglass")
                        .font(.poppinsSemiBold(size: 32))
                        .foregroundColor(Color(red: 0.0, green: 0.71, blue: 0.737))
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 2)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }
            }
            .frame(height: 160)
            
            VStack(spacing: 8) {
                Text("Buscando reportes...")
                    .font(.poppinsBold(size: 25))
                    .foregroundColor(.white)
                
                Text("Analizando la base de datos")
                    .font(.poppinsRegular(size: 16))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Barra de progreso animada
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.71, blue: 0.737),
                                Color(red: 0.0, green: 0.8, blue: 0.7)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: isAnimating ? 250 : 0, height: 6)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            .frame(width: 250)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Preview Container

struct LoadingView_PreviewContainer: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                Color(red: 0.043, green: 0.067, blue: 0.173)]),
                           startPoint: UnitPoint(x:0.5, y:0.1),
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            LoadingPreView()
        }
    }
}

#Preview {
    LoadingView_PreviewContainer()
}
