import { CARD_IDS, CardID, SafetyFlag } from "./symptomAnalysis";

export { CARD_IDS };

export const FOLLOW_UP_QUESTION_IDS = ["fq_1", "fq_2", "fq_3", "fq_4"] as const;
export const FOLLOW_UP_CATEGORIES = [
    "symptom_change",
    "associated_symptom",
    "safety",
    "work_environment",
    "exposure",
    "medical_context"
] as const;

export type FollowUpQuestionID = typeof FOLLOW_UP_QUESTION_IDS[number];
export type FollowUpCategory = typeof FOLLOW_UP_CATEGORIES[number];

export interface MedicalInterviewContext {
    original_symptom: {
        text: string;
        language_hint: string | null;
    };
    medical_history: {
        chronic_conditions: string[];
        allergies: string[];
        family_history: string[];
        substance_use: string | null;
        surgery_history: string | null;
    };
    base_interview: {
        duration: string | null;
        frequency: string | null;
        pain_intensity: number | null;
        accompanying_symptoms: string[];
        medications: string[];
        work_environment: string[];
    };
    weather_context: {
        observed_at: string;
        temperature_celsius: number;
        humidity_percent: number;
        heat_warning: boolean;
    } | null;
}

export interface GeneratedFollowUpQuestion {
    id: FollowUpQuestionID;
    prompt_user: string;
    prompt_ko: string;
    category: FollowUpCategory;
    answer_type: "checkbox_yes";
}

export interface GeneratedQuestionGroup {
    title_user: string;
    title_ko: string;
    questions: GeneratedFollowUpQuestion[];
}

export interface FollowUpQuestionsRequest {
    schema_version: "2.0";
    context: MedicalInterviewContext;
}

export interface FollowUpQuestionsResponse {
    schema_version: "2.0";
    detected_language: {
        code: string;
        name: string;
    };
    question_groups: GeneratedQuestionGroup[];
    safety_flags: SafetyFlag[];
}

export interface MedicalInterviewSummaryRequest {
    schema_version: "2.0";
    context: MedicalInterviewContext;
    question_groups: GeneratedQuestionGroup[];
    selected_follow_up_question_ids: FollowUpQuestionID[];
    allowed_card_ids: CardID[];
}

export interface MedicalInterviewSummaryResponse {
    schema_version: "2.0";
    detected_language: {
        code: string;
        name: string;
    };
    symptoms: Array<{
        name_ko: string;
        body_part_ko: string | null;
        onset_text_ko: string | null;
        severity: number | null;
    }>;
    selected_card_id: CardID;
    medical_summary_user: string;
    medical_summary_ko: string;
    safety_flags: SafetyFlag[];
}
