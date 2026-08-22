import Foundation
import Observation

enum SymptomAnalysisViewState: Equatable {
    case idle
    case loading
    case success(SymptomAnalysisResponse)
    case failure(String)

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}

@MainActor
@Observable
final class SymptomAnalysisViewModel {
    private(set) var state: SymptomAnalysisViewState = .idle

    private let service: any SymptomAnalyzing
    private let catalogLoader: InterviewCatalogLoader
    private let validator: SymptomAnalysisValidator

    init(
        service: (any SymptomAnalyzing)? = nil,
        catalogLoader: InterviewCatalogLoader? = nil,
        validator: SymptomAnalysisValidator? = nil
    ) {
        self.service = service ?? SymptomAnalysisService()
        self.catalogLoader = catalogLoader ?? InterviewCatalogLoader()
        self.validator = validator ?? SymptomAnalysisValidator()
    }

    func analyze(
        text: String,
        languageHint: String?,
        workContext: WorkContext? = nil,
        weatherContext: WeatherContext? = nil
    ) async {
        guard !state.isLoading else { return }

        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            state = .failure("증상을 입력해 주세요.")
            return
        }

        state = .loading

        do {
            let cards = try catalogLoader.loadSymptomCards()
            let questions = try catalogLoader.loadFollowUpQuestions()
            let request = SymptomAnalysisRequest(
                schemaVersion: "1.0",
                input: SymptomInput(text: trimmedText, languageHint: languageHint),
                workContext: workContext,
                weatherContext: weatherContext,
                allowedCardIDs: cards.cards.map(\.id),
                allowedQuestionIDs: questions.questions.map(\.id)
            )

            let response = try await service.analyze(request)
            let validatedResponse = try validator.validateAndNormalize(
                response,
                cards: cards,
                questions: questions
            )
            state = .success(validatedResponse)
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failure(
                error.localizedDescription.isEmpty
                    ? "증상 분석에 실패했습니다. 잠시 후 다시 시도해 주세요."
                    : error.localizedDescription
            )
        }
    }

    func reset() {
        state = .idle
    }
}
