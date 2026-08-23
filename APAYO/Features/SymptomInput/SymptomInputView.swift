import SwiftUI

struct SymptomInputView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    @Binding var symptom: String
    let onNeedGuidance: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)

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

            Spacer(minLength: 24)

            Text(languageStore.language.localized("symptom.title"))
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 346)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 0)

            Spacer().frame(height: 38)

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

            HStack(alignment: .bottom, spacing: 8) {
                TextField(
                    languageStore.language.localized("symptom.placeholder"),
                    text: $symptom,
                    axis: .vertical
                )
                    .font(.body)
                    .lineLimit(1...4)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .frame(minHeight: 50, alignment: .topLeading)
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

            Spacer(minLength: 24)

            Button(action: onNeedGuidance) {
                HStack(spacing: 14) {
                    Image(systemName: "safari.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.apayoGreen)
                        .frame(width: 42, height: 42)
                        .background(Color.apayoBrightGreen.opacity(0.2), in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(languageStore.language.localized("symptom.guide.title"))
                            .font(.headline)
                            .foregroundStyle(Color.apayoGray800)

                        Text(languageStore.language.localized("symptom.guide.subtitle"))
                            .font(.subheadline)
                            .foregroundStyle(Color.apayoGray600)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.apayoGreen)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, minHeight: 78)
                .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: APAYOTheme.listCornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: APAYOTheme.listCornerRadius, style: .continuous)
                        .stroke(Color.apayoGreen.opacity(0.22), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, APAYOTheme.horizontalPadding)
            .accessibilityElement(children: .combine)

            Spacer().frame(height: 24)
        }
        .background {
            GeometryReader { geometry in
                ZStack {
                    Color.apayoBackground

                    Image("SymptomInputBackground")
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .clipped()
                }
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var suggestionItems: [String] {
        [
            "symptom.suggestion.stomachache",
            "symptom.suggestion.dizziness",
            "symptom.suggestion.cough"
        ]
        .map(languageStore.language.localized)
    }
}

#Preview {
    NavigationStack {
        SymptomInputView(
            symptom: .constant(""),
            onNeedGuidance: {},
            onNext: {}
        )
        .environmentObject(AppLanguageStore())
    }
}
