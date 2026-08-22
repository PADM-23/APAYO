import SwiftUI

struct AIFollowUpView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    @Binding var selections: Set<String>
    let onNext: () -> Void

    private let heatQuestions = [
        "followup.long_work", "followup.hottest", "followup.rest_water"
    ]

    private let externalQuestions = [
        "followup.enclosed"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            InterviewProgressLine(completedSteps: 4)
                .padding(.top, 10)

            Text("AI")
                .font(.headline)
                .foregroundStyle(Color.apayoGreen)
                .padding(.top, 26)

            Text(text("followup.title"))
                .font(.title2.bold())
                .padding(.top, 2)

            Text(text("followup.subtitle"))
                .font(.body)
                .foregroundStyle(Color.apayoGray800)
                .padding(.top, 10)

            questionSection(title: text("followup.heat"), questions: heatQuestions)
                .padding(.top, 62)

            questionSection(title: text("followup.external"), questions: externalQuestions)
                .padding(.top, 54)

            Spacer(minLength: 24)

            APAYOButton(title: LocalizedStringKey(text("common.next")), action: onNext)
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .padding(.bottom, 1)
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func questionSection(title: String, questions: [String]) -> some View {
        VStack(alignment: .leading, spacing: 19) {
            Text(title)
                .font(.headline)

            ForEach(questions, id: \.self) { question in
                Button {
                    toggle(question)
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selections.contains(question) ? Color.apayoBrightGreen : Color.apayoGray100)
                                .overlay {
                                    if !selections.contains(question) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.apayoGray400)
                                    }
                                }

                            if selections.contains(question) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 27, height: 27)

                        Text(text(question))
                            .font(.callout)
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selections.contains(question) ? .isSelected : [])
            }
        }
    }

    private func toggle(_ question: String) {
        if selections.contains(question) {
            selections.remove(question)
        } else {
            selections.insert(question)
        }
    }

    private func text(_ key: String) -> String {
        languageStore.language.localized(key)
    }
}

#Preview {
    AIFollowUpView(selections: .constant([
        "오늘 야외 또는 비닐하우스 내 작업 시간이 4시간 이상인가요?",
        "밀폐되고 환기가 되지 않는 공간(ex 비닐하우스 내부, 창고)에서 작업하셨나요?"
    ]), onNext: {})
}
