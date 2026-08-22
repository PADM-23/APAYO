import { z } from "zod";

import {
    SymptomAnalysisRequest,
    SymptomAnalysisResponse
} from "../contracts/symptomAnalysis";
import { symptomAnalysisResponseSchema } from "../validation/symptomAnalysisSchema";
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

export async function analyzeSymptomsWithAzureOpenAI(
    request: SymptomAnalysisRequest
): Promise<SymptomAnalysisResponse> {
    const endpoint = requiredEnvironmentVariable("AZURE_OPENAI_ENDPOINT");
    const apiKey = requiredEnvironmentVariable("AZURE_OPENAI_API_KEY");
    const deployment = requiredEnvironmentVariable("AZURE_OPENAI_DEPLOYMENT");

    const response = await fetch(responsesURL(endpoint), {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "api-key": apiKey
        },
        body: JSON.stringify({
            model: deployment,
            instructions: SYMPTOM_ANALYSIS_INSTRUCTIONS,
            input: buildSymptomAnalysisInput(request),
            temperature: 0.1,
            max_output_tokens: 800,
            store: false,
            text: {
                format: {
                    type: "json_schema",
                    name: "symptom_analysis",
                    strict: true,
                    schema: SYMPTOM_ANALYSIS_JSON_SCHEMA
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

    const validated = symptomAnalysisResponseSchema.safeParse(jsonOutput);
    if (!validated.success) {
        throw new AzureOpenAIRequestError("Azure OpenAI output failed server validation", 502);
    }

    return validated.data;
}
