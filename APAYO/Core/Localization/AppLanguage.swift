import Combine
import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case filipino = "fil"
    case vietnamese = "vi"
    case chinese = "zh-Hans"
    case russian = "ru"
    case khmer = "km"
    case korean = "ko"

    var id: String { rawValue }
    var locale: Locale { Locale(identifier: rawValue) }

    var nativeName: String {
        switch self {
        case .english: "English"
        case .filipino: "Wikang Filipino"
        case .vietnamese: "Tiếng Việt"
        case .chinese: "简体中文"
        case .russian: "Русский"
        case .khmer: "ភាសាខ្មែរ"
        case .korean: "한국어"
        }
    }

    var englishName: String {
        switch self {
        case .english: "English"
        case .filipino: "Filipino"
        case .vietnamese: "Vietnamese"
        case .chinese: "Chinese"
        case .russian: "Russian"
        case .khmer: "Khmer"
        case .korean: "Korean"
        }
    }

    var imageName: String {
        switch self {
        case .english: "FlagEnglish"
        case .filipino: "FlagFilipino"
        case .vietnamese: "FlagVietnamese"
        case .chinese: "FlagChinese"
        case .russian: "FlagRussian"
        case .khmer: "FlagCambodian"
        case .korean: "FlagKorean"
        }
    }

    func localized(_ key: String) -> String {
        localizedBundle.localizedString(
            forKey: key,
            value: nil,
            table: "Localizable"
        )
    }

    private var localizedBundle: Bundle {
        guard
            let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .main
        }
        return bundle
    }

    static var onboardingLanguages: [AppLanguage] {
        [.english, .filipino, .vietnamese, .chinese, .russian, .khmer]
    }
}

enum LanguageFallbackReason: Equatable {
    case unsupportedLanguage(String)
}

@MainActor
final class AppLanguageStore: ObservableObject {
    @Published private(set) var language: AppLanguage
    @Published private(set) var fallbackReason: LanguageFallbackReason?

    private let defaults: UserDefaults
    private let storageKey = "app.language"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let code = defaults.string(forKey: storageKey) ?? AppLanguage.korean.rawValue
        if let language = AppLanguage(rawValue: code) {
            self.language = language
            fallbackReason = nil
        } else {
            language = .korean
            fallbackReason = .unsupportedLanguage(code)
        }
    }

    func select(_ language: AppLanguage) {
        self.language = language
        defaults.set(language.rawValue, forKey: storageKey)
        fallbackReason = nil
    }

    func clearFallbackReason() {
        fallbackReason = nil
    }
}
