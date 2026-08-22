import SwiftUI

struct InterviewStartView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Text(languageStore.language.localized("interview.start.title"))
                    .font(.title2.bold())
                Text(languageStore.language.localized("interview.start.subtitle"))
                    .font(.body)
                    .foregroundStyle(Color.apayoGray800)
            }
            .padding(.top, 38)

            Image("SymptomCards/InterviewStart")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.top, 42)

            Spacer(minLength: 24)

            APAYOButton(title: LocalizedStringKey(languageStore.language.localized("common.start")), action: onNext)
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .padding(.bottom, 1)
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle(languageStore.language.localized("navigation.interview_start"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        InterviewStartView(onNext: {})
    }
}
