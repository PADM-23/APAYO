import SwiftUI

private struct InterviewHeader: View {
    let title: String
    let subtitle: String
    var step: (current: Int, total: Int)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let step {
                APAYOProgressBar(currentStep: step.current, totalSteps: step.total)
                    .padding(.bottom, 20)
            }

            Text(title)
                .font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(Color.apayoGray800)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SingleChoiceInterviewView: View {
    let title: String
    let subtitle: String
    let step: (current: Int, total: Int)?
    let options: [String]
    let onNext: () -> Void

    @State private var selection: String?

    var body: some View {
        VStack(spacing: 0) {
            InterviewHeader(title: title, subtitle: subtitle, step: step)
                .padding(.top, 42)

            VStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    InterviewOptionButton(title: option, isSelected: selection == option) {
                        selection = option
                    }
                }

                Button {
                    // Figma에는 직접 입력의 다음 화면이 아직 없습니다.
                } label: {
                    Label("직접입력", systemImage: "plus")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(Color.apayoGreen)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
            }
            .padding(.top, 26)

            Spacer()
            APAYOButton(title: "다음", isDisabled: selection == nil, action: onNext)
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
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
    let onNext: () -> Void
    @State private var intensity = 2

    var body: some View {
        VStack(spacing: 0) {
            InterviewHeader(
                title: "가장 심했을 때 통증은\n어느 정도였나요?",
                subtitle: "0점부터 10점까지 점수를 매겨주세요."
            )
            .padding(.top, 88)

            HStack(spacing: 4) {
                ForEach(1...10, id: \.self) { value in
                    Button {
                        intensity = value
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(value <= intensity ? Color.apayoBrightGreen : Color.apayoGray100)
                            .frame(height: 85)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("통증 강도 \(value)점")
                    .accessibilityAddTraits(value == intensity ? .isSelected : [])
                }
            }
            .padding(.top, 134)

            HStack {
                Text("통증 없음")
                Spacer()
                Text("보통 통증")
                Spacer()
                Text("극심한 통증")
            }
            .font(.subheadline)
            .foregroundStyle(Color.apayoGray600)
            .padding(.top, 10)

            Spacer()
            APAYOButton(title: "다음", action: onNext)
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct MultiChoiceInterviewView: View {
    let title: String
    let subtitle: String
    let options: [String]
    let onNext: () -> Void

    @State private var selections: Set<String> = []

    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        VStack(spacing: 0) {
            InterviewHeader(title: title, subtitle: subtitle)
                .padding(.top, 88)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button {
                        toggle(option)
                    } label: {
                        VStack(spacing: 4) {
                            if option == "증상 없음" {
                                Image(systemName: "x.circle.fill")
                            }
                            Text(option)
                                .multilineTextAlignment(.center)
                        }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.primary)
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
                    // Figma에는 직접 입력의 다음 화면이 아직 없습니다.
                } label: {
                    Label("직접입력", systemImage: "plus")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(Color.apayoGreen)
                        .frame(maxWidth: .infinity, minHeight: 98)
                }
            }
            .padding(.top, 26)

            Spacer()
            APAYOButton(title: "다음", isDisabled: selections.isEmpty, action: onNext)
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func toggle(_ option: String) {
        if option == "증상 없음" {
            selections = selections == [option] ? [] : [option]
        } else {
            selections.remove("증상 없음")
            if selections.contains(option) {
                selections.remove(option)
            } else {
                selections.insert(option)
            }
        }
    }
}

struct WorkEnvironmentInterviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            InterviewHeader(
                title: "오늘 어떤 환경에서 일하셨나요?",
                subtitle: "일하셨던 환경과 노출 상황을 모두 체크해 주세요"
            )
            .padding(.top, 88)

            Text("기상 및 온열환경")
                .font(.body.weight(.semibold))
                .padding(.top, 56)

            Text("오늘 야외 또는 비닐하우스 내 작업 시간이 4시간 이상인가요?")
                .font(.body.weight(.semibold))
                .padding(.top, 16)

            Spacer()
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
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
                    onNext: { path.append(.intensityInterview) }
                )
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
                ) { path.append(.workContextInterview) }
            case .workContextInterview:
                WorkEnvironmentInterviewView()
            default:
                EmptyView()
            }
        }
    }
}
