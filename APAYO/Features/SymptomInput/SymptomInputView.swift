import SwiftUI

struct SymptomInputView: View {
    @State private var symptom = ""
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 72)

            Menu {
                Button("Tiếng Việt") {}
                Button("한국어") {}
            } label: {
                HStack(spacing: 10) {
                    Image("FlagVietnamese")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                    Text("Tiếng Việt")
                        .font(.callout.weight(.semibold))
                    Image(systemName: "chevron.down")
                }
                .foregroundStyle(Color.apayoGray700)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.systemBackground), in: Capsule())
                .overlay { Capsule().stroke(Color.apayoGray300, lineWidth: 2) }
            }

            Text("어디가 불편해서\n찾아오셨나요?")
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 54)

            Spacer().frame(height: 58)

            HStack(spacing: 8) {
                ForEach(["배아파", "머리아파", "어지러워", "기침해"], id: \.self) { item in
                    Text(item)
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.7), in: Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()

            HStack(spacing: 8) {
                TextField("증상을 입력해주세요", text: $symptom)
                    .font(.body)
                    .padding(.horizontal, 20)
                    .frame(height: 50)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))

                Button(action: onNext) {
                    Image(systemName: "arrow.right")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.apayoGreen, in: Circle())
                }
                .disabled(symptom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, APAYOTheme.horizontalPadding)
            .padding(.top, 18)

            Spacer()
        }
        .background {
            RadialGradient(
                colors: [.apayoBrightGreen.opacity(0.65), .apayoYellow.opacity(0.45), .clear],
                center: .center,
                startRadius: 20,
                endRadius: 280
            )
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        SymptomInputView(onNext: {})
    }
}
