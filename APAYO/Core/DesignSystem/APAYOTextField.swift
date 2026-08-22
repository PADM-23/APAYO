import SwiftUI

struct APAYOTextField: View {
    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey
    @Binding var text: String
    var axis: Axis = .horizontal
    var errorMessage: LocalizedStringKey?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))

            TextField(placeholder, text: $text, axis: axis)
                .lineLimit(axis == .vertical ? 3...6 : 1...1)
                .padding(16)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(errorMessage == nil ? Color.clear : Color.red, lineWidth: 1)
                }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    @Previewable @State var symptom = ""
    APAYOTextField(title: "증상", placeholder: "어디가 어떻게 아픈가요?", text: $symptom, axis: .vertical)
        .padding()
}
