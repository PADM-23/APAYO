import SwiftUI

struct SymptomConfirmationView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let onConfirm: () -> Void
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            symptomCard
                .padding(.top, 48)

            Spacer(minLength: 24)

            APAYOButton(title: LocalizedStringKey(text("confirmation.correct")), action: onConfirm)

            Button(text("confirmation.retry"), action: onRetry)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.apayoGray800)
                .frame(maxWidth: .infinity, minHeight: 54)
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .padding(.bottom, 1)
        .background {
            LinearGradient(
                colors: [
                    Color(red: 243 / 255, green: 1, blue: 206 / 255).opacity(0.10),
                    Color.white,
                    Color(red: 134 / 255, green: 246 / 255, blue: 192 / 255).opacity(0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .navigationTitle(text("confirmation.navigation"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onRetry) {
                    Image(systemName: "chevron.backward")
                }
            }
        }
    }

    private var symptomCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(
                    color: Color(red: 223 / 255, green: 246 / 255, blue: 220 / 255),
                    radius: 16,
                    y: 8
                )

            VStack(spacing: 0) {
                Image("SymptomCards/Heatstroke")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 226, height: 226)

                VStack(spacing: 6) {
                    Text(text("confirmation.heatstroke"))
                        .font(.system(size: 28, weight: .bold))
                    Text(languageStore.language.nativeName)
                        .font(.subheadline)
                        .foregroundStyle(Color.apayoGreen)
                }
                .padding(.top, 16)

                Spacer(minLength: 12)

                Text(descriptionText)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .lineSpacing(1)
                    .padding(.horizontal, 22)
                    .frame(maxWidth: .infinity, minHeight: 102)
                    .background(Color.apayoGray100.opacity(0.62))
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.apayoGray300.opacity(0.7), lineWidth: 2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 473)

    }

    private var descriptionText: String {
        text("confirmation.description")
    }

    private func text(_ key: String) -> String {
        languageStore.language.localized(key)
    }
}

#Preview {
    NavigationStack {
        SymptomConfirmationView(
            onConfirm: {},
            onRetry: {}
        )
        .environmentObject(AppLanguageStore())
    }
}
