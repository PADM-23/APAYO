import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPresented = false

    var body: some View {
        ZStack {
            Color.apayoGreen
                .ignoresSafeArea()

            Image("APAYOLogo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 280)
                .padding(.horizontal, APAYOTheme.horizontalPadding)
            .scaleEffect(isPresented || reduceMotion ? 1 : 0.92)
            .opacity(isPresented || reduceMotion ? 1 : 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("아파요")
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isPresented = true
            }
        }
    }
}

#Preview {
    SplashView()
}
