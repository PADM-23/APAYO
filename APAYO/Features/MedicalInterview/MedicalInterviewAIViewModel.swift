import Foundation
import Observation

enum FollowUpGenerationState: Equatable {
    case idle
    case loading
    case success(FollowUpQuestionsResponse)
    case failure(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

enum MedicalSummaryGenerationState: Equatable {
    case idle
    case loading
    case success(MedicalInterviewSummaryResponse)
    case failure(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

@MainActor
@Observable
final class MedicalInterviewAIViewModel {
    private(set) var followUpState: FollowUpGenerationState = .idle
    private(set) var summaryState: MedicalSummaryGenerationState = .idle
    private(set) var selectedQuestionIDs: Set<FollowUpQuestionID> = []
    private(set) var selectedCardAssetName = "SymptomCard_Default"

    private let service: any MedicalInterviewServing
    private let catalogLoader: any SymptomCardCatalogLoading

    init(
        service: (any MedicalInterviewServing)? = nil,
        catalogLoader: (any SymptomCardCatalogLoading)? = nil
    ) {
        self.service = service ?? MedicalInterviewService()
        self.catalogLoader = catalogLoader ?? InterviewCatalogLoader()
    }

    func generateFollowUpQuestions(context: MedicalInterviewContext) async {
        guard !followUpState.isLoading else { return }

        followUpState = .loading
        summaryState = .idle
        selectedQuestionIDs = []
        selectedCardAssetName = "SymptomCard_Default"

        do {
            let response = try await service.generateFollowUpQuestions(
                request: FollowUpQuestionsRequest(
                    schemaVersion: "2.0",
                    context: context
                )
            )
            try validate(response)
            followUpState = .success(response)
        } catch is CancellationError {
            followUpState = .idle
        } catch {
            followUpState = .failure(message(for: error, fallback: "추가 질문을 만들지 못했습니다."))
        }
    }

    func toggleSelection(for questionID: FollowUpQuestionID) {
        guard generatedQuestionIDs.contains(questionID) else { return }

        if selectedQuestionIDs.contains(questionID) {
            selectedQuestionIDs.remove(questionID)
        } else {
            selectedQuestionIDs.insert(questionID)
        }

        summaryState = .idle
        selectedCardAssetName = "SymptomCard_Default"
    }

    func generateMedicalSummary(context: MedicalInterviewContext) async {
        guard !summaryState.isLoading else { return }
        guard case .success = summaryState else {
            await requestMedicalSummary(context: context)
            return
        }
    }

    private func requestMedicalSummary(context: MedicalInterviewContext) async {
        guard case .success(let followUpResponse) = followUpState else {
            summaryState = .failure("먼저 추가 질문을 생성해 주세요.")
            return
        }

        summaryState = .loading

        do {
            let cards = try catalogLoader.loadSymptomCards()
            let selectedIDs = selectedQuestionIDs.sorted { $0.rawValue < $1.rawValue }
            let response = try await service.generateMedicalSummary(
                request: MedicalInterviewSummaryRequest(
                    schemaVersion: "2.0",
                    context: context,
                    questionGroups: followUpResponse.questionGroups,
                    selectedFollowUpQuestionIDs: selectedIDs,
                    allowedCardIDs: cards.cards.map(\.id)
                )
            )
            try validate(response, allowedCardIDs: Set(cards.cards.map(\.id)))
            selectedCardAssetName = cards.cards.first(where: { $0.id == response.selectedCardID })?.assetName
                ?? "SymptomCard_Default"
            summaryState = .success(response)
        } catch is CancellationError {
            summaryState = .idle
        } catch {
            summaryState = .failure(message(for: error, fallback: "의료진용 요약을 만들지 못했습니다."))
        }
    }

    func reset() {
        followUpState = .idle
        summaryState = .idle
        selectedQuestionIDs = []
        selectedCardAssetName = "SymptomCard_Default"
    }

    private var generatedQuestionIDs: Set<FollowUpQuestionID> {
        guard case .success(let response) = followUpState else { return [] }
        return Set(response.questionGroups.flatMap(\.questions).map(\.id))
    }

    private func validate(_ response: FollowUpQuestionsResponse) throws {
        let questions = response.questionGroups.flatMap(\.questions)
        let uniqueIDs = Set(questions.map(\.id))

        guard response.schemaVersion == "2.0",
              (1...2).contains(response.questionGroups.count),
              (2...4).contains(questions.count),
              uniqueIDs.count == questions.count,
              questions.allSatisfy({ $0.answerType == .checkboxYes }) else {
            throw MedicalInterviewClientError.invalidFollowUpResponse
        }
    }

    private func validate(
        _ response: MedicalInterviewSummaryResponse,
        allowedCardIDs: Set<String>
    ) throws {
        guard response.schemaVersion == "2.0",
              !response.symptoms.isEmpty,
              allowedCardIDs.contains(response.selectedCardID),
              !response.medicalSummaryKo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw MedicalInterviewClientError.invalidSummaryResponse
        }
    }

    private func message(for error: Error, fallback: String) -> String {
        let message = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return message.isEmpty ? fallback : message
    }
}

private enum MedicalInterviewClientError: LocalizedError {
    case invalidFollowUpResponse
    case invalidSummaryResponse

    var errorDescription: String? {
        switch self {
        case .invalidFollowUpResponse:
            return "추가 질문 응답 형식이 올바르지 않습니다."
        case .invalidSummaryResponse:
            return "의료진용 요약 응답 형식이 올바르지 않습니다."
        }
    }
}
