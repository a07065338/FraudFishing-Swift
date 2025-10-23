import SwiftUI

struct ResumenBusquedaCard: View {
    let total: Int
    let url: String
    let tags: [String]
    let categories: [String]

    var body: some View {
        VStack(spacing: 0) {
            // Header con gradiente y efecto de alerta
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.red.opacity(0.8),
                        Color.red.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 160)
                
                // Patrón decorativo
                Canvas { context, size in
                    let lineSpacing: CGFloat = 30
                    for x in stride(from: 0, to: size.width + 100, by: lineSpacing) {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x - 60, y: size.height))
                        context.stroke(path, with: .color(.white.opacity(0.08)), lineWidth: 2)
                    }
                }
                .frame(height: 160)
                
                VStack(spacing: 12) {
                    // Ícono de alerta animado
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 70, height: 70)
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 56, height: 56)
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 28, weight: .bold))
                    }
                    
                    // Contador de reportes
                    HStack(spacing: 6) {
                        Text("\(total)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        Text("reporte\(total == 1 ? "" : "s")")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            }
            
            // Contenido principal
            VStack(alignment: .leading, spacing: 24) {
                // URL destacada
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "link.circle.fill")
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                            .font(.system(size: 16, weight: .semibold))
                        Text("URL Detectada")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Text(url)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.3), lineWidth: 1.5)
                                )
                        )
                }
                
                // Sección de Etiquetas
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.15))
                                .frame(width: 28, height: 28)
                            Image(systemName: "tag.fill")
                                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                                .font(.system(size: 12, weight: .semibold))
                        }
                        Text("Etiquetas")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        // Badge con contador
                        Text("\(tags.isEmpty ? 0 : tags.count)")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.3))
                            )
                    }
                    
                    if tags.isEmpty {
                        HStack {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.white.opacity(0.3))
                                .font(.system(size: 14))
                            Text("Sin etiquetas")
                                .font(.callout)
                                .foregroundColor(.white.opacity(0.4))
                                .italic()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.03))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                        .foregroundColor(.white.opacity(0.1))
                                )
                        )
                    } else {
                        FlexibleChipRow(items: tags)
                    }
                }
                
                // Sección de Categorías
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.15))
                                .frame(width: 28, height: 28)
                            Image(systemName: "square.grid.2x2.fill")
                                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.7))
                                .font(.system(size: 11, weight: .semibold))
                        }
                        Text("Categorías")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        // Badge con contador
                        Text("\(categories.isEmpty ? 0 : categories.count)")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.0, green: 0.8, blue: 0.7).opacity(0.3))
                            )
                    }
                    
                    if categories.isEmpty {
                        HStack {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.white.opacity(0.3))
                                .font(.system(size: 14))
                            Text("Sin categorías")
                                .font(.callout)
                                .foregroundColor(.white.opacity(0.4))
                                .italic()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.03))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                        .foregroundColor(.white.opacity(0.1))
                                )
                        )
                    } else {
                        FlexibleChipRow(items: categories)
                    }
                }
            }
            .padding(24)
        }
        .frame(maxWidth: 400)
        .background(
            ZStack {
                // Fondo con gradiente
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.35),
                        Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.2)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Borde sutil
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
        .shadow(color: Color.red.opacity(0.2), radius: 25, x: 0, y: 12)
    }
}

// Layout flexible para los chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
