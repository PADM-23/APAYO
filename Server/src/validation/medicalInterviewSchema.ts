import { z } from "zod";

import {
    CARD_IDS,
    FOLLOW_UP_CATEGORIES,
    FOLLOW_UP_QUESTION_IDS
} from "../contracts/medicalInterview";
import { SAFETY_FLAGS } from "../contracts/symptomAnalysis";

const languageHintSchema = z.string()
    .regex(/^[a-z]{2,3}(?:-[A-Za-z]{2,4})?$/)
    .nullable();

const shortTextSchema = z.string().trim().min(1).max(200);

const weatherContextSchema = z.object({
    observed_at: z.string().datetime({ offset: true }),
    temperature_celsius: z.number().min(-60).max(60),
    humidity_percent: z.number().int().min(0).max(100),
    heat_warning: z.boolean()
}).strict();

export const medicalInterviewContextSchema = z.object({
    original_symptom: z.object({
        text: z.string().trim().min(1).max(2_000),
        language_hint: languageHintSchema
    }).strict(),
    medical_history: z.object({
        chronic_conditions: z.array(shortTextSchema).max(30),
        allergies: z.array(shortTextSchema).max(30),
        family_history: z.array(shortTextSchema).max(30),
        substance_use: shortTextSchema.nullable(),
        surgery_history: shortTextSchema.nullable()
    }).strict(),
    base_interview: z.object({
        duration: shortTextSchema.nullable(),
        frequency: shortTextSchema.nullable(),
        pain_intensity: z.number().int().min(0).max(10).nullable(),
        accompanying_symptoms: z.array(shortTextSchema).max(30),
        medications: z.array(shortTextSchema).max(30),
        work_environment: z.array(shortTextSchema).max(30)
    }).strict(),
    weather_context: weatherContextSchema.nullable()
}).strict();

export const generatedFollowUpQuestionSchema = z.object({
    id: z.enum(FOLLOW_UP_QUESTION_IDS),
    prompt_user: z.string().trim().min(1).max(160),
    prompt_ko: z.string().trim().min(1).max(160),
    category: z.enum(FOLLOW_UP_CATEGORIES),
    answer_type: z.literal("checkbox_yes")
}).strict();

export const generatedQuestionGroupSchema = z.object({
    title_user: z.string().trim().min(1).max(60),
    title_ko: z.string().trim().min(1).max(60),
    questions: z.array(generatedFollowUpQuestionSchema).min(1).max(4)
}).strict();

function hasValidQuestionCollection(groups: Array<z.infer<typeof generatedQuestionGroupSchema>>): boolean {
    const ids = groups.flatMap(group => group.questions.map(question => question.id));
    return ids.length >= 2 && ids.length <= 4 && new Set(ids).size === ids.length;
}

export const followUpQuestionsRequestSchema = z.object({
    schema_version: z.literal("2.0"),
    context: medicalInterviewContextSchema
}).strict();

export const followUpQuestionsResponseSchema = z.object({
    schema_version: z.literal("2.0"),
    detected_language: z.object({
        code: z.string().trim().min(1).max(20),
        name: z.string().trim().min(1).max(100)
    }).strict(),
    question_groups: z.array(generatedQuestionGroupSchema)
        .min(1)
        .max(2)
        .refine(hasValidQuestionCollection, {
            message: "question_groups must contain 2 to 4 unique questions"
        }),
    safety_flags: z.array(z.enum(SAFETY_FLAGS))
        .refine(flags => new Set(flags).size === flags.length, {
            message: "safety_flags must not contain duplicates"
        })
}).strict();

const allowedCardIDsSchema = z.array(z.enum(CARD_IDS))
    .length(CARD_IDS.length)
    .refine(
        ids => new Set(ids).size === CARD_IDS.length && CARD_IDS.every(id => ids.includes(id)),
        { message: "allowed_card_ids must contain every supported card ID exactly once" }
    );

export const medicalInterviewSummaryRequestSchema = z.object({
    schema_version: z.literal("2.0"),
    context: medicalInterviewContextSchema,
    question_groups: z.array(generatedQuestionGroupSchema)
        .min(1)
        .max(2)
        .refine(hasValidQuestionCollection, {
            message: "question_groups must contain 2 to 4 unique questions"
        }),
    selected_follow_up_question_ids: z.array(z.enum(FOLLOW_UP_QUESTION_IDS))
        .max(4)
        .refine(ids => new Set(ids).size === ids.length, {
            message: "selected_follow_up_question_ids must not contain duplicates"
        }),
    allowed_card_ids: allowedCardIDsSchema
}).strict().superRefine((request, context) => {
    const generatedIDs = new Set(
        request.question_groups.flatMap(group => group.questions.map(question => question.id))
    );
    for (const selectedID of request.selected_follow_up_question_ids) {
        if (!generatedIDs.has(selectedID)) {
            context.addIssue({
                code: "custom",
                path: ["selected_follow_up_question_ids"],
                message: `Selected follow-up question was not generated: ${selectedID}`
            });
        }
    }
});

export const medicalInterviewSummaryResponseSchema = z.object({
    schema_version: z.literal("2.0"),
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
    medical_summary_user: z.string().trim().min(1).max(2_000),
    medical_summary_ko: z.string().trim().min(1).max(2_000),
    safety_flags: z.array(z.enum(SAFETY_FLAGS))
        .refine(flags => new Set(flags).size === flags.length, {
            message: "safety_flags must not contain duplicates"
        })
}).strict().superRefine((response, context) => {
    const makesUnsupportedSafetyDenial = response.safety_flags.length === 0
        && /(위험\s*신호|호흡\s*곤란|의식\s*소실|심한\s*흉통|뇌졸중|심한\s*출혈|알레르기\s*반응).{0,80}(없|아니|부인|관찰되지|나타나지)/.test(
            response.medical_summary_ko
        );

    if (makesUnsupportedSafetyDenial) {
        context.addIssue({
            code: "custom",
            path: ["medical_summary_ko"],
            message: "medical_summary_ko must not infer absent safety signs"
        });
    }
});
