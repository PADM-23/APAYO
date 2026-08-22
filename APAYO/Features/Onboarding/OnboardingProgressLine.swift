import SwiftUI

struct OnboardingProgressLine: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let completedSteps: Int
    private let totalSteps = 6

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...totalSteps, id: \.self) { step in
                node(for: step)

                if step < totalSteps {
                    Rectangle()
                        .fill(step < completedSteps ? Color.apayoGreen : Color.apayoGray300)
                        .frame(maxWidth: .infinity)
                        .frame(height: 4)
                }
            }
        }
        .frame(height: 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(languageStore.language.localized("accessibility.onboarding_progress"))
        .accessibilityValue(
            String(
                format: languageStore.language.localized("accessibility.onboarding_value"),
                completedSteps
            )
        )
    }

    @ViewBuilder
    private func node(for step: Int) -> some View {
        if step <= completedSteps {
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(Color.apayoBrightGreen, in: Circle())
                .overlay { Circle().stroke(Color.apayoGreen, lineWidth: 2) }
        } else {
            Text("\(step)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.apayoGray300)
                .frame(width: 19, height: 19)
                .background(Color.white, in: Circle())
                .overlay { Circle().stroke(Color.apayoGray300, lineWidth: 2) }
        }
    }
}
