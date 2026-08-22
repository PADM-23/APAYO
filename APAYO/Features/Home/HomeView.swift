import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cross.case.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("아파요")
                .font(.title.bold())

            Text("편한 언어로 증상을 알려주세요.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    HomeView()
}

