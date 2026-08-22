import SwiftUI

struct QuestionOption: Identifiable, Hashable {
    let id: String
    let title: String
    var systemImage: String?
}

struct QuestionCard: View {
    let title: String
    var subtitle: String?
    let options: [QuestionOption]
    @Binding var selection: QuestionOption?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2.bold())

            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(.secondary)
            }

            Spacer().frame(height: 14)

            ForEach(options) { option in
                Button {
                    selection = option
                } label: {
                    HStack(spacing: 16) {
                        if let systemImage = option.systemImage {
                            Image(systemName: systemImage)
                            .frame(width: 28, height: 28)
                        }
                        Text(option.title)
                            .font(.body.weight(.medium))
                        Spacer()
                        Image(systemName: selection == option ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selection == option ? Color.apayoGreen : Color.secondary)
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(selection == option ? Color.apayoBackground : Color.apayoGray100)
                    .clipShape(RoundedRectangle(cornerRadius: APAYOTheme.listCornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: APAYOTheme.listCornerRadius)
                            .stroke(selection == option ? Color.apayoGreen : Color.clear, lineWidth: 1.5)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == option ? .isSelected : [])
            }
        }
    }
}
