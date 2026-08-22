import SwiftUI

struct PatientFlowView: View {
    @State private var path: [PatientFlowRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            LanguageSelectionView {
                path.append(.symptomInput)
            }
            .navigationDestination(for: PatientFlowRoute.self) { route in
                destination(for: route)
            }
        }
        .tint(.apayoGreen)
    }

    @ViewBuilder
    private func destination(for route: PatientFlowRoute) -> some View {
        switch route {
        case .symptomInput:
            SymptomInputView { path.append(.symptomConfirmation) }
        case .symptomConfirmation:
            SymptomConfirmationView { path.append(.durationInterview) }
        case .durationInterview:
            SingleChoiceInterviewView(
                title: "언제부터 불편하셨나요?",
                subtitle: "통증이 시작된 대략적인 시점을 알려주세요.",
                step: (1, 2),
                options: PreviewMockData.durationOptions
            ) { path.append(.frequencyInterview) }
        case .frequencyInterview:
            SingleChoiceInterviewView(
                title: "통증이 얼마나 자주,\n어떻게 나타나나요?",
                subtitle: "일상생활이나 활동 중 증상을 선택해 주세요.",
                step: (2, 2),
                options: PreviewMockData.frequencyOptions
            ) { path.append(.intensityInterview) }
        case .intensityInterview:
            PainIntensityView {
                path.append(.accompanyingSymptoms)
            }
        case .accompanyingSymptoms:
            MultiChoiceInterviewView(
                title: "통증 외에 같이 나타나는\n증상이 있나요?",
                subtitle: "현재 겪고 계신 모든 동반 증상을 체크해 주세요.",
                options: PreviewMockData.accompanyingOptions
            ) { path.append(.medicationInterview) }
        case .medicationInterview:
            MultiChoiceInterviewView(
                title: "증상이 나타난 후\n응급 복용한 약이 있나요?",
                subtitle: "증상 발생 후 드신 약을 모두 선택해 주세요",
                options: PreviewMockData.medicationOptions
            ) {
                path.append(.workContextInterview)
            }
        case .workContextInterview:
            WorkEnvironmentInterviewView()
        case .medicalSummary:
            MedicalSummaryView {
                path.append(.facilitySearch)
            }
        case .facilitySearch:
            APAYOStateView(
                kind: .empty,
                title: "주변 병원을 찾고 있어요",
                message: "병원 검색 기능은 다음 단계에서 연결됩니다.",
                actionTitle: "처음으로"
            ) {
                path.removeAll()
            }
            .navigationTitle("병원 찾기")
        }
    }
}

#Preview {
    PatientFlowView()
}
