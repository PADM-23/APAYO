import Foundation

struct MedicalInterviewContext: Encodable, Equatable {
    let originalSymptom: OriginalSymptom
    let medicalHistory: MedicalHistory
    let baseInterview: BaseInterview
    let weatherContext: WeatherContext?

    enum CodingKeys: String, CodingKey {
        case originalSymptom = "original_symptom"
        case medicalHistory = "medical_history"
        case baseInterview = "base_interview"
        case weatherContext = "weather_context"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(originalSymptom, forKey: .originalSymptom)
        try container.encode(medicalHistory, forKey: .medicalHistory)
        try container.encode(baseInterview, forKey: .baseInterview)

        if let weatherContext {
            try container.encode(weatherContext, forKey: .weatherContext)
        } else {
            try container.encodeNil(forKey: .weatherContext)
        }
    }
}

struct OriginalSymptom: Encodable, Equatable {
    let text: String
    let languageHint: String?

    enum CodingKeys: String, CodingKey {
        case text
        case languageHint = "language_hint"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)

        if let languageHint {
            try container.encode(languageHint, forKey: .languageHint)
        } else {
            try container.encodeNil(forKey: .languageHint)
        }
    }
}

struct MedicalHistory: Encodable, Equatable {
    let chronicConditions: [String]
    let allergies: [String]
    let familyHistory: [String]
    let substanceUse: String?
    let surgeryHistory: String?

    enum CodingKeys: String, CodingKey {
        case chronicConditions = "chronic_conditions"
        case allergies
        case familyHistory = "family_history"
        case substanceUse = "substance_use"
        case surgeryHistory = "surgery_history"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(chronicConditions, forKey: .chronicConditions)
        try container.encode(allergies, forKey: .allergies)
        try container.encode(familyHistory, forKey: .familyHistory)
        try container.encodeOptionalOrNull(substanceUse, forKey: .substanceUse)
        try container.encodeOptionalOrNull(surgeryHistory, forKey: .surgeryHistory)
    }
}

struct BaseInterview: Encodable, Equatable {
    let duration: String?
    let frequency: String?
    let painIntensity: Int?
    let accompanyingSymptoms: [String]
    let medications: [String]
    let workEnvironment: [String]

    enum CodingKeys: String, CodingKey {
        case duration
        case frequency
        case painIntensity = "pain_intensity"
        case accompanyingSymptoms = "accompanying_symptoms"
        case medications
        case workEnvironment = "work_environment"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeOptionalOrNull(duration, forKey: .duration)
        try container.encodeOptionalOrNull(frequency, forKey: .frequency)
        try container.encodeOptionalOrNull(painIntensity, forKey: .painIntensity)
        try container.encode(accompanyingSymptoms, forKey: .accompanyingSymptoms)
        try container.encode(medications, forKey: .medications)
        try container.encode(workEnvironment, forKey: .workEnvironment)
    }
}

struct FollowUpQuestionsRequest: Encodable, Equatable {
    let schemaVersion: String
    let context: MedicalInterviewContext

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case context
    }
}

struct FollowUpQuestionsResponse: Decodable, Equatable {
    let schemaVersion: String
    let detectedLanguage: DetectedLanguage
    let questionGroups: [GeneratedQuestionGroup]
    let safetyFlags: [SafetyFlag]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case detectedLanguage = "detected_language"
        case questionGroups = "question_groups"
        case safetyFlags = "safety_flags"
    }
}

struct GeneratedQuestionGroup: Codable, Equatable {
    let titleUser: String
    let titleKo: String
    let questions: [GeneratedFollowUpQuestion]

    enum CodingKeys: String, CodingKey {
        case titleUser = "title_user"
        case titleKo = "title_ko"
        case questions
    }
}

struct GeneratedFollowUpQuestion: Codable, Equatable, Identifiable {
    let id: FollowUpQuestionID
    let promptUser: String
    let promptKo: String
    let category: FollowUpCategory
    let answerType: FollowUpAnswerType

    enum CodingKeys: String, CodingKey {
        case id
        case promptUser = "prompt_user"
        case promptKo = "prompt_ko"
        case category
        case answerType = "answer_type"
    }
}

enum FollowUpQuestionID: String, Codable, Equatable, Hashable {
    case first = "fq_1"
    case second = "fq_2"
    case third = "fq_3"
    case fourth = "fq_4"
}

enum FollowUpCategory: String, Codable, Equatable {
    case symptomChange = "symptom_change"
    case associatedSymptom = "associated_symptom"
    case safety
    case workEnvironment = "work_environment"
    case exposure
    case medicalContext = "medical_context"
}

enum FollowUpAnswerType: String, Codable, Equatable {
    case checkboxYes = "checkbox_yes"
}

struct MedicalInterviewSummaryRequest: Encodable, Equatable {
    let schemaVersion: String
    let context: MedicalInterviewContext
    let questionGroups: [GeneratedQuestionGroup]
    let selectedFollowUpQuestionIDs: [FollowUpQuestionID]
    let allowedCardIDs: [String]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case context
        case questionGroups = "question_groups"
        case selectedFollowUpQuestionIDs = "selected_follow_up_question_ids"
        case allowedCardIDs = "allowed_card_ids"
    }
}

struct MedicalInterviewSummaryResponse: Decodable, Equatable {
    let schemaVersion: String
    let detectedLanguage: DetectedLanguage
    let symptoms: [StructuredSymptom]
    let selectedCardID: String
    let medicalSummaryUser: String
    let medicalSummaryKo: String
    let safetyFlags: [SafetyFlag]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case detectedLanguage = "detected_language"
        case symptoms
        case selectedCardID = "selected_card_id"
        case medicalSummaryUser = "medical_summary_user"
        case medicalSummaryKo = "medical_summary_ko"
        case safetyFlags = "safety_flags"
    }
}

private extension KeyedEncodingContainer {
    mutating func encodeOptionalOrNull<Value: Encodable>(
        _ value: Value?,
        forKey key: Key
    ) throws {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }
}
