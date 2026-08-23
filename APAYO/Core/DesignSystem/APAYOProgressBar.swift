import SwiftUI

struct APAYOProgressBar: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        Text("\(currentStep)/\(totalSteps)")
            .font(.body.weight(.semibold))
            .foregroundStyle(Color.apayoGreen)
            .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(languageStore.language.localized("accessibility.interview_progress"))
        .accessibilityValue("\(totalSteps)단계 중 \(currentStep)단계")
    }
}
