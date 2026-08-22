import Foundation

struct SymptomCardCatalog: Decodable, Equatable {
    let schemaVersion: String
    let cards: [SymptomCard]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case cards
    }
}

struct SymptomCard: Decodable, Equatable, Identifiable {
    let id: String
    let assetName: String
    let titleKo: String
    let titleEn: String
    let concept: String
    let isFallback: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case assetName = "asset_name"
        case titleKo = "title_ko"
        case titleEn = "title_en"
        case concept
        case isFallback = "is_fallback"
    }
}

struct FollowUpQuestionCatalog: Decodable, Equatable {
    let schemaVersion: String
    let questions: [FollowUpQuestion]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case questions
    }
}

struct FollowUpQuestion: Decodable, Equatable, Identifiable {
    let id: String
    let category: QuestionCategory
    let answerType: QuestionAnswerType
    let prompt: LocalizedPrompt

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case answerType = "answer_type"
        case prompt
    }
}

struct LocalizedPrompt: Decodable, Equatable {
    let ko: String
    let en: String
}

enum QuestionCategory: String, Decodable, Equatable {
    case symptomDetail = "symptom_detail"
    case associatedSymptom = "associated_symptom"
    case safety
    case workEnvironment = "work_environment"
    case medicalContext = "medical_context"
}

enum QuestionAnswerType: String, Decodable, Equatable {
    case shortText = "short_text"
    case scale0To10 = "scale_0_to_10"
    case yesNoUnknown = "yes_no_unknown"
}
