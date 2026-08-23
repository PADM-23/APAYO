import SwiftUI

struct AIFollowUpView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let viewModel: MedicalInterviewAIViewModel
    let context: MedicalInterviewContext
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            InterviewProgressLine(completedSteps: 4)
                .padding(.top, 10)

            Label {
                Text(text("followup.ai_label"))
                    .font(.headline)
            } icon: {
                Image(systemName: "sparkles.2")
                    .font(.body)
            }
            .foregroundStyle(Color.apayoGreen)
            .padding(.top, 26)

            Text(text("followup.title"))
                .font(.title2.bold())
                .padding(.top, 2)

            Text(text("followup.subtitle"))
                .font(.body)
                .foregroundStyle(Color.apayoGray800)
                .padding(.top, 10)

            followUpContent
                .padding(.top, 62)

            Spacer(minLength: 24)

            if case .success = viewModel.followUpState {
                if case .failure(let message) = viewModel.summaryState {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                }

                APAYOButton(
                    title: LocalizedStringKey(text("common.next")),
                    action: onNext
                )
            }
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .padding(.bottom, 1)
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            guard case .idle = viewModel.followUpState else { return }
            await viewModel.generateFollowUpQuestions(context: context)
        }
    }

    @ViewBuilder
    private var followUpContent: some View {
        switch viewModel.followUpState {
        case .idle, .loading:
            VStack(spacing: 14) {
                ProgressView()
                Text(text("loading.wait"))
                    .font(.body)
                    .foregroundStyle(Color.apayoGray800)
            }
                .frame(maxWidth: .infinity)
        case .failure(let message):
            VStack(spacing: 16) {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)

                Button(text("confirmation.retry")) {
                    Task {
                        await viewModel.generateFollowUpQuestions(context: context)
                    }
                }
                .font(.headline)
                .foregroundStyle(Color.apayoGreen)
            }
            .frame(maxWidth: .infinity)
        case .success(let response):
            VStack(alignment: .leading, spacing: 54) {
                ForEach(Array(response.questionGroups.enumerated()), id: \.offset) { _, group in
                    questionSection(group)
                }
            }
        }
    }

    private func questionSection(_ group: GeneratedQuestionGroup) -> some View {
        VStack(alignment: .leading, spacing: 19) {
            Text(group.titleUser)
                .font(.headline)

            ForEach(group.questions) { question in
                Button {
                    viewModel.toggleSelection(for: question.id)
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isSelected(question) ? Color.apayoBrightGreen : Color.apayoGray100)
                                .overlay {
                                    if !isSelected(question) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.apayoGray400)
                                    }
                                }

                            if isSelected(question) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 27, height: 27)

                        Text(question.promptUser)
                            .font(.body)
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected(question) ? .isSelected : [])
            }
        }
    }

    private func isSelected(_ question: GeneratedFollowUpQuestion) -> Bool {
        viewModel.selectedQuestionIDs.contains(question.id)
    }

    private func text(_ key: String) -> String {
        languageStore.language.localized(key)
    }
}
