import SwiftUI

@main
struct APAYOApp: App {
    @StateObject private var languageStore = AppLanguageStore()

    var body: some Scene {
        WindowGroup {
            PatientFlowView()
                .environmentObject(languageStore)
                .environment(\.locale, languageStore.language.locale)
        }
    }
}
