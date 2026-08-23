import SwiftUI

@main
struct APAYOApp: App {
    @StateObject private var languageStore = AppLanguageStore()

    var body: some Scene {
        WindowGroup {
            APAYORootView()
                .environmentObject(languageStore)
                .environment(\.locale, languageStore.language.locale)
        }
    }
}

private struct APAYORootView: View {
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            PatientFlowView()

            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.6))

            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.35)) {
                isShowingSplash = false
            }
        }
    }
}
