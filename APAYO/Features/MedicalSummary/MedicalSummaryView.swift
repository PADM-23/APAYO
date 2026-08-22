import SwiftUI

struct MedicalSummaryView: View {
    let onFindFacility: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Label("문진이 완료되었어요", systemImage: "checkmark.seal.fill")
                    .font(.title.bold())
                    .foregroundStyle(Color.apayoGreen)

                summarySection(title: "주요 증상", content: PreviewMockData.symptom)
                summarySection(title: "통증 정도", content: "많이 아파요")
                summarySection(title: "작업 환경", content: "더운 야외에서 일했어요")

                APAYOButton(title: "주변 병원 찾기", systemImage: "mappin.and.ellipse", action: onFindFacility)
            }
            .padding(APAYOTheme.horizontalPadding)
        }
        .navigationTitle("문진 요약")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func summarySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(content)
                .font(.body.weight(.medium))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
