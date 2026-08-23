import Foundation

struct APIConfiguration: Equatable {
    let baseURL: URL

    static let local = APIConfiguration(
        baseURL: URL(string: "http://127.0.0.1:7071/api")!
    )

    static let azureDevelopment = APIConfiguration(
        baseURL: URL(string: "https://apayo-api-dev-padm.azurewebsites.net/api")!
    )

    static var current: APIConfiguration {
        guard
            let override = ProcessInfo.processInfo.environment["APAYO_API_BASE_URL"],
            let overrideURL = URL(string: override),
            !override.isEmpty
        else {
            return .azureDevelopment
        }

        return APIConfiguration(baseURL: overrideURL)
    }
}
