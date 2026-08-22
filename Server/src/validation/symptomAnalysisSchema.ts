import { z } from "zod";

import {
    CARD_IDS,
    QUESTION_IDS,
    SAFETY_FLAGS
} from "../contracts/symptomAnalysis";

const exposureStatusSchema = z.enum(["yes", "no", "unknown"]);

const workContextSchema = z.object({
    worked_today: z.boolean(),
    work_type: z.string().trim().min(1).max(100).nullable(),
    pesticide_exposure: exposureStatusSchema,
    injury_or_fall: exposureStatusSchema
}).strict();

const weatherContextSchema = z.object({
    observed_at: z.string().datetime({ offset: true }),
    temperature_celsius: z.number().min(-60).max(60),
    humidity_percent: z.number().int().min(0).max(100),
    heat_warning: z.boolean()
}).strict();

const allowedCardIDsSchema = z.array(z.enum(CARD_IDS))
    .length(CARD_IDS.length)
    .refine(
        ids => new Set(ids).size === CARD_IDS.length && CARD_IDS.every(id => ids.includes(id)),
        { message: "allowed_card_ids must contain every supported card ID exactly once" }
    );

const allowedQuestionIDsSchema = z.array(z.enum(QUESTION_IDS))
    .length(QUESTION_IDS.length)
    .refine(
        ids => new Set(ids).size === QUESTION_IDS.length && QUESTION_IDS.every(id => ids.includes(id)),
        { message: "allowed_question_ids must contain every supported question ID exactly once" }
    );

export const symptomAnalysisRequestSchema = z.object({
    schema_version: z.literal("1.0"),
    input: z.object({
        text: z.string().trim().min(1).max(2_000),
        language_hint: z.string()
            .regex(/^[a-z]{2,3}(?:-[A-Z]{2})?$/)
            .nullable()
    }).strict(),
    work_context: workContextSchema.nullable(),
    weather_context: weatherContextSchema.nullable(),
    allowed_card_ids: allowedCardIDsSchema,
    allowed_question_ids: allowedQuestionIDsSchema
}).strict();

export const symptomAnalysisResponseSchema = z.object({
    schema_version: z.literal("1.0"),
    detected_language: z.object({
        code: z.string().trim().min(1).max(20),
        name: z.string().trim().min(1).max(100)
    }).strict(),
    symptoms: z.array(z.object({
        name_ko: z.string().trim().min(1).max(100),
        body_part_ko: z.string().trim().min(1).max(100).nullable(),
        onset_text_ko: z.string().trim().min(1).max(200).nullable(),
        severity: z.number().int().min(0).max(10).nullable()
    }).strict()).min(1).max(5),
    selected_card_id: z.enum(CARD_IDS),
    selected_question_ids: z.array(z.enum(QUESTION_IDS))
        .min(2)
        .max(4)
        .refine(ids => new Set(ids).size === ids.length, {
            message: "selected_question_ids must not contain duplicates"
        }),
    safety_flags: z.array(z.enum(SAFETY_FLAGS))
        .refine(flags => new Set(flags).size === flags.length, {
            message: "safety_flags must not contain duplicates"
        }),
    clarification_note_ko: z.string().trim().min(1).max(500).nullable()
}).strict();
