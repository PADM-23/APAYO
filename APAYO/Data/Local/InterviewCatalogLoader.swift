import Foundation

protocol SymptomCardCatalogLoading {
    func loadSymptomCards() throws -> SymptomCardCatalog
}

enum InterviewCatalogLoadingError: LocalizedError, Equatable {
    case resourceNotFound(name: String)
    case resourceUnreadable(name: String)
    case decodingFailed(name: String, reason: String)

    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let name):
            return "앱 번들에서 \(name).json을 찾을 수 없습니다."
        case .resourceUnreadable(let name):
            return "\(name).json 파일을 읽을 수 없습니다."
        case .decodingFailed(let name, let reason):
            return "\(name).json의 형식이 올바르지 않습니다: \(reason)"
        }
    }
}

struct InterviewCatalogLoader: SymptomCardCatalogLoading {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func loadSymptomCards() throws -> SymptomCardCatalog {
        try load(SymptomCardCatalog.self, resourceName: "symptom_cards")
    }

    func loadFollowUpQuestions() throws -> FollowUpQuestionCatalog {
        try load(FollowUpQuestionCatalog.self, resourceName: "follow_up_questions")
    }

    private func load<Value: Decodable>(
        _ type: Value.Type,
        resourceName: String
    ) throws -> Value {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw InterviewCatalogLoadingError.resourceNotFound(name: resourceName)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw InterviewCatalogLoadingError.resourceUnreadable(name: resourceName)
        }

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw InterviewCatalogLoadingError.decodingFailed(
                name: resourceName,
                reason: error.localizedDescription
            )
        }
    }
}
