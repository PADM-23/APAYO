import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    var onStart: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "cross.case.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.apayoGreen)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(languageStore.language.localized("home.title"))
                    .font(.largeTitle.bold())

                Text(languageStore.language.localized("home.subtitle"))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            APAYOButton(title: LocalizedStringKey(languageStore.language.localized("home.start")), systemImage: "arrow.right", action: onStart)
        }
        .padding(APAYOTheme.horizontalPadding)
        .background(Color.apayoBackground.ignoresSafeArea())
    }
}

#Preview {
    HomeView()
        .environmentObject(AppLanguageStore())
}
