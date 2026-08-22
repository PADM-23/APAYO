import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";

import {
    AzureOpenAIConfigurationError,
    AzureOpenAIRequestError,
    generateFollowUpQuestionsWithAzureOpenAI,
    summarizeMedicalInterviewWithAzureOpenAI
} from "../ai/azureOpenAI";
import {
    FollowUpQuestionsRequest,
    MedicalInterviewSummaryRequest
} from "../contracts/medicalInterview";
import {
    followUpQuestionsRequestSchema,
    medicalInterviewSummaryRequestSchema
} from "../validation/medicalInterviewSchema";

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

function aiErrorResponse(error: unknown, context: InvocationContext): HttpResponseInit {
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
        context.error("Unexpected medical interview AI error");
    }

    return {
        status: 502,
        jsonBody: {
            error: {
                code: "ai_request_failed",
                message: "AI 처리를 완료하지 못했습니다. 잠시 후 다시 시도해 주세요."
            }
        }
    };
}

async function readJSON(request: HttpRequest): Promise<unknown | HttpResponseInit> {
    try {
        return await request.json();
    } catch {
        return invalidRequest([{ path: [], message: "Request body must be valid JSON" }]);
    }
}

export async function followUpQuestions(
    request: HttpRequest,
    context: InvocationContext
): Promise<HttpResponseInit> {
    const body = await readJSON(request);
    if (isHttpResponse(body)) {
        return body;
    }

    const validation = followUpQuestionsRequestSchema.safeParse(body);
    if (!validation.success) {
        return invalidRequest(validation.error.issues.map(issue => ({
            path: issue.path,
            message: issue.message
        })));
    }

    const validRequest: FollowUpQuestionsRequest = validation.data;
    context.log("Validated follow-up questions request", {
        schemaVersion: validRequest.schema_version,
        languageHint: validRequest.context.original_symptom.language_hint
    });

    try {
        return {
            status: 200,
            jsonBody: await generateFollowUpQuestionsWithAzureOpenAI(validRequest)
        };
    } catch (error) {
        return aiErrorResponse(error, context);
    }
}

export async function medicalInterviewSummary(
    request: HttpRequest,
    context: InvocationContext
): Promise<HttpResponseInit> {
    const body = await readJSON(request);
    if (isHttpResponse(body)) {
        return body;
    }

    const validation = medicalInterviewSummaryRequestSchema.safeParse(body);
    if (!validation.success) {
        return invalidRequest(validation.error.issues.map(issue => ({
            path: issue.path,
            message: issue.message
        })));
    }

    const validRequest: MedicalInterviewSummaryRequest = validation.data;
    context.log("Validated medical interview summary request", {
        schemaVersion: validRequest.schema_version,
        selectedFollowUpCount: validRequest.selected_follow_up_question_ids.length
    });

    try {
        return {
            status: 200,
            jsonBody: await summarizeMedicalInterviewWithAzureOpenAI(validRequest)
        };
    } catch (error) {
        return aiErrorResponse(error, context);
    }
}

function isHttpResponse(value: unknown): value is HttpResponseInit {
    return typeof value === "object" && value !== null && "status" in value;
}

app.http("followUpQuestions", {
    methods: ["POST"],
    authLevel: "anonymous",
    route: "v2/follow-up-questions",
    handler: followUpQuestions
});

app.http("medicalInterviewSummary", {
    methods: ["POST"],
    authLevel: "anonymous",
    route: "v2/medical-interview-summary",
    handler: medicalInterviewSummary
});
