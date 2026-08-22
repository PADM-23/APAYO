import SwiftUI

struct SymptomAnalysisLoadingView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var didComplete = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Text(languageStore.language.localized("loading.title"))
                    .font(.title2.bold())
                Text(languageStore.language.localized("loading.subtitle"))
                    .font(.body)
                    .foregroundStyle(Color.apayoGray800)
            }
            .padding(.top, 38)

            Spacer(minLength: 20)

            Image("SymptomCards/Loading")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)

            Spacer(minLength: 20)

            Text(languageStore.language.localized("loading.wait"))
                .font(.body)
                .foregroundStyle(Color.apayoGray800)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 125)
        }
        .padding(.horizontal, 27)
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle(languageStore.language.localized("navigation.symptom"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.backward")
                }
            }
        }
        .task {
            guard !didComplete else { return }
            try? await Task.sleep(for: .seconds(1.6))
            guard !Task.isCancelled else { return }
            didComplete = true
            onComplete()
        }
    }
}

#Preview {
    NavigationStack {
        SymptomAnalysisLoadingView(onBack: {}, onComplete: {})
    }
}
