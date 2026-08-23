import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    @State private var selection: AppLanguage?
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressLine(completedSteps: selection == nil ? 0 : 1)
                .padding(.top, 10)

            Text("1/2")
                .font(.headline)
                .foregroundStyle(Color.apayoGreen)
                .padding(.top, 18)

            VStack(alignment: .leading, spacing: 10) {
                Text((selection ?? .english).localized("language.title"))
                    .font(.title2.bold())
                    .fixedSize(horizontal: false, vertical: true)
                Text((selection ?? .english).localized("language.subtitle"))
                    .font(.body)
                    .foregroundStyle(Color.apayoGray800)
            }
            .padding(.top, 20)

            VStack(spacing: 8) {
                ForEach(AppLanguage.onboardingLanguages) { language in
                    Button {
                        selection = language
                        languageStore.select(language)
                    } label: {
                        HStack(spacing: 16) {
                            Image(language.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 28, height: 28)
                                .clipShape(Circle())

                            VStack(spacing: 4) {
                                Text(language.nativeName)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(Color.primary)
                                Text(language.englishName)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.apayoGray600)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 68)
                        .background(selection == language ? Color.apayoBackground : Color.apayoGray100)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(selection == language ? Color.apayoGreen : .clear)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selection == language ? .isSelected : [])
                }
            }
            .padding(.top, 26)

            Spacer(minLength: 12)

            APAYOButton(
                title: LocalizedStringKey((selection ?? .english).localized("common.next")),
                isDisabled: selection == nil,
                action: onNext
            )
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .padding(.bottom, 1)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    LanguageSelectionView(onNext: {})
        .environmentObject(AppLanguageStore())
}
