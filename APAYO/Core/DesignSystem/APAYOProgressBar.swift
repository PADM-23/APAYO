import SwiftUI

struct APAYOProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        Text("\(currentStep)/\(totalSteps)")
            .font(.body.weight(.semibold))
            .foregroundStyle(Color.apayoGreen)
            .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("문진 진행률")
        .accessibilityValue("\(totalSteps)단계 중 \(currentStep)단계")
    }
}
