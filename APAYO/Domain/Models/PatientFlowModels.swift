import Foundation

enum PatientFlowRoute: Hashable {
    case symptomInput
    case symptomConfirmation
    case durationInterview
    case frequencyInterview
    case intensityInterview
    case accompanyingSymptoms
    case medicationInterview
    case workContextInterview
    case medicalSummary
    case facilitySearch
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
