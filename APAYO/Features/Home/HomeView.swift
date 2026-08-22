import SwiftUI

struct HomeView: View {
    var onStart: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "cross.case.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.apayoGreen)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("아파요")
                    .font(.largeTitle.bold())

                Text("편한 언어로 증상을 알려주세요.\n진료에 필요한 내용을 함께 정리해 드릴게요.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            APAYOButton(title: "문진 시작하기", systemImage: "arrow.right", action: onStart)
        }
        .padding(APAYOTheme.horizontalPadding)
        .background(Color.apayoBackground.ignoresSafeArea())
    }
}

#Preview {
    HomeView()
}
