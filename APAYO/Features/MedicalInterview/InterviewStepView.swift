import SwiftUI

private struct InterviewHeader: View {
    let title: String
    let subtitle: String
    let completedSteps: Int
    var substep: (current: Int, total: Int)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            InterviewProgressLine(completedSteps: completedSteps)

            if let substep {
                Text("\(substep.current)/\(substep.total)")
                    .font(.headline)
                    .foregroundStyle(Color.apayoGreen)
                    .padding(.top, 16)
            }

            Text(title)
                .font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, substep == nil ? 58 : 20)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(Color.apayoGray800)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SingleChoiceInterviewView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let title: String
    let subtitle: String
    let step: (current: Int, total: Int)?
    let options: [String]
    @Binding var selection: String?
    let onNext: () -> Void

    @State private var isCustomInputPresented = false
    @State private var customInput = ""

    var body: some View {
        VStack(spacing: 0) {
            InterviewHeader(
                title: title,
                subtitle: subtitle,
                completedSteps: 0,
                substep: step
            )
            .padding(.top, 10)

            VStack(spacing: 8) {
                ForEach(displayedOptions, id: \.self) { option in
                    InterviewOptionButton(title: display(option), isSelected: selection == option) {
                        selection = option
                    }
                }

                Button {
                    if let selection, !options.contains(selection) {
                        customInput = selection
                    }
                    isCustomInputPresented = true
                } label: {
                    Label(languageStore.language.localized("common.custom"), systemImage: "plus")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(Color.apayoGreen)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
            }
            .padding(.top, 26)

            Spacer()
            APAYOButton(title: LocalizedStringKey(languageStore.language.localized("common.next")), isDisabled: selection == nil, action: onNext)
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isCustomInputPresented) {
            APAYOCustomInputSheet(
                placeholder: languageStore.language.localized("custom.situation_placeholder"),
                text: $customInput
            ) {
                selection = customInput.trimmingCharacters(in: .whitespacesAndNewlines)
                isCustomInputPresented = false
            }
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(34)
        }
    }

    private var displayedOptions: [String] {
        guard let selection, !options.contains(selection) else { return options }
        return options + [selection]
    }

    private func display(_ value: String) -> String {
        options.contains(value) ? languageStore.language.localized(value) : value
    }
}

private struct InterviewOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(isSelected ? Color.apayoBackground : Color.apayoGray100)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isSelected ? Color.apayoGreen : .clear)
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct PainIntensityView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    @Binding var intensity: Int?
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            InterviewHeader(
                title: languageStore.language.localized("interview.intensity.title"),
                subtitle: languageStore.language.localized("interview.intensity.subtitle"),
                completedSteps: 1
            )
            .padding(.top, 10)

            HStack(spacing: 4) {
                ForEach(1...10, id: \.self) { value in
                    Button {
                        intensity = value
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(value <= (intensity ?? 0) ? Color.apayoBrightGreen : Color.apayoGray100)
                            .frame(height: 85)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        String(
                            format: languageStore.language.localized("accessibility.pain_value"),
                            value
                        )
                    )
                    .accessibilityAddTraits(value == intensity ? .isSelected : [])
                }
            }
            .padding(.top, 134)

            HStack {
                Text(languageStore.language.localized("pain.none"))
                Spacer()
                Text(languageStore.language.localized("pain.moderate"))
                Spacer()
                Text(languageStore.language.localized("pain.severe"))
            }
            .font(.subheadline)
            .foregroundStyle(Color.apayoGray600)
            .padding(.top, 10)

            Spacer()
            APAYOButton(title: LocalizedStringKey(languageStore.language.localized("common.next")), isDisabled: intensity == nil, action: onNext)
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct MultiChoiceInterviewView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let title: String
    let subtitle: String
    let options: [String]
    @Binding var selections: Set<String>
    var completedSteps: Int = 2
    var noneOptionLocalizationKey = "choice.none"
    let onNext: () -> Void

    @State private var isCustomInputPresented = false
    @State private var customInput = ""

    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        VStack(spacing: 0) {
            InterviewHeader(
                title: title,
                subtitle: subtitle,
                completedSteps: completedSteps
            )
            .padding(.top, 10)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(displayedOptions, id: \.self) { option in
                    Button {
                        toggle(option)
                    } label: {
                        VStack(spacing: 4) {
                            if option == "choice.none" {
                                Image(systemName: "x.circle.fill")
                            }
                            Text(display(option))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, minHeight: 98)
                        .background(selections.contains(option) ? Color.apayoBackground : Color.apayoGray100)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(selections.contains(option) ? Color.apayoGreen : .clear)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selections.contains(option) ? .isSelected : [])
                }

                Button {
                    customInput = ""
                    isCustomInputPresented = true
                } label: {
                    Label(languageStore.language.localized("common.custom"), systemImage: "plus")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(Color.apayoGreen)
                        .frame(maxWidth: .infinity, minHeight: 98)
                }
            }
            .padding(.top, 26)

            Spacer()
            APAYOButton(title: LocalizedStringKey(languageStore.language.localized("common.next")), isDisabled: selections.isEmpty, action: onNext)
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isCustomInputPresented) {
            APAYOCustomInputSheet(
                placeholder: languageStore.language.localized(
                    completedSteps == 3 ? "custom.medication_placeholder" : "custom.symptom_placeholder"
                ),
                text: $customInput
            ) {
                let value = customInput.trimmingCharacters(in: .whitespacesAndNewlines)
                if !value.isEmpty {
                    selections.remove("choice.none")
                    selections.insert(value)
                }
                isCustomInputPresented = false
            }
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(34)
        }
    }

    private var displayedOptions: [String] {
        let customOptions = selections
            .filter { !options.contains($0) }
            .sorted()
        return options + customOptions
    }

    private func toggle(_ option: String) {
        if option == "choice.none" {
            selections = selections == [option] ? [] : [option]
        } else {
            selections.remove("choice.none")
            if selections.contains(option) {
                selections.remove(option)
            } else {
                selections.insert(option)
            }
        }
    }

    private func display(_ value: String) -> String {
        guard options.contains(value) else { return value }
        let localizationKey = value == "choice.none" ? noneOptionLocalizationKey : value
        return languageStore.language.localized(localizationKey)
    }
}

struct InterviewProgressLine: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let completedSteps: Int
    private let totalSteps = 5

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...totalSteps, id: \.self) { step in
                progressNode(step)

                if step < totalSteps {
                    Rectangle()
                        .fill(step <= completedSteps ? Color.apayoGreen : Color.apayoGray300)
                        .frame(maxWidth: .infinity)
                        .frame(height: 4)
                }
            }
        }
        .frame(height: 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(languageStore.language.localized("accessibility.interview_progress"))
        .accessibilityValue(
            String(
                format: languageStore.language.localized("accessibility.interview_value"),
                completedSteps
            )
        )
    }

    @ViewBuilder
    private func progressNode(_ step: Int) -> some View {
        if step <= completedSteps {
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(Color.apayoBrightGreen, in: Circle())
                .overlay { Circle().stroke(Color.apayoGreen, lineWidth: 2) }
        } else {
            Text("\(step)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.apayoGray300)
                .frame(width: 19, height: 19)
                .background(.white, in: Circle())
                .overlay { Circle().stroke(Color.apayoGray300, lineWidth: 2) }
        }
    }
}

struct APAYOCustomInputSheet: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let placeholder: String
    @Binding var text: String
    var title: String?
    var actionTitle: String?
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(title ?? languageStore.language.localized("custom.title"))
                .font(.headline)
                .padding(.top, 22)

            TextField(placeholder, text: $text)
                .font(.body)
                .padding(.horizontal, 20)
                .frame(height: 50)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.top, 38)

            Spacer(minLength: 18)

            APAYOButton(
                title: LocalizedStringKey(actionTitle ?? languageStore.language.localized("custom.complete")),
                isDisabled: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                action: onComplete
            )
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 26)
        .background(Color.apayoGray100.opacity(0.94).ignoresSafeArea())
    }
}

#Preview("Duration") {
    @Previewable @State var path: [PatientFlowRoute] = []

    NavigationStack(path: $path) {
        SingleChoiceInterviewView(
            title: "언제부터 불편하셨나요?",
            subtitle: "통증이 시작된 대략적인 시점을 알려주세요.",
            step: (1, 2),
            options: PreviewMockData.durationOptions,
            selection: .constant(nil),
            onNext: { path.append(.frequencyInterview) }
        )
        .navigationDestination(for: PatientFlowRoute.self) { destination in
            switch destination {
            case .frequencyInterview:
                SingleChoiceInterviewView(
                    title: "통증이 얼마나 자주,\n어떻게 나타나나요?",
                    subtitle: "일상생활이나 활동 중 증상을 선택해 주세요.",
                    step: (2, 2),
                    options: PreviewMockData.frequencyOptions,
                    selection: .constant(nil),
                    onNext: { path.append(.intensityInterview) }
                )
            case .intensityInterview:
                PainIntensityView(intensity: .constant(nil)) {
                    path.append(.accompanyingSymptoms)
                }
            case .accompanyingSymptoms:
                MultiChoiceInterviewView(
                    title: "통증 외에 같이 나타나는\n증상이 있나요?",
                    subtitle: "현재 겪고 계신 모든 동반 증상을 체크해 주세요.",
                    options: PreviewMockData.accompanyingOptions,
                    selections: .constant([])
                ) { path.append(.medicationInterview) }
            case .medicationInterview:
                MultiChoiceInterviewView(
                    title: "증상이 나타난 후\n응급 복용한 약이 있나요?",
                    subtitle: "증상 발생 후 드신 약을 모두 선택해 주세요",
                    options: PreviewMockData.medicationOptions,
                    selections: .constant([])
                ) { path.append(.aiFollowUp) }
            case .aiFollowUp:
                AIFollowUpView(
                    viewModel: MedicalInterviewAIViewModel(),
                    context: PreviewMockData.medicalInterviewContext,
                    onNext: {}
                )
            default:
                EmptyView()
            }
        }
    }
}
