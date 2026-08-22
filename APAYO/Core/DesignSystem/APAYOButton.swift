import SwiftUI

struct APAYOButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: LocalizedStringKey
    var systemImage: String?
    var style: Style = .primary
    var isLoading = false
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }

                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: APAYOTheme.controlHeight)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: APAYOTheme.cornerRadius, style: .continuous))
            .overlay {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: APAYOTheme.cornerRadius, style: .continuous)
                        .stroke(Color.apayoGreen, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .accessibilityValue(isLoading ? "로딩 중" : "")
    }

    private var foregroundColor: Color {
        style == .primary ? .white : .apayoGreen
    }

    private var backgroundColor: Color {
        style == .primary ? (isDisabled ? .apayoGray400 : .apayoGreen) : .clear
    }
}

#Preview("Buttons") {
    VStack {
        APAYOButton(title: "다음", systemImage: "arrow.right") {}
        APAYOButton(title: "이전", style: .secondary) {}
        APAYOButton(title: "다음", isDisabled: true) {}
    }
    .padding()
}
