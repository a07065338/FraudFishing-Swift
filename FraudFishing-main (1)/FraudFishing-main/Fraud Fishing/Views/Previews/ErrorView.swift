import SwiftUI

struct ErrorPreView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.poppinsBold(size: 50))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text("Error en la búsqueda")
                    .font(.poppinsBold(size: 32))
                    .foregroundColor(.white)
                    .padding(.bottom)
                
                Text(message)
                    .font(.poppinsRegular(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.red.opacity(0.2), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Preview Container

struct ErrorView_PreviewContainer: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                Color(red: 0.043, green: 0.067, blue: 0.173)]),
                           startPoint: UnitPoint(x:0.5, y:0.1),
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ErrorPreView(message: "No se pudo conectar con el servidor. Por favor, verifica tu conexión a internet e intenta nuevamente.")
                .padding()
        }
    }
}

#Preview {
    ErrorView_PreviewContainer()
}
