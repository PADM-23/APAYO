import Combine
import Foundation

@MainActor
final class PatientFlowViewModel: ObservableObject {
    @Published var originalSymptom = ""
    @Published var translatedSymptom = ""
    @Published var extractedSymptoms: [String] = []
    @Published var extractedBodyParts: [String] = []

    @Published var chronicConditions: Set<String> = []
    @Published var allergies: Set<String> = []
    @Published var familyHistory: Set<String> = []
    @Published var substanceUse: String?
    @Published var surgeryHistory: String?

    @Published var duration: String?
    @Published var frequency: String?
    @Published var painIntensity: Int?
    @Published var accompanyingSymptoms: Set<String> = []
    @Published var medications: Set<String> = []
    @Published var workEnvironment = WorkEnvironmentResponse()

    func reset() {
        originalSymptom = ""
        translatedSymptom = ""
        extractedSymptoms = []
        extractedBodyParts = []
        chronicConditions = []
        allergies = []
        familyHistory = []
        substanceUse = nil
        surgeryHistory = nil
        duration = nil
        frequency = nil
        painIntensity = nil
        accompanyingSymptoms = []
        medications = []
        workEnvironment = WorkEnvironmentResponse()
    }
}
