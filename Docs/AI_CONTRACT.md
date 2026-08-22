# APAYO AI Contract

## 목적

APAYO는 외국인 계절 농업 근로자가 모국어로 입력한 증상과 문진 답변을 의료진에게 전달 가능한 한국어 정보로 구조화합니다.

AI는 다음 작업만 수행합니다.

1. 기본 문진 이후 부족한 맥락을 확인할 체크형 추가 질문 2~4개 생성
2. 전체 문진 이후 증상 정보를 한국어로 구조화
3. 준비된 그림 카드 중 하나의 `card_id` 선택
4. 의료진용 한국어 문진 요약 생성

AI는 진단, 질병 확률 추정, 약·복용량·치료 추천, 의료기관 방문 여부 결정을 수행하지 않습니다.

## 전체 데이터 흐름

```text
모국어 자유 증상 입력
  -> 앱의 기본 문진
  -> POST /api/v2/follow-up-questions
  -> 사용자가 AI 추가 질문에 체크
  -> POST /api/v2/medical-interview-summary
  -> 구조화된 한국어 증상 + 그림 카드 + 의료진용 한국어 요약
```

Azure OpenAI 자격 증명은 Azure Functions 환경 변수로 관리하며 iOS 앱에 포함하지 않습니다.

## 공통 문진 맥락

두 API는 동일한 `context` 구조를 사용합니다.

```json
{
  "original_symptom": {
    "text": "Masakit ang ulo ko at nahihilo ako mula kaninang umaga.",
    "language_hint": "fil"
  },
  "medical_history": {
    "chronic_conditions": [],
    "allergies": [],
    "family_history": [],
    "substance_use": "Hindi umiinom o naninigarilyo",
    "surgery_history": "Walang operasyon"
  },
  "base_interview": {
    "duration": "Nagsimula ngayong umaga",
    "frequency": "Patuloy",
    "pain_intensity": 6,
    "accompanying_symptoms": ["Pagkahilo", "Pagduduwal"],
    "medications": [],
    "work_environment": ["Nagtrabaho sa greenhouse ngayong araw"]
  },
  "weather_context": {
    "observed_at": "2026-08-23T14:00:00+09:00",
    "temperature_celsius": 34.2,
    "humidity_percent": 71,
    "heat_warning": true
  }
}
```

아직 수집하지 않은 값은 `null` 또는 빈 배열을 사용합니다. AI는 누락된 정보를 추측하지 않습니다.

## 1차 API: 맥락형 추가 질문 생성

```http
POST /api/v2/follow-up-questions
Content-Type: application/json
```

### 요청

```json
{
  "schema_version": "2.0",
  "context": { "...": "공통 문진 맥락" }
}
```

### 응답

```json
{
  "schema_version": "2.0",
  "detected_language": {
    "code": "fil",
    "name": "Filipino"
  },
  "question_groups": [
    {
      "title_user": "Suriin ang kapaligiran sa trabaho",
      "title_ko": "작업 환경 추가 확인",
      "questions": [
        {
          "id": "fq_1",
          "prompt_user": "Hindi ako nakainom ng sapat na tubig habang nagtatrabaho.",
          "prompt_ko": "작업 중 수분을 충분히 섭취하지 못했습니다.",
          "category": "work_environment",
          "answer_type": "checkbox_yes"
        },
        {
          "id": "fq_2",
          "prompt_user": "Nagpatuloy ang mga sintomas kahit nagpahinga na ako.",
          "prompt_ko": "휴식 후에도 증상이 계속되었습니다.",
          "category": "symptom_change",
          "answer_type": "checkbox_yes"
        }
      ]
    }
  ],
  "safety_flags": []
}
```

### 추가 질문 규칙

- 그룹은 1~2개입니다.
- 전체 질문은 2~4개입니다.
- ID는 표시 순서대로 `fq_1`부터 `fq_4`까지 중복 없이 사용합니다.
- 모든 항목은 한 가지 사실만 확인하는 예/아니요 질문이며, 체크하면 `예`를 뜻합니다.
- 모든 항목의 `answer_type`은 `checkbox_yes`로 고정됩니다.
- `그리고`, `또는` 등으로 서로 다른 사실을 한 항목에 묶지 않습니다.
- 숫자, 자유 서술, 여러 내용을 한꺼번에 요구하는 질문은 생성하지 않습니다.
- `title_user`와 `prompt_user`는 사용자 언어로 생성합니다.
- `title_ko`와 `prompt_ko`는 의료진 전달용 한국어로 함께 생성합니다.
- 이미 기본 문진에서 명확히 답한 내용을 반복하지 않습니다.
- 섹션 제목과 질문에 진단 또는 치료 추천을 포함하지 않습니다.

허용 카테고리:

```text
symptom_change
associated_symptom
safety
work_environment
exposure
medical_context
```

## 2차 API: 최종 의료진용 결과

```http
POST /api/v2/medical-interview-summary
Content-Type: application/json
```

### 요청

```json
{
  "schema_version": "2.0",
  "context": { "...": "공통 문진 맥락" },
  "question_groups": ["1차 API가 반환한 그룹 전체"],
  "selected_follow_up_question_ids": ["fq_1", "fq_2"],
  "allowed_card_ids": [
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
  ]
}
```

체크한 ID는 반드시 1차 API가 생성한 질문에 존재해야 합니다. 체크되지 않은 항목은 명시적인 `아니오`가 아니라 `확인되지 않음`으로 취급합니다.

### 응답

```json
{
  "schema_version": "2.0",
  "detected_language": {
    "code": "fil",
    "name": "Filipino"
  },
  "symptoms": [
    {
      "name_ko": "두통",
      "body_part_ko": "머리",
      "onset_text_ko": "오늘 아침",
      "severity": 6
    },
    {
      "name_ko": "어지러움",
      "body_part_ko": null,
      "onset_text_ko": "오늘 아침",
      "severity": null
    }
  ],
  "selected_card_id": "card_headache",
  "medical_summary_user": "Masakit ang ulo ko at nahihilo ako mula kaninang umaga. Ang tindi ng sakit ay 6 sa 10. Hindi ako nakainom ng sapat na tubig habang nagtatrabaho sa greenhouse, at nagpatuloy ang mga sintomas kahit nagpahinga ako.",
  "medical_summary_ko": "오늘 아침부터 두통과 어지러움이 지속되며 통증 강도는 6점으로 응답함. 비닐하우스 작업 중 수분 섭취가 부족했고 휴식 후에도 증상이 지속됐다고 표시함.",
  "safety_flags": []
}
```

### 최종 결과 규칙

- 증상은 1~5개입니다.
- 확인되지 않은 신체 부위, 시작 시점, 강도는 `null`입니다.
- `selected_card_id`는 준비된 카드 ID 중 하나입니다.
- 명확히 대응하는 카드가 없으면 `card_default`를 사용합니다.
- `medical_summary_user`는 사용자의 언어로 작성합니다.
- `medical_summary_ko`는 의료진 전달용 한국어로 작성합니다.
- 두 요약은 언어만 다르고 동일한 보고 사실을 포함합니다.
- 두 요약 모두 사용자가 말하거나 선택한 사실만 포함합니다.
- 미선택 체크 항목을 부정 답변으로 기록하지 않습니다.

## 안전 제한

AI는 다음 작업을 수행하지 않습니다.

- 질병 또는 부상 진단
- 질병 가능성이나 확률 제시
- 약품, 복용량 또는 치료 추천
- 의료기관 방문 여부를 임의로 결정
- 사용자가 말하지 않은 병력이나 증상 추측

허용되는 `safety_flags`:

```text
breathing_difficulty
loss_of_consciousness
severe_chest_symptom
stroke_like_symptom
severe_bleeding
possible_severe_allergic_reaction
```

`safety_flags`는 진단 결과가 아닙니다. 앱은 사전 검토된 고정 안내 문구만 사용해야 하며 AI가 응급 안내 문장을 자유롭게 생성하지 않습니다.

## 검증 책임

Azure Functions는 AI 응답을 iOS에 전달하기 전에 다음을 검사합니다.

- Structured Outputs JSON Schema 준수
- 스키마 버전
- 질문 그룹·질문 개수
- 질문 ID와 카테고리
- 질문 ID 중복
- 체크한 ID가 실제 생성된 질문인지
- 증상 개수와 강도 범위
- 카드 ID와 safety flag 허용 여부

검증에 실패하면 부분 응답을 사용하지 않고 명시적인 API 오류를 반환합니다.

## 레거시 API

`POST /api/v1/symptom-analysis`는 iOS 전환이 끝날 때까지만 호환성을 위해 유지합니다. 새 사용자 플로우에서는 v2 API 두 개를 사용합니다.
