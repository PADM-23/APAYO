import SwiftUI

struct SymptomAnalysisLoadingView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    let onBack: () -> Void
    let animatesWaitText: Bool
    let operation: (() async -> Bool)?
    let onFailure: () -> Void
    let onComplete: () -> Void

    @State private var didComplete = false

    init(
        onBack: @escaping () -> Void,
        animatesWaitText: Bool = false,
        operation: (() async -> Bool)? = nil,
        onFailure: @escaping () -> Void = {},
        onComplete: @escaping () -> Void
    ) {
        self.onBack = onBack
        self.animatesWaitText = animatesWaitText
        self.operation = operation
        self.onFailure = onFailure
        self.onComplete = onComplete
    }

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

            waitText
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

            if let operation {
                let succeeded = await operation()
                guard !Task.isCancelled else { return }
                guard succeeded else {
                    onFailure()
                    return
                }
            } else {
                try? await Task.sleep(for: .seconds(1.6))
            }

            guard !Task.isCancelled else { return }
            didComplete = true
            onComplete()
        }
    }

    @ViewBuilder
    private var waitText: some View {
        Group {
            if animatesWaitText && !accessibilityReduceMotion {
                TimelineView(.periodic(from: .now, by: 0.45)) { context in
                    let dotCount = Int(context.date.timeIntervalSinceReferenceDate / 0.45) % 3 + 1

                    Text(waitTextBase + "...")
                        .hidden()
                        .overlay {
                            Text(waitTextBase + String(repeating: ".", count: dotCount))
                        }
                }
            } else {
                Text(languageStore.language.localized("loading.wait"))
            }
        }
        .font(.body)
        .foregroundStyle(Color.apayoGray800)
        .frame(maxWidth: .infinity)
    }

    private var waitTextBase: String {
        languageStore.language.localized("loading.wait")
            .trimmingCharacters(in: CharacterSet(charactersIn: ".… "))
    }
}

#Preview {
    NavigationStack {
        SymptomAnalysisLoadingView(onBack: {}, onComplete: {})
    }
}
