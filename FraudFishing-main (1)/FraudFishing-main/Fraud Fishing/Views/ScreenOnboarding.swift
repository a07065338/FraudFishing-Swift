//
//  ScreenOnboarding.swift
//  Fraud Fishing
//
//  Created by Javier Canella Ramos on 24/09/25.
//

import SwiftUI

fileprivate struct OnboardingPageInfo: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

struct ScreenOnboarding: View {
    @Binding var isOnboardingFinished: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPageInfo] = [
        .init(imageName: "onboarding1", title: "Reporta las páginas fraudulentas", description: "Ve los reportes de los demás usuarios para evitar imprevistos."),
        .init(imageName: "onboarding2", title: "Recibe alertas en tiempo real", description: "Te notificamos sobre nuevas amenazas y el estado de tus reportes para que navegues seguro"),
        .init(imageName: "onboarding3", title: "Seguimiento a tus reportes", description: "Mantente al tanto del estatus de tus reportes")
    ]

    var body: some View {
        ZStack {
            Color(red: 0.043, green: 0.067, blue: 0.173)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer().frame(height: 50)
                
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingTabView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeOut(duration: 0.5), value: currentPage)

                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .frame(width: index == currentPage ? 20 : 8, height: 8)
                            .foregroundColor(index == currentPage ? .white : .gray.opacity(0.5))
                            .animation(.easeOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 40)

                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        isOnboardingFinished = true
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Siguiente" : "Comenzar")
                        .font(.poppinsBold(size: 20))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.0, green: 0.2, blue: 0.4))
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 30)
                
                Spacer()
            }
        }
    }
}

fileprivate struct OnboardingTabView: View {
    let page: OnboardingPageInfo
    
    var body: some View {
        VStack {
            Spacer()

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .padding(.bottom, 10)

            Text(page.title)
                .font(.poppinsBold(size: 28))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 10)

            Text(page.description)
                .font(.poppinsRegular(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 20)
            
            Spacer()
        }
    }
}

#if DEBUG
struct ScreenOnboarding_Previews: PreviewProvider {
    static var previews: some View {
        ScreenOnboarding(isOnboardingFinished: .constant(false))
    }
}
#endif
