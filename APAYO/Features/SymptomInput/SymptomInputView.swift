import SwiftUI

struct SymptomInputView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    @Binding var symptom: String
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 72)

            Menu {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        languageStore.select(language)
                    } label: {
                        Label(language.nativeName, image: language.imageName)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(languageStore.language.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                    Text(languageStore.language.nativeName)
                        .font(.callout.weight(.semibold))
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(Color.apayoGray700)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.systemBackground), in: Capsule())
                .overlay { Capsule().stroke(Color.apayoGray300, lineWidth: 2) }
            }

            Text(languageStore.language.localized("symptom.title"))
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 346)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 54)

            Spacer().frame(height: 58)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(suggestionItems.enumerated()), id: \.offset) { _, item in
                        Text(item)
                            .font(.subheadline)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.7), in: Capsule())
                    }
                }
                .padding(.horizontal, APAYOTheme.horizontalPadding)
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                TextField(languageStore.language.localized("symptom.placeholder"), text: $symptom)
                    .font(.body)
                    .padding(.horizontal, 20)
                    .frame(height: 50)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))

                Button(action: onNext) {
                    Image(systemName: "arrow.right")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.apayoGreen, in: Circle())
                }
                .disabled(symptom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, APAYOTheme.horizontalPadding)
            .padding(.top, 18)

            Spacer()
        }
        .background {
            ZStack {
                Color(.systemBackground)
                RadialGradient(
                    colors: [
                        Color.apayoBrightGreen.opacity(0.62),
                        Color.apayoYellow.opacity(0.42),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: 0.43),
                    startRadius: 18,
                    endRadius: 230
                )
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var suggestionItems: [String] {
        Array(repeating: languageStore.language.localized("symptom.suggestion"), count: 3)
    }
}

#Preview {
    NavigationStack {
        SymptomInputView(
            symptom: .constant(""),
            onNext: {}
        )
        .environmentObject(AppLanguageStore())
    }
}
