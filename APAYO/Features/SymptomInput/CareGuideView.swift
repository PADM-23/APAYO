import SwiftUI

struct CareGuideView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    let onCreateSymptomCard: () -> Void
    let onFindFacility: () -> Void

    @State private var step: Step = .condition
    @State private var condition: Condition?
    @State private var situation: Situation?
    @State private var isReminderSet = false

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Color.apayoGray300
                    Color.apayoGreen.frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 4)
            .animation(.easeInOut(duration: 0.2), value: step)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(Color.apayoGray600)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 8)
                    content.padding(.top, 28)
                }
                .padding(.horizontal, APAYOTheme.horizontalPadding)
                .padding(.vertical, 30)
            }
        }
        .background(Color.apayoBackground.opacity(0.45).ignoresSafeArea())
        .navigationTitle(text("care_guide.navigation_title"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: handleBack) { Image(systemName: "chevron.left") }
            }
        }
    }

    @ViewBuilder private var content: some View {
        switch step {
        case .condition:
            optionList(Condition.allCases) {
                condition = $0
                step = [.uncomfortable, .mild].contains($0) ? .result : .situation
            }
        case .situation:
            optionList(Situation.allCases) {
                situation = $0
                step = $0 == .workInjury ? .workInjury : .result
            }
        case .workInjury:
            optionList(WorkInjury.allCases) { step = .resultForWorkInjury($0) }
        case .result, .resultForWorkInjury:
            resultContent
        }
    }

    private func optionList<Option: CareGuideOption>(
        _ options: [Option],
        onSelect: @escaping (Option) -> Void
    ) -> some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.key) { option in
                Button { onSelect(option) } label: {
                    HStack(spacing: 14) {
                        Image(systemName: option.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.apayoGreen)
                            .frame(width: 42, height: 42)
                            .background(Color.apayoBrightGreen.opacity(0.2), in: Circle())
                        Text(text(option.key))
                            .font(.headline)
                            .foregroundStyle(Color.apayoGray800)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.apayoGreen)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: 76)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: APAYOTheme.listCornerRadius, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder private var resultContent: some View {
        VStack(spacing: 16) {
            if result != .pharmacyOrObserve {
                VStack(alignment: .leading, spacing: 14) {
                    Label(text(result.titleKey), systemImage: result.icon)
                        .font(.title3.bold())
                        .foregroundStyle(result.color)
                    Text(text(result.descriptionKey))
                        .font(.body)
                        .foregroundStyle(Color.apayoGray800)
                        .fixedSize(horizontal: false, vertical: true)
                    if result == .sameDayCare { checklist }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: APAYOTheme.cornerRadius, style: .continuous))
            }

            switch result {
            case .immediateHelp:
                APAYOButton(title: LocalizedStringKey(text("care_guide.action.call_119")), systemImage: "phone.fill") {
                    if let url = URL(string: "tel://119") { openURL(url) }
                }
            case .sameDayCare:
                APAYOButton(title: LocalizedStringKey(text("care_guide.action.find_facility")), systemImage: "map.fill", action: onFindFacility)
                Button(action: onCreateSymptomCard) {
                    secondaryAction(text("care_guide.action.create_card"), icon: "square.and.pencil")
                }
                .buttonStyle(.plain)
            case .pharmacyOrObserve:
                Button(action: onFindFacility) {
                    secondaryAction(text("care_guide.action.find_pharmacy"), icon: "pills.fill")
                }
                .buttonStyle(.plain)
                Button(action: restart) {
                    secondaryAction(text("care_guide.action.rest_and_check"), icon: "bed.double.fill")
                }
                .buttonStyle(.plain)
                Button {
                    isReminderSet = true
                } label: {
                    secondaryAction(
                        text(isReminderSet ? "care_guide.action.reminder_set" : "care_guide.action.check_in_two_hours"),
                        icon: isReminderSet ? "checkmark.circle.fill" : "clock.fill"
                    )
                }
                .buttonStyle(.plain)
                .disabled(isReminderSet)
            }
        }
    }

    private var checklist: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(text("care_guide.prepare.heading")).font(.headline)
            ForEach(["care_guide.prepare.id", "care_guide.prepare.medicine", "care_guide.prepare.payment", "care_guide.prepare.card"], id: \.self) {
                Label(text($0), systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.apayoGray700)
            }
        }
        .padding(.top, 4)
    }

    private func secondaryAction(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundStyle(Color.apayoGreen)
            .frame(maxWidth: .infinity)
            .frame(height: APAYOTheme.controlHeight)
            .overlay {
                RoundedRectangle(cornerRadius: APAYOTheme.cornerRadius, style: .continuous)
                    .stroke(Color.apayoGreen, lineWidth: 1.5)
            }
    }

    private var title: String {
        switch step {
        case .condition: text("care_guide.condition.title")
        case .situation: text("care_guide.situation.title")
        case .workInjury: text("care_guide.work_injury.title")
        case .result, .resultForWorkInjury: text(result.headingKey)
        }
    }
    private var subtitle: String {
        switch step {
        case .condition: text("care_guide.condition.subtitle")
        case .situation: text("care_guide.situation.subtitle")
        case .workInjury: text("care_guide.work_injury.subtitle")
        case .result, .resultForWorkInjury:
            text(result == .pharmacyOrObserve ? "care_guide.result.observe.subtitle" : "care_guide.result.subtitle")
        }
    }
    private var result: CareResult {
        if case .resultForWorkInjury(let injury) = step, [.machine, .chemical].contains(injury) {
            return .immediateHelp
        }
        if (condition == .uncomfortable || condition == .mild), situation == nil {
            return .pharmacyOrObserve
        }
        return .sameDayCare
    }
    private var progress: CGFloat {
        switch step {
        case .condition: 0.25
        case .situation: 0.5
        case .workInjury: 0.75
        case .result, .resultForWorkInjury: 1
        }
    }
    private func goBack() {
        switch step {
        case .condition: break
        case .situation: step = .condition
        case .workInjury: step = .situation
        case .result: step = situation == nil ? .condition : .situation
        case .resultForWorkInjury: step = .workInjury
        }
    }
    private func handleBack() {
        if step == .condition {
            dismiss()
        } else {
            goBack()
        }
    }
    private func restart() {
        condition = nil
        situation = nil
        isReminderSet = false
        step = .condition
    }
    private func text(_ key: String) -> String { languageStore.language.localized(key) }
}

private protocol CareGuideOption {
    var key: String { get }
    var icon: String { get }
}

private extension CareGuideView {
    enum Step: Equatable {
        case condition, situation, workInjury, result
        case resultForWorkInjury(WorkInjury)
    }
    enum Condition: String, CaseIterable, CareGuideOption {
        case cannotWork, uncomfortable, mild, unsure
        var key: String { "care_guide.condition.\(rawValue)" }
        var icon: String {
            switch self {
            case .cannotWork: "figure.seated.side"
            case .uncomfortable: "figure.walk"
            case .mild: "bandage.fill"
            case .unsure: "questionmark"
            }
        }
    }
    enum Situation: String, CaseIterable, CareGuideOption {
        case sick, workInjury, weather, medicineReaction, unsure
        var key: String { "care_guide.situation.\(rawValue)" }
        var icon: String {
            switch self {
            case .sick: "cross.case.fill"
            case .workInjury: "hammer.fill"
            case .weather: "sun.max.fill"
            case .medicineReaction: "pills.fill"
            case .unsure: "questionmark"
            }
        }
    }
    enum WorkInjury: String, CaseIterable, CareGuideOption {
        case machine, fallOrCut, chemical, heat, insect, existingCondition
        var key: String { "care_guide.work_injury.\(rawValue)" }
        var icon: String {
            switch self {
            case .machine: "gearshape.2.fill"
            case .fallOrCut: "bandage.fill"
            case .chemical: "exclamationmark.triangle.fill"
            case .heat: "thermometer.sun.fill"
            case .insect: "ant.fill"
            case .existingCondition: "heart.text.square.fill"
            }
        }
    }
    enum CareResult: Equatable {
        case immediateHelp, sameDayCare, pharmacyOrObserve
        var headingKey: String { "care_guide.result.\(key).heading" }
        var titleKey: String { "care_guide.result.\(key).title" }
        var descriptionKey: String { "care_guide.result.\(key).description" }
        var icon: String {
            switch self {
            case .immediateHelp: "person.2.fill"
            case .sameDayCare: "cross.case.fill"
            case .pharmacyOrObserve: "pills.fill"
            }
        }
        var color: Color { self == .immediateHelp ? .orange : .apayoGreen }
        private var key: String {
            switch self {
            case .immediateHelp: "immediate"
            case .sameDayCare: "same_day"
            case .pharmacyOrObserve: "observe"
            }
        }
    }
}

#Preview {
    NavigationStack {
        CareGuideView(onCreateSymptomCard: {}, onFindFacility: {})
    }
    .environmentObject(AppLanguageStore())
}
