import SwiftUI

struct APAYOStateView: View {
    enum Kind {
        case loading
        case error
        case empty

        var icon: String {
            switch self {
            case .loading: "cross.case.fill"
            case .error: "exclamationmark.triangle.fill"
            case .empty: "doc.text.magnifyingglass"
            }
        }
    }

    let kind: Kind
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    var actionTitle: LocalizedStringKey?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            if kind == .loading {
                ProgressView()
                    .controlSize(.large)
                    .tint(.apayoGreen)
            } else {
                Image(systemName: kind.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(kind == .error ? .red : .apayoGreen)
            }

            Text(title)
                .font(.title3.bold())

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if let actionTitle, let action {
                APAYOButton(title: actionTitle, style: .secondary, action: action)
                    .frame(maxWidth: 240)
            }
        }
        .padding(APAYOTheme.horizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
