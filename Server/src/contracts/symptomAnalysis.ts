export const CARD_IDS = [
    "card_default",
    "card_chest_tightness",
    "card_chills",
    "card_cough",
    "card_dizziness",
    "card_headache",
    "card_hives",
    "card_stomachache",
    "card_toothache",
    "card_vomiting"
] as const;

export const QUESTION_IDS = [
    "q_onset",
    "q_severity",
    "q_getting_worse",
    "q_fever",
    "q_breathing_difficulty",
    "q_loss_of_consciousness",
    "q_heat_exposure",
    "q_water_intake",
    "q_pesticide_exposure",
    "q_injury_or_fall",
    "q_insect_bite",
    "q_other_medication"
] as const;

export const SAFETY_FLAGS = [
    "breathing_difficulty",
    "loss_of_consciousness",
    "severe_chest_symptom",
    "stroke_like_symptom",
    "severe_bleeding",
    "possible_severe_allergic_reaction"
] as const;

export type CardID = typeof CARD_IDS[number];
export type QuestionID = typeof QUESTION_IDS[number];
export type SafetyFlag = typeof SAFETY_FLAGS[number];
export type ExposureStatus = "yes" | "no" | "unknown";

export interface SymptomAnalysisRequest {
    schema_version: "1.0";
    input: {
        text: string;
        language_hint: string | null;
    };
    work_context: {
        worked_today: boolean;
        work_type: string | null;
        pesticide_exposure: ExposureStatus;
        injury_or_fall: ExposureStatus;
    } | null;
    weather_context: {
        observed_at: string;
        temperature_celsius: number;
        humidity_percent: number;
        heat_warning: boolean;
    } | null;
    allowed_card_ids: CardID[];
    allowed_question_ids: QuestionID[];
}

export interface SymptomAnalysisResponse {
    schema_version: "1.0";
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
    selected_question_ids: QuestionID[];
    safety_flags: SafetyFlag[];
    clarification_note_ko: string | null;
}
