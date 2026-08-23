import SwiftUI

struct MedicalHistoryOnboardingView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let title: String
    let subtitle: String
    let completedSteps: Int
    let options: [String]
    let cardHeight: CGFloat
    let noSelectionOption: String?
    @Binding var selections: Set<String>
    let onNext: () -> Void

    @State private var showsCustomInput = false
    @State private var customInput = ""

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressLine(completedSteps: completedSteps)
                .padding(.top, 10)

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.title2.bold())
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(Color.apayoGray800)
            }
            .padding(.top, 55)

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(displayedOptions, id: \.self) { option in
                        optionButton(option)
                    }

                    Button {
                        showsCustomInput = true
                    } label: {
                        Label(text("common.custom"), systemImage: "plus")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(Color.apayoGreen)
                            .frame(maxWidth: .infinity, minHeight: cardHeight)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 12)
            }
            .padding(.top, 26)

            APAYOButton(title: LocalizedStringKey(text("common.next")), isDisabled: selections.isEmpty, action: onNext)
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .padding(.bottom, 1)
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showsCustomInput, onDismiss: {
            customInput = ""
        }) {
            APAYOCustomInputSheet(
                placeholder: text("common.custom"),
                text: $customInput
            ) {
                addCustomInput()
                showsCustomInput = false
            }
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(34)
        }
    }

    private var displayedOptions: [String] {
        let customOptions = selections
            .filter { !options.contains($0) }
            .sorted()
        return options + customOptions
    }

    private func optionButton(_ option: String) -> some View {
        Button {
            toggle(option)
        } label: {
            Group {
                if option == noSelectionOption {
                    Label(text(option), systemImage: "x.circle.fill")
                } else {
                    Text(text(option))
                }
            }
            .font(.body.weight(.semibold))
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, minHeight: cardHeight)
            .padding(.vertical, 8)
            .background(selections.contains(option) ? Color.apayoBackground : Color.apayoGray100)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selections.contains(option) ? Color.apayoGreen : Color.clear)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selections.contains(option) ? .isSelected : [])
    }

    private func toggle(_ option: String) {
        if option == noSelectionOption {
            selections = selections == [option] ? [] : [option]
            return
        }

        if let noSelectionOption {
            selections.remove(noSelectionOption)
        }

        if selections.contains(option) {
            selections.remove(option)
        } else {
            selections.insert(option)
        }
    }

    private func addCustomInput() {
        let value = customInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        if let noSelectionOption {
            selections.remove(noSelectionOption)
        }
        selections.insert(value)
        customInput = ""
    }

    private func text(_ key: String) -> String {
        options.contains(key) || key.hasPrefix("common.")
            ? languageStore.language.localized(key)
            : key
    }
}

struct SingleChoiceOnboardingView: View {
    @EnvironmentObject private var languageStore: AppLanguageStore
    let title: String
    let subtitle: String
    let completedSteps: Int
    let options: [String]
    @Binding var selection: String?
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressLine(completedSteps: completedSteps)
                .padding(.top, 10)

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.title2.bold())
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(Color.apayoGray800)
            }
            .padding(.top, 55)

            VStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        Text(languageStore.language.localized(option))
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .padding(.vertical, 8)
                            .background(selection == option ? Color.apayoBackground : Color.apayoGray100)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selection == option ? Color.apayoGreen : Color.clear)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selection == option ? .isSelected : [])
                }
            }
            .padding(.top, 26)

            Spacer()

            APAYOButton(
                title: LocalizedStringKey(languageStore.language.localized("common.next")),
                isDisabled: selection == nil,
                action: onNext
            )
        }
        .padding(.horizontal, APAYOTheme.horizontalPadding)
        .padding(.bottom, 1)
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
