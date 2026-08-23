import Photos
import SwiftUI
import UIKit

struct MedicalSummaryView: View {
    @Environment(\.displayScale) private var displayScale
    @EnvironmentObject private var languageStore: AppLanguageStore
    @ObservedObject var viewModel: PatientFlowViewModel
    let aiViewModel: MedicalInterviewAIViewModel
    let onFindFacility: () -> Void
    let onBackToSymptomInput: () -> Void

    @State private var showsKorean = false
    @State private var saveAlertKey: String?

    var body: some View {
        ScrollView {
            summaryContent
        }
        .background(Color(.systemBackground))
        .navigationTitle(localized("summary.navigation"))
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Button {
                        Task { await saveSummaryImage() }
                    } label: {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 64, height: 64)
                            .background(Color.apayoGreen, in: RoundedRectangle(cornerRadius: 24))
                    }

                    APAYOButton(
                        title: LocalizedStringKey(localized("summary.find_facility")),
                        action: onFindFacility
                    )
                }

                APAYOButton(
                    title: LocalizedStringKey(localized("summary.back_to_symptom_input")),
                    systemImage: "arrow.counterclockwise",
                    style: .secondary,
                    action: onBackToSymptomInput
                )
            }
            .padding(.horizontal, 21)
            .padding(.top, 8)
            .background(.white)
            .overlay(alignment: .top) { Divider() }
        }
        .alert(localized(saveAlertKey ?? "summary.save_failed"), isPresented: saveAlertPresented) {
            Button(localized("common.confirm"), role: .cancel) {}
        }
    }

    private var summaryContent: some View {
        VStack(spacing: 0) {
            languagePicker
                .padding(.top, 24)

            Image(aiViewModel.selectedCardAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 226, height: 226)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.top, 26)

            Text(summaryTitle)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 16)

            Text(showsKorean ? localized("summary.doctor_korean") : selectedLanguageName)
                .font(.subheadline)
                .foregroundStyle(Color.apayoGreen)
                .padding(.top, 6)

            Text(summaryDescription)
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 66)
                .padding(.top, 28)
                .padding(.bottom, 32)

            Divider()

            VStack(alignment: .leading, spacing: 32) {
                summarySection(title: localized("summary.duration_frequency")) {
                    summaryRow(systemImage: "clock.fill", text: localizedAnswer(viewModel.duration))
                    summaryRow(systemImage: "chart.bar.fill", text: localizedAnswer(viewModel.frequency))
                }

                summarySection(title: localized("summary.intensity")) {
                    VStack(alignment: .leading, spacing: 14) {
                        intensityBar
                        Text(intensityDescription)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.apayoGreen)
                    }
                }

                summarySection(title: localized("summary.accompanying")) {
                    centeredValues(localizedAnswers(viewModel.accompanyingSymptoms))
                }

                summarySection(title: localized("summary.medication")) {
                    centeredValues(localizedAnswers(viewModel.medications))
                }

                summarySection(title: localized("summary.environment")) {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(viewModel.workEnvironment.selectedConditions.sorted(), id: \.self) { condition in
                            Text(localizedAnswer(condition))
                                .font(.callout)
                        }

                        if viewModel.workEnvironment.selectedConditions.isEmpty {
                            Text(localized("summary.no_environment"))
                                .font(.callout)
                        }
                    }
                }

                basicInformationSection
            }
            .padding(.horizontal, APAYOTheme.horizontalPadding)
            .padding(.top, 26)
            .padding(.bottom, 28)
        }
        .background(Color(.systemBackground))
    }

    private var saveAlertPresented: Binding<Bool> {
        Binding(
            get: { saveAlertKey != nil },
            set: { if !$0 { saveAlertKey = nil } }
        )
    }

    @MainActor
    private func saveSummaryImage() async {
        let authorization = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard authorization == .authorized || authorization == .limited else {
            saveAlertKey = "summary.save_permission_denied"
            return
        }

        let renderer = ImageRenderer(
            content: summaryContent
                .frame(width: 402)
                .environmentObject(languageStore)
        )
        renderer.scale = displayScale

        guard let image = renderer.uiImage else {
            saveAlertKey = "summary.save_failed"
            return
        }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            saveAlertKey = "summary.save_success"
        } catch {
            saveAlertKey = "summary.save_failed"
        }
    }

    private var languagePicker: some View {
        HStack(spacing: 8) {
            languageButton(
                title: selectedLanguageName,
                imageName: languageStore.language.imageName,
                isSelected: !showsKorean
            ) {
                showsKorean = false
            }
            languageButton(
                title: languageStore.language.localized("summary.korean_language"),
                imageName: "FlagKorean",
                isSelected: showsKorean
            ) {
                showsKorean = true
            }
        }
        .padding(4)
        .background(Color(red: 238 / 255, green: 237 / 255, blue: 236 / 255), in: Capsule())
    }

    private func languageButton(
        title: String,
        imageName: String?,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                } else {
                    Text("🇰🇷")
                        .frame(width: 28, height: 28)
                }

                Text(title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(Color.apayoGray700)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(isSelected ? Color.white : Color.clear, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func summarySection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(Color.apayoGray700)

            VStack(spacing: 15) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 19)
            .frame(maxWidth: .infinity)
            .background(Color.apayoBackground, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    private func summaryRow(systemImage: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(Color.apayoGreen)
                .frame(width: 32)
            Text(text)
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var intensityBar: some View {
        HStack(spacing: 4) {
            ForEach(1...10, id: \.self) { value in
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        value <= (viewModel.painIntensity ?? 0)
                        ? Color.apayoBrightGreen
                        : Color(red: 238 / 255, green: 237 / 255, blue: 236 / 255)
                    )
                    .frame(height: 59)
            }
        }
    }

    private func centeredValues(_ values: Set<String>) -> some View {
        VStack(spacing: 6) {
            ForEach(values.sorted(), id: \.self) { item in
                Text(item)
                    .font(.body.weight(.semibold))
                    .multilineTextAlignment(.center)
            }

            if values.isEmpty {
                Text(localized("common.no_selection"))
                    .font(.body.weight(.semibold))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var selectedLanguageName: String {
        languageStore.language.nativeName
    }

    private var summaryTitle: String {
        if showsKorean,
           case .success(let response) = aiViewModel.summaryState,
           let symptom = response.symptoms.first?.nameKo {
            return symptom
        }

        let symptom = viewModel.extractedSymptoms.first ?? viewModel.originalSymptom
        if symptom.isEmpty { return localized("summary.default_symptom") }
        return symptom.contains(".") ? localized(symptom) : symptom
    }

    private var summaryDescription: String {
        if showsKorean, case .success(let response) = aiViewModel.summaryState {
            return response.medicalSummaryKo
        }
        if case .success(let response) = aiViewModel.summaryState {
            return response.medicalSummaryUser
        }
        return localized("summary.description")
    }

    private var intensityDescription: String {
        guard let intensity = viewModel.painIntensity else {
            return localized("common.no_selection")
        }
        switch intensity {
        case 1...3: return localized("summary.mild")
        case 4...7: return localized("summary.moderate")
        default: return localized("summary.severe")
        }
    }

    private func value(_ value: String?) -> String {
        value ?? localized("common.no_selection")
    }

    private var basicInformationSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(localized("summary.basic"))
                .font(.callout.weight(.semibold))
                .foregroundStyle(Color.apayoGray700)

            VStack(spacing: 0) {
                basicInformationRow(
                    title: localized("summary.medication"),
                    value: localizedAnswers(viewModel.medications).joined(separator: ", ")
                )
                basicInformationRow(
                    title: localized("summary.conditions"),
                    value: localizedAnswers(viewModel.chronicConditions).joined(separator: ", ")
                )
                basicInformationRow(
                    title: localized("summary.allergies"),
                    value: localizedAnswers(viewModel.allergies).joined(separator: ", ")
                )
                basicInformationRow(
                    title: localized("summary.family_history"),
                    value: localizedAnswers(viewModel.familyHistory).joined(separator: ", ")
                )
                basicInformationRow(
                    title: localized("summary.substance"),
                    value: localizedAnswer(viewModel.substanceUse)
                )
            }
            .padding(.horizontal, 19)
            .background(Color.apayoBackground, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    private func basicInformationRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.body.weight(.semibold))
            Spacer(minLength: 12)
            Text(value.isEmpty ? localized("common.none") : value)
                .font(.callout)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private func localized(_ key: String) -> String {
        (showsKorean ? AppLanguage.korean : languageStore.language).localized(key)
    }

    private func localizedAnswers(_ values: Set<String>) -> Set<String> {
        Set(values.map(localizedAnswer))
    }

    private func localizedAnswer(_ value: String?) -> String {
        guard let value else { return localized("common.no_selection") }
        if value.contains(".") {
            return (showsKorean ? AppLanguage.korean : languageStore.language).localized(value)
        }
        return value
    }

}

#Preview {
    NavigationStack {
        MedicalSummaryView(
            viewModel: PatientFlowViewModel(),
            aiViewModel: MedicalInterviewAIViewModel(),
            onFindFacility: {},
            onBackToSymptomInput: {}
        )
            .environmentObject(AppLanguageStore())
    }
}
