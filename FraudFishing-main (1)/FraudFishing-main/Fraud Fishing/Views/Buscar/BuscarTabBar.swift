import SwiftUI

struct BuscarTabBar: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject var authController: AuthenticationController

    var body: some View {
        let turquoise = Color(red: 0.0, green: 0.71, blue: 0.737)
        let barHeight: CGFloat = 88

        ZStack {
            Path { path in
                let width = UIScreen.main.bounds.width
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(to: CGPoint(x: width, y: 0),
                                  control: CGPoint(x: width / 2, y: 40))
                path.addLine(to: CGPoint(x: width, y: barHeight))
                path.addLine(to: CGPoint(x: 0, y: barHeight))
                path.closeSubpath()
            }
            .fill(Color(red: 0.537, green: 0.616, blue: 0.733, opacity: 0.6))
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: -6)

            HStack {
                if selectedTab == .dashboard {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                } else {
                    NavigationLink(destination: ScreenDashboard().environmentObject(authController)) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.537, green: 0.616, blue: 0.733))
                    }
                }

                Spacer()

                if selectedTab == .settings {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                } else {
                    NavigationLink(destination: ScreenAjustes()) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.537, green: 0.616, blue: 0.733))
                    }
                }
            }
            .padding(.horizontal, 55)

            if selectedTab != .home {
                NavigationLink(destination: ScreenHome()) {
                    ZStack {
                        Circle()
                            .fill(turquoise)
                            .frame(width: 70, height: 70)
                            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
                        Image(systemName: "house.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -25)
            } else {
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(turquoise)
                            .frame(width: 70, height: 70)
                            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
                        Image(systemName: "house.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -25)
            }
        }
        .frame(height: barHeight)
    }
}

struct BuscarTabButton: View {
    let icon: String
    let tab: Tab
    @Binding var selectedTab: Tab

    var body: some View {
        Button(action: { selectedTab = tab }) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(selectedTab == tab ? .white : Color(red: 0.537, green: 0.616, blue: 0.733))
        }
    }
}