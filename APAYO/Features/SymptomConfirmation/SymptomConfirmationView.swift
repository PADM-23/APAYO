import SwiftUI

struct SymptomConfirmationView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            APAYOProgressBar(currentStep: 1, totalSteps: 3)

            Text("이 증상이 맞나요?")
                .font(.largeTitle.bold())

            Label(PreviewMockData.symptom, systemImage: "quote.bubble.fill")
                .font(.title3.weight(.medium))
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.apayoBackground, in: RoundedRectangle(cornerRadius: 20))

            Spacer()

            APAYOButton(title: "네, 맞아요", systemImage: "checkmark", action: onNext)
        }
        .padding(APAYOTheme.horizontalPadding)
        .navigationTitle("증상 확인")
        .navigationBarTitleDisplayMode(.inline)
    }
}
