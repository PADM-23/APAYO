import Foundation

struct APIConfiguration: Equatable {
    let baseURL: URL

    static let local = APIConfiguration(
        baseURL: URL(string: "http://127.0.0.1:7071/api")!
    )
}
