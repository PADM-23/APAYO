import Foundation

struct SymptomAnalysisRequest: Encodable, Equatable {
    let schemaVersion: String
    let input: SymptomInput
    let workContext: WorkContext?
    let weatherContext: WeatherContext?
    let allowedCardIDs: [String]
    let allowedQuestionIDs: [String]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case input
        case workContext = "work_context"
        case weatherContext = "weather_context"
        case allowedCardIDs = "allowed_card_ids"
        case allowedQuestionIDs = "allowed_question_ids"
    }
}

struct SymptomInput: Encodable, Equatable {
    let text: String
    let languageHint: String?
}

struct WorkContext: Codable, Equatable {
    let workedToday: Bool
    let workType: String?
    let pesticideExposure: ExposureStatus
    let injuryOrFall: ExposureStatus

    enum CodingKeys: String, CodingKey {
        case workedToday = "worked_today"
        case workType = "work_type"
        case pesticideExposure = "pesticide_exposure"
        case injuryOrFall = "injury_or_fall"
    }
}

struct WeatherContext: Codable, Equatable {
    let observedAt: String
    let temperatureCelsius: Double
    let humidityPercent: Int
    let heatWarning: Bool

    enum CodingKeys: String, CodingKey {
        case observedAt = "observed_at"
        case temperatureCelsius = "temperature_celsius"
        case humidityPercent = "humidity_percent"
        case heatWarning = "heat_warning"
    }
}

enum ExposureStatus: String, Codable, Equatable {
    case yes
    case no
    case unknown
}

struct SymptomAnalysisResponse: Decodable, Equatable {
    let schemaVersion: String
    let detectedLanguage: DetectedLanguage
    let symptoms: [StructuredSymptom]
    let selectedCardID: String
    let selectedQuestionIDs: [String]
    let safetyFlags: [SafetyFlag]
    let clarificationNoteKo: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case detectedLanguage = "detected_language"
        case symptoms
        case selectedCardID = "selected_card_id"
        case selectedQuestionIDs = "selected_question_ids"
        case safetyFlags = "safety_flags"
        case clarificationNoteKo = "clarification_note_ko"
    }
}

struct DetectedLanguage: Decodable, Equatable {
    let code: String
    let name: String
}

struct StructuredSymptom: Decodable, Equatable {
    let nameKo: String
    let bodyPartKo: String?
    let onsetTextKo: String?
    let severity: Int?

    enum CodingKeys: String, CodingKey {
        case nameKo = "name_ko"
        case bodyPartKo = "body_part_ko"
        case onsetTextKo = "onset_text_ko"
        case severity
    }
}

enum SafetyFlag: String, Decodable, Equatable {
    case breathingDifficulty = "breathing_difficulty"
    case lossOfConsciousness = "loss_of_consciousness"
    case severeChestSymptom = "severe_chest_symptom"
    case strokeLikeSymptom = "stroke_like_symptom"
    case severeBleeding = "severe_bleeding"
    case possibleSevereAllergicReaction = "possible_severe_allergic_reaction"
}
