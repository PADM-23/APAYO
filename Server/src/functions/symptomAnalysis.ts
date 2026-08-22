import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";

import {
    SymptomAnalysisRequest,
    SymptomAnalysisResponse
} from "../contracts/symptomAnalysis";
import { symptomAnalysisRequestSchema } from "../validation/symptomAnalysisSchema";

function invalidRequest(details: unknown): HttpResponseInit {
    return {
        status: 400,
        jsonBody: {
            error: {
                code: "invalid_request",
                message: "요청 형식이 올바르지 않습니다.",
                details
            }
        }
    };
}

export async function symptomAnalysis(
    request: HttpRequest,
    context: InvocationContext
): Promise<HttpResponseInit> {
    let body: unknown;

    try {
        body = await request.json();
    } catch {
        return invalidRequest([{ path: [], message: "Request body must be valid JSON" }]);
    }

    const validation = symptomAnalysisRequestSchema.safeParse(body);
    if (!validation.success) {
        return invalidRequest(
            validation.error.issues.map(issue => ({
                path: issue.path,
                message: issue.message
            }))
        );
    }

    const validRequest: SymptomAnalysisRequest = validation.data;
    context.log("Validated symptom analysis request", {
        schemaVersion: validRequest.schema_version,
        hasWorkContext: validRequest.work_context !== null,
        hasWeatherContext: validRequest.weather_context !== null
    });

    const response: SymptomAnalysisResponse = {
        schema_version: "1.0",
        detected_language: {
            code: validRequest.input.language_hint ?? "und",
            name: validRequest.input.language_hint ?? "Unknown"
        },
        symptoms: [
            {
                name_ko: "확인 필요",
                body_part_ko: null,
                onset_text_ko: null,
                severity: null
            }
        ],
        selected_card_id: "card_default",
        selected_question_ids: ["q_onset", "q_severity"],
        safety_flags: [],
        clarification_note_ko: "현재는 Azure OpenAI 연결 전 가짜 응답입니다."
    };

    return {
        status: 200,
        jsonBody: response
    };
}

app.http("symptomAnalysis", {
    methods: ["POST"],
    authLevel: "anonymous",
    route: "v1/symptom-analysis",
    handler: symptomAnalysis
});
