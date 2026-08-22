import Foundation

enum PatientFlowRoute: Hashable {
    case chronicConditions
    case allergies
    case familyHistory
    case substanceUse
    case surgeryHistory
    case symptomInput
    case symptomAnalysis
    case symptomConfirmation
    case interviewStart
    case durationInterview
    case frequencyInterview
    case intensityInterview
    case accompanyingSymptoms
    case medicationInterview
    case aiFollowUp
    case medicalSummary
    case facilitySearch
}

struct WorkEnvironmentResponse: Equatable {
    var selectedConditions: Set<String> = []
    var weatherSummary: String?
}

struct InterviewQuestion: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String?
    let options: [QuestionOption]

    init(id: UUID = UUID(), title: String, subtitle: String? = nil, options: [QuestionOption]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.options = options
    }
}
