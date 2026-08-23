import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";

import {
    analyzeSymptomsWithAzureOpenAI,
    AzureOpenAIConfigurationError,
    AzureOpenAIRequestError
} from "../ai/azureOpenAI";
import { SymptomAnalysisRequest } from "../contracts/symptomAnalysis";
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

    try {
        const response = await analyzeSymptomsWithAzureOpenAI(validRequest);

        return {
            status: 200,
            jsonBody: response
        };
    } catch (error) {
        if (error instanceof AzureOpenAIConfigurationError) {
            context.error("Azure OpenAI is not configured");
            return {
                status: 503,
                jsonBody: {
                    error: {
                        code: "ai_not_configured",
                        message: "AI 서비스가 아직 설정되지 않았습니다."
                    }
                }
            };
        }

        if (error instanceof AzureOpenAIRequestError) {
            context.error("Azure OpenAI request failed", { status: error.status });
        } else {
            context.error("Unexpected symptom analysis error");
        }

        return {
            status: 502,
            jsonBody: {
                error: {
                    code: "ai_request_failed",
                    message: "AI 분석을 완료하지 못했습니다. 잠시 후 다시 시도해 주세요."
                }
            }
        };
    }
}

app.http("symptomAnalysis", {
    methods: ["POST"],
    authLevel: "anonymous",
    route: "v1/symptom-analysis",
    handler: symptomAnalysis
});
