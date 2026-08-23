import SwiftUI

struct PatientFlowView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    @State private var path: [PatientFlowRoute] = []
    @StateObject private var viewModel = PatientFlowViewModel()
    @State private var aiViewModel = MedicalInterviewAIViewModel()

    var body: some View {
        NavigationStack(path: $path) {
            LanguageSelectionView {
                path.append(.chronicConditions)
            }
            .navigationDestination(for: PatientFlowRoute.self) { route in
                destination(for: route)
            }
        }
        .tint(.apayoGreen)
        .alert(
            fallbackTitle,
            isPresented: Binding(
                get: { languageStore.fallbackReason != nil },
                set: { if !$0 { languageStore.clearFallbackReason() } }
            )
        ) {
            Button(text("common.dismiss")) {
                languageStore.clearFallbackReason()
            }
        } message: {
            Text(fallbackMessage)
        }
    }

    @ViewBuilder
    private func destination(for route: PatientFlowRoute) -> some View {
        switch route {
        case .chronicConditions:
            MedicalHistoryOnboardingView(
                title: text("onboarding.chronic.title"),
                subtitle: text("onboarding.chronic.subtitle"),
                completedSteps: 1,
                options: [
                    "condition.hypertension", "condition.diabetes", "condition.heart", "condition.cerebrovascular",
                    "condition.respiratory", "condition.cancer_immune", "condition.liver_kidney", "choice.none"
                ],
                cardHeight: 98,
                noSelectionOption: "choice.none",
                selections: $viewModel.chronicConditions
            ) { path.append(.allergies) }
        case .allergies:
            MedicalHistoryOnboardingView(
                title: text("onboarding.allergy.title"),
                subtitle: text("onboarding.allergy.subtitle"),
                completedSteps: 2,
                options: ["allergy.nuts", "allergy.fish", "allergy.shellfish", "allergy.grain", "allergy.milk", "allergy.pollen", "allergy.fruit", "allergy.latex", "choice.none"],
                cardHeight: 76,
                noSelectionOption: "choice.none",
                selections: $viewModel.allergies
            ) { path.append(.familyHistory) }
        case .familyHistory:
            MedicalHistoryOnboardingView(
                title: text("onboarding.family.title"),
                subtitle: text("onboarding.family.subtitle"),
                completedSteps: 3,
                options: [
                    "family.hypertension", "family.diabetes", "family.hyperlipidemia", "family.obesity", "family.heart", "family.stroke",
                    "family.stomach_cancer", "family.colon_cancer", "family.breast_cancer", "family.lung_cancer", "family.osteoporosis", "family.dementia", "choice.none"
                ],
                cardHeight: 68,
                noSelectionOption: "choice.none",
                selections: $viewModel.familyHistory
            ) { path.append(.substanceUse) }
        case .substanceUse:
            SingleChoiceOnboardingView(
                title: text("onboarding.substance.title"),
                subtitle: text("onboarding.substance.subtitle"),
                completedSteps: 4,
                options: ["substance.both", "substance.alcohol", "substance.smoking", "substance.neither"],
                selection: $viewModel.substanceUse
            ) { path.append(.surgeryHistory) }
        case .surgeryHistory:
            SingleChoiceOnboardingView(
                title: text("onboarding.surgery.title"),
                subtitle: text("onboarding.surgery.subtitle"),
                completedSteps: 5,
                options: ["binary.yes", "binary.no"],
                selection: $viewModel.surgeryHistory
            ) { path.append(.symptomInput) }
        case .symptomInput:
            SymptomInputView(
                symptom: $viewModel.originalSymptom,
                onNeedGuidance: { path.append(.careGuide) },
                onNext: { path.append(.interviewStart) }
            )
        case .careGuide:
            CareGuideView(
                onCreateSymptomCard: { path.removeLast() },
                onFindFacility: { path.append(.facilitySearch) }
            )
        case .symptomAnalysis:
            SymptomAnalysisLoadingView {
                path.removeLast()
            } onComplete: {
                viewModel.translatedSymptom = "confirmation.heatstroke"
                viewModel.extractedSymptoms = ["confirmation.heatstroke"]
                path.append(.symptomConfirmation)
            }
        case .symptomConfirmation:
            SymptomConfirmationView {
                path.append(.interviewStart)
            } onRetry: {
                path.removeLast(2)
            }
        case .interviewStart:
            InterviewStartView {
                path.append(.durationInterview)
            }
        case .durationInterview:
            SingleChoiceInterviewView(
                title: text("interview.duration.title"),
                subtitle: text("interview.duration.subtitle"),
                step: (1, 2),
                options: PreviewMockData.durationOptions,
                selection: $viewModel.duration
            ) { path.append(.frequencyInterview) }
        case .frequencyInterview:
            SingleChoiceInterviewView(
                title: text("interview.frequency.title"),
                subtitle: text("interview.frequency.subtitle"),
                step: (2, 2),
                options: PreviewMockData.frequencyOptions,
                selection: $viewModel.frequency
            ) { path.append(.intensityInterview) }
        case .intensityInterview:
            PainIntensityView(intensity: $viewModel.painIntensity) {
                path.append(.accompanyingSymptoms)
            }
        case .accompanyingSymptoms:
            MultiChoiceInterviewView(
                title: text("interview.accompanying.title"),
                subtitle: text("interview.accompanying.subtitle"),
                options: PreviewMockData.accompanyingOptions,
                selections: $viewModel.accompanyingSymptoms,
                completedSteps: 2
            ) { path.append(.medicationInterview) }
        case .medicationInterview:
            MultiChoiceInterviewView(
                title: text("interview.medication.title"),
                subtitle: text("interview.medication.subtitle"),
                options: PreviewMockData.medicationOptions,
                selections: $viewModel.medications,
                completedSteps: 3,
                noneOptionLocalizationKey: "common.none"
            ) {
                aiViewModel.reset()
                path.append(.aiFollowUp)
            }
        case .aiFollowUp:
            AIFollowUpView(
                viewModel: aiViewModel,
                context: medicalInterviewContext
            ) {
                path.append(.medicalSummary)
            }
        case .medicalSummary:
            MedicalSummaryView(
                viewModel: viewModel,
                aiViewModel: aiViewModel
            ) {
                path.append(.facilitySearch)
            } onBackToSymptomInput: {
                backToSymptomInput()
            }
        case .facilitySearch:
            FacilitySearchView()
        }
    }

    private func text(_ key: String) -> String {
        languageStore.language.localized(key)
    }

    private var medicalInterviewContext: MedicalInterviewContext {
        MedicalInterviewContext(
            originalSymptom: OriginalSymptom(
                text: viewModel.originalSymptom,
                languageHint: languageStore.language.rawValue
            ),
            medicalHistory: MedicalHistory(
                chronicConditions: localizedSelections(viewModel.chronicConditions, excludingNone: true),
                allergies: localizedSelections(viewModel.allergies, excludingNone: true),
                familyHistory: localizedSelections(viewModel.familyHistory, excludingNone: true),
                substanceUse: localizedAnswer(viewModel.substanceUse),
                surgeryHistory: localizedAnswer(viewModel.surgeryHistory)
            ),
            baseInterview: BaseInterview(
                duration: localizedAnswer(viewModel.duration),
                frequency: localizedAnswer(viewModel.frequency),
                painIntensity: viewModel.painIntensity,
                accompanyingSymptoms: localizedSelections(
                    viewModel.accompanyingSymptoms,
                    excludingNone: true
                ),
                medications: localizedSelections(viewModel.medications, excludingNone: true),
                workEnvironment: []
            ),
            weatherContext: nil
        )
    }

    private func localizedSelections(
        _ selections: Set<String>,
        excludingNone: Bool = false
    ) -> [String] {
        selections
            .filter { !excludingNone || $0 != "choice.none" }
            .map { localizedAnswer($0) ?? $0 }
            .sorted()
    }

    private func localizedAnswer(_ answer: String?) -> String? {
        guard let answer else { return nil }
        return answer.contains(".") ? languageStore.language.localized(answer) : answer
    }

    private func backToSymptomInput() {
        guard let symptomInputIndex = path.lastIndex(of: .symptomInput) else { return }
        let routesAfterSymptomInput = path.index(after: symptomInputIndex)..<path.endIndex
        path.removeSubrange(routesAfterSymptomInput)
        aiViewModel.reset()
    }

    private var fallbackTitle: String {
        switch languageStore.fallbackReason {
        case .unsupportedLanguage:
            text("error.unsupported.title")
        case nil:
            ""
        }
    }

    private var fallbackMessage: String {
        switch languageStore.fallbackReason {
        case .unsupportedLanguage:
            text("error.unsupported.message")
        case nil:
            ""
        }
    }
}

#Preview {
    PatientFlowView()
        .environmentObject(AppLanguageStore())
}
