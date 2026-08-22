import Foundation
import UIKit

enum InterviewCatalogValidationError: LocalizedError, Equatable {
    case unsupportedSchemaVersion(String)
    case duplicateCardID(String)
    case duplicateQuestionID(String)
    case invalidFallbackCount(Int)
    case invalidFallbackID(String)
    case emptyCardField(cardID: String)
    case emptyQuestionPrompt(questionID: String)
    case missingImage(assetName: String)
    case notEnoughQuestions(Int)

    var errorDescription: String? {
        switch self {
        case .unsupportedSchemaVersion(let version):
            return "지원하지 않는 카탈로그 스키마 버전입니다: \(version)"
        case .duplicateCardID(let id):
            return "카드 ID가 중복되었습니다: \(id)"
        case .duplicateQuestionID(let id):
            return "질문 ID가 중복되었습니다: \(id)"
        case .invalidFallbackCount(let count):
            return "fallback 카드는 정확히 1개여야 하지만 \(count)개입니다."
        case .invalidFallbackID(let id):
            return "fallback 카드 ID는 card_default여야 하지만 \(id)입니다."
        case .emptyCardField(let cardID):
            return "카드의 필수 문구가 비어 있습니다: \(cardID)"
        case .emptyQuestionPrompt(let questionID):
            return "질문 문구가 비어 있습니다: \(questionID)"
        case .missingImage(let assetName):
            return "Asset Catalog에서 이미지를 찾을 수 없습니다: \(assetName)"
        case .notEnoughQuestions(let count):
            return "후속 질문은 최소 2개가 필요하지만 \(count)개입니다."
        }
    }
}

struct InterviewCatalogValidator {
    private let supportedSchemaVersion = "1.0"
    private let assetExists: (String) -> Bool

    init(assetExists: @escaping (String) -> Bool = { UIImage(named: $0) != nil }) {
        self.assetExists = assetExists
    }

    func validate(
        cards: SymptomCardCatalog,
        questions: FollowUpQuestionCatalog
    ) throws {
        guard cards.schemaVersion == supportedSchemaVersion else {
            throw InterviewCatalogValidationError.unsupportedSchemaVersion(cards.schemaVersion)
        }
        guard questions.schemaVersion == supportedSchemaVersion else {
            throw InterviewCatalogValidationError.unsupportedSchemaVersion(questions.schemaVersion)
        }

        if let duplicateID = firstDuplicate(in: cards.cards.map(\.id)) {
            throw InterviewCatalogValidationError.duplicateCardID(duplicateID)
        }
        if let duplicateID = firstDuplicate(in: questions.questions.map(\.id)) {
            throw InterviewCatalogValidationError.duplicateQuestionID(duplicateID)
        }

        let fallbackCards = cards.cards.filter(\.isFallback)
        guard fallbackCards.count == 1 else {
            throw InterviewCatalogValidationError.invalidFallbackCount(fallbackCards.count)
        }
        guard fallbackCards[0].id == "card_default" else {
            throw InterviewCatalogValidationError.invalidFallbackID(fallbackCards[0].id)
        }

        for card in cards.cards {
            guard !card.id.isBlank,
                  !card.assetName.isBlank,
                  !card.titleKo.isBlank,
                  !card.titleEn.isBlank,
                  !card.concept.isBlank else {
                throw InterviewCatalogValidationError.emptyCardField(cardID: card.id)
            }
            guard assetExists(card.assetName) else {
                throw InterviewCatalogValidationError.missingImage(assetName: card.assetName)
            }
        }

        guard questions.questions.count >= 2 else {
            throw InterviewCatalogValidationError.notEnoughQuestions(questions.questions.count)
        }
        for question in questions.questions {
            guard !question.prompt.ko.isBlank, !question.prompt.en.isBlank else {
                throw InterviewCatalogValidationError.emptyQuestionPrompt(questionID: question.id)
            }
        }
    }

    private func firstDuplicate(in values: [String]) -> String? {
        var seen = Set<String>()
        return values.first { !seen.insert($0).inserted }
    }
}

private extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
