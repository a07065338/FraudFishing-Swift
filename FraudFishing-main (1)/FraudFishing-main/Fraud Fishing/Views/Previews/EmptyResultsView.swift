import SwiftUI
import Foundation

struct EmptyResultsPreView: View {
    let url: String
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "magnifyingglass")
                    .font(.poppinsBold(size: 40))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            VStack(spacing: 20) {
                Text("Sin resultados")
                    .font(.poppinsBold(size: 28))
                    .foregroundColor(.white)
                
                VStack(spacing: 6) {
                    Text("No se encontraron reportes para")
                        .font(.poppinsRegular(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(url)
                        .font(.poppinsRegular(size: 16))
                        .foregroundColor(Color(red: 0.0, green: 0.71, blue: 0.737))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.0, green: 0.71, blue: 0.737).opacity(0.1))
                        )
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(10)
                }
                
                Text("Intenta buscar otra URL o crea un nuevo reporte")
                    .font(.poppinsRegular(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
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
    }
}

// MARK: - Preview Container

struct EmptyResultsView_PreviewContainer: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.043, green: 0.067, blue: 0.173, opacity: 0.88),
                Color(red: 0.043, green: 0.067, blue: 0.173)]),
                           startPoint: UnitPoint(x:0.5, y:0.1),
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            EmptyResultsPreView(url: "https://phishing-example-site.com/login")
                .padding()
        }
    }
}

#Preview {
    EmptyResultsView_PreviewContainer()
}
