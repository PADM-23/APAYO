import Foundation

enum APIClientError: LocalizedError, Equatable {
    case invalidResponse
    case server(statusCode: Int, message: String?)
    case invalidResponseBody

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "서버의 응답을 확인할 수 없습니다."
        case .server(_, let message):
            return message ?? "요청에 실패했습니다. 잠시 후 다시 시도해 주세요."
        case .invalidResponseBody:
            return "서버 응답 형식이 올바르지 않습니다."
        }
    }
}

struct APIClient {
    private let configuration: APIConfiguration
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        configuration: APIConfiguration = .local,
        session: URLSession = .shared,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.configuration = configuration
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    func post<Request: Encodable, Response: Decodable>(
        path: String,
        body: Request,
        responseType: Response.Type = Response.self
    ) async throws -> Response {
        let endpoint = configuration.baseURL.appending(path: path)
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data)
            throw APIClientError.server(
                statusCode: httpResponse.statusCode,
                message: errorResponse?.error.message
            )
        }

        guard let result = try? decoder.decode(responseType, from: data) else {
            throw APIClientError.invalidResponseBody
        }

        return result
    }
}

private struct APIErrorResponse: Decodable {
    let error: APIErrorDetail
}

private struct APIErrorDetail: Decodable {
    let code: String
    let message: String
}
