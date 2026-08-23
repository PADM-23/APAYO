import Foundation

enum SymptomAnalysisValidationError: LocalizedError, Equatable {
    case unsupportedSchemaVersion(String)
    case invalidSymptomCount(Int)
    case emptySymptomName
    case invalidSeverity(Int)
    case invalidQuestionCount(Int)

    var errorDescription: String? {
        switch self {
        case .unsupportedSchemaVersion(let version):
            return "지원하지 않는 AI 응답 스키마 버전입니다: \(version)"
        case .invalidSymptomCount(let count):
            return "구조화된 증상은 1개 이상 5개 이하여야 하지만 \(count)개입니다."
        case .emptySymptomName:
            return "구조화된 증상의 한국어 이름이 비어 있습니다."
        case .invalidSeverity(let severity):
            return "증상 강도는 0부터 10까지여야 하지만 \(severity)입니다."
        case .invalidQuestionCount(let count):
            return "유효한 후속 질문은 2개 이상 4개 이하여야 하지만 \(count)개입니다."
        }
    }
}

struct SymptomAnalysisValidator {
    private let supportedSchemaVersion = "1.0"

    func validateAndNormalize(
        _ response: SymptomAnalysisResponse,
        cards: SymptomCardCatalog,
        questions: FollowUpQuestionCatalog
    ) throws -> SymptomAnalysisResponse {
        guard response.schemaVersion == supportedSchemaVersion else {
            throw SymptomAnalysisValidationError.unsupportedSchemaVersion(response.schemaVersion)
        }
        guard (1...5).contains(response.symptoms.count) else {
            throw SymptomAnalysisValidationError.invalidSymptomCount(response.symptoms.count)
        }

        for symptom in response.symptoms {
            guard !symptom.nameKo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw SymptomAnalysisValidationError.emptySymptomName
            }
            if let severity = symptom.severity, !(0...10).contains(severity) {
                throw SymptomAnalysisValidationError.invalidSeverity(severity)
            }
        }

        let allowedCardIDs = Set(cards.cards.map(\.id))
        let normalizedCardID = allowedCardIDs.contains(response.selectedCardID)
            ? response.selectedCardID
            : "card_default"

        let allowedQuestionIDs = Set(questions.questions.map(\.id))
        var seenQuestionIDs = Set<String>()
        let normalizedQuestionIDs = response.selectedQuestionIDs.filter { id in
            allowedQuestionIDs.contains(id) && seenQuestionIDs.insert(id).inserted
        }

        guard (2...4).contains(normalizedQuestionIDs.count) else {
            throw SymptomAnalysisValidationError.invalidQuestionCount(normalizedQuestionIDs.count)
        }

        return SymptomAnalysisResponse(
            schemaVersion: response.schemaVersion,
            detectedLanguage: response.detectedLanguage,
            symptoms: response.symptoms,
            selectedCardID: normalizedCardID,
            selectedQuestionIDs: normalizedQuestionIDs,
            safetyFlags: response.safetyFlags,
            clarificationNoteKo: response.clarificationNoteKo
        )
    }
}
