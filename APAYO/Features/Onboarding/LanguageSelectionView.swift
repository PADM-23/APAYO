import SwiftUI

struct LanguageOption: Identifiable, Hashable {
    let id: String
    let nativeName: String
    let englishName: String
    let imageName: String
}

struct LanguageSelectionView: View {
    let onNext: () -> Void
    @State private var selection: LanguageOption?

    private let languages = [
        LanguageOption(id: "en", nativeName: "English", englishName: "English", imageName: "FlagEnglish"),
        LanguageOption(id: "fil", nativeName: "Wikang Filipino", englishName: "Filipino", imageName: "FlagFilipino"),
        LanguageOption(id: "vi", nativeName: "Tiếng Việt", englishName: "Vietnamese", imageName: "FlagVietnamese"),
        LanguageOption(id: "zh", nativeName: "中國語", englishName: "Chinese", imageName: "FlagChinese"),
        LanguageOption(id: "ru", nativeName: "ру́сский язы́к", englishName: "Russian", imageName: "FlagRussian"),
        LanguageOption(id: "km", nativeName: "ភាសាខ្មែរ", englishName: "Cambodian", imageName: "FlagCambodian")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            APAYOProgressBar(currentStep: 1, totalSteps: 2)
                .padding(.top, 42)

            VStack(alignment: .leading, spacing: 10) {
                Text("Which language are you\ncomfortable with?")
                    .font(.title2.bold())
                Text("Please select your preferred language.")
                    .font(.body)
                    .foregroundStyle(Color.apayoGray800)
            }
            .padding(.top, 20)

            VStack(spacing: 8) {
                ForEach(languages) { language in
                    Button {
                        selection = language
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

            APAYOButton(title: "다음", isDisabled: selection == nil, action: onNext)
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .padding(.bottom, 1)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    LanguageSelectionView(onNext: {})
}
