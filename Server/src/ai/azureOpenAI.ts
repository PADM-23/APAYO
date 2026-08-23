import { z } from "zod";

import {
    SymptomAnalysisRequest,
    SymptomAnalysisResponse
} from "../contracts/symptomAnalysis";
import {
    FollowUpQuestionsRequest,
    FollowUpQuestionsResponse,
    MedicalInterviewSummaryRequest,
    MedicalInterviewSummaryResponse
} from "../contracts/medicalInterview";
import {
    followUpQuestionsResponseSchema,
    medicalInterviewSummaryResponseSchema
} from "../validation/medicalInterviewSchema";
import { symptomAnalysisResponseSchema } from "../validation/symptomAnalysisSchema";
import {
    buildFollowUpQuestionsInput,
    FOLLOW_UP_QUESTIONS_INSTRUCTIONS,
    FOLLOW_UP_QUESTIONS_JSON_SCHEMA
} from "./followUpQuestionsPrompt";
import {
    buildMedicalInterviewSummaryInput,
    MEDICAL_INTERVIEW_SUMMARY_INSTRUCTIONS,
    MEDICAL_INTERVIEW_SUMMARY_JSON_SCHEMA
} from "./medicalInterviewSummaryPrompt";
import {
    buildSymptomAnalysisInput,
    SYMPTOM_ANALYSIS_INSTRUCTIONS,
    SYMPTOM_ANALYSIS_JSON_SCHEMA
} from "./symptomAnalysisPrompt";

const azureResponseSchema = z.object({
    status: z.string(),
    output: z.array(z.object({
        type: z.string(),
        content: z.array(z.object({
            type: z.string(),
            text: z.string().optional()
        }).passthrough()).optional()
    }).passthrough())
}).passthrough();

export class AzureOpenAIConfigurationError extends Error {}

export class AzureOpenAIRequestError extends Error {
    constructor(
        message: string,
        readonly status: number
    ) {
        super(message);
    }
}

function requiredEnvironmentVariable(name: string): string {
    const value = process.env[name]?.trim();
    if (!value) {
        throw new AzureOpenAIConfigurationError(`Missing environment variable: ${name}`);
    }
    return value;
}

function responsesURL(endpoint: string): string {
    return `${endpoint.replace(/\/+$/, "")}/openai/v1/responses`;
}

function extractOutputText(payload: unknown): string {
    const parsed = azureResponseSchema.parse(payload);
    const outputText = parsed.output
        .flatMap(item => item.content ?? [])
        .find(content => content.type === "output_text" && content.text)?.text;

    if (parsed.status !== "completed" || !outputText) {
        throw new AzureOpenAIRequestError("Azure OpenAI returned no completed text output", 502);
    }

    return outputText;
}

async function requestStructuredOutput<Output>(options: {
    instructions: string;
    input: string;
    schemaName: string;
    schema: object;
    validator: z.ZodType<Output>;
    maxOutputTokens: number;
    maxValidationAttempts?: number;
}): Promise<Output> {
    const endpoint = requiredEnvironmentVariable("AZURE_OPENAI_ENDPOINT");
    const apiKey = requiredEnvironmentVariable("AZURE_OPENAI_API_KEY");
    const deployment = requiredEnvironmentVariable("AZURE_OPENAI_DEPLOYMENT");

    const maxValidationAttempts = options.maxValidationAttempts ?? 1;
    let currentInput = options.input;

    for (let attempt = 1; attempt <= maxValidationAttempts; attempt += 1) {
        const response = await fetch(responsesURL(endpoint), {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "api-key": apiKey
            },
            body: JSON.stringify({
                model: deployment,
                instructions: options.instructions,
                input: currentInput,
                temperature: 0.1,
                max_output_tokens: options.maxOutputTokens,
                store: false,
                text: {
                    format: {
                        type: "json_schema",
                        name: options.schemaName,
                        strict: true,
                        schema: options.schema
                    }
                }
            })
        });

        const payload: unknown = await response.json().catch(() => null);
        if (!response.ok) {
            throw new AzureOpenAIRequestError(
                `Azure OpenAI request failed with status ${response.status}`,
                response.status
            );
        }

        let jsonOutput: unknown;
        try {
            jsonOutput = JSON.parse(extractOutputText(payload));
        } catch (error) {
            if (error instanceof AzureOpenAIRequestError) {
                throw error;
            }
            throw new AzureOpenAIRequestError("Azure OpenAI returned invalid JSON output", 502);
        }

        const validated = options.validator.safeParse(jsonOutput);
        if (validated.success) {
            return validated.data;
        }

        const validationIssues = validated.error.issues.map(issue => ({
            path: issue.path,
            message: issue.message
        }));
        console.warn("Structured output semantic validation failed", {
            schemaName: options.schemaName,
            attempt,
            validationIssues
        });

        if (attempt < maxValidationAttempts) {
            currentInput = JSON.stringify({
                task: "Correct the previous output so it passes every semantic validation rule.",
                original_input: JSON.parse(options.input),
                previous_invalid_output: jsonOutput,
                validation_issues: validationIssues
            });
            continue;
        }
    }

    throw new AzureOpenAIRequestError("Azure OpenAI output failed server validation", 502);
}

export async function analyzeSymptomsWithAzureOpenAI(
    request: SymptomAnalysisRequest
): Promise<SymptomAnalysisResponse> {
    return requestStructuredOutput({
        instructions: SYMPTOM_ANALYSIS_INSTRUCTIONS,
        input: buildSymptomAnalysisInput(request),
        schemaName: "symptom_analysis",
        schema: SYMPTOM_ANALYSIS_JSON_SCHEMA,
        validator: symptomAnalysisResponseSchema,
        maxOutputTokens: 800
    });
}

export async function generateFollowUpQuestionsWithAzureOpenAI(
    request: FollowUpQuestionsRequest
): Promise<FollowUpQuestionsResponse> {
    return requestStructuredOutput({
        instructions: FOLLOW_UP_QUESTIONS_INSTRUCTIONS,
        input: buildFollowUpQuestionsInput(request),
        schemaName: "follow_up_questions",
        schema: FOLLOW_UP_QUESTIONS_JSON_SCHEMA,
        validator: followUpQuestionsResponseSchema,
        maxOutputTokens: 1_200
    });
}

export async function summarizeMedicalInterviewWithAzureOpenAI(
    request: MedicalInterviewSummaryRequest
): Promise<MedicalInterviewSummaryResponse> {
    return requestStructuredOutput({
        instructions: MEDICAL_INTERVIEW_SUMMARY_INSTRUCTIONS,
        input: buildMedicalInterviewSummaryInput(request),
        schemaName: "medical_interview_summary",
        schema: MEDICAL_INTERVIEW_SUMMARY_JSON_SCHEMA,
        validator: medicalInterviewSummaryResponseSchema,
        maxOutputTokens: 1_200,
        maxValidationAttempts: 2
    });
}
