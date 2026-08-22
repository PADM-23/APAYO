import Foundation

protocol SymptomAnalyzing {
    func analyze(_ analysisRequest: SymptomAnalysisRequest) async throws -> SymptomAnalysisResponse
}

struct SymptomAnalysisService: SymptomAnalyzing {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func analyze(_ analysisRequest: SymptomAnalysisRequest) async throws -> SymptomAnalysisResponse {
        try await client.post(
            path: "v1/symptom-analysis",
            body: analysisRequest
        )
    }
}
