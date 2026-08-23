import Foundation

protocol MedicalInterviewServing {
    func generateFollowUpQuestions(
        request: FollowUpQuestionsRequest
    ) async throws -> FollowUpQuestionsResponse

    func generateMedicalSummary(
        request: MedicalInterviewSummaryRequest
    ) async throws -> MedicalInterviewSummaryResponse
}

struct MedicalInterviewService: MedicalInterviewServing {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func generateFollowUpQuestions(
        request: FollowUpQuestionsRequest
    ) async throws -> FollowUpQuestionsResponse {
        try await client.post(
            path: "v2/follow-up-questions",
            body: request
        )
    }

    func generateMedicalSummary(
        request: MedicalInterviewSummaryRequest
    ) async throws -> MedicalInterviewSummaryResponse {
        try await client.post(
            path: "v2/medical-interview-summary",
            body: request
        )
    }
}
