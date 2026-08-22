# APAYO AI Contract

## 목적

이 문서는 iOS 앱, Azure Functions API, Azure OpenAI 사이에서 사용하는 증상 분석 계약을 정의합니다.

AI의 역할은 사용자가 입력한 정보를 구조화하고, 앱에 준비된 증상 카드와 후속 질문을 선택하는 것입니다. AI는 진단하거나 약·치료를 추천하지 않습니다.

## 데이터 흐름

```text
iOS symptom input
  -> Azure Functions proxy
  -> Azure OpenAI Structured Outputs
  -> Azure Functions validation
  -> iOS
```

Azure OpenAI 자격 증명은 Azure Functions의 환경 변수로 관리하고 iOS 앱에 포함하지 않습니다.

## API

```http
POST /api/v1/symptom-analysis
Content-Type: application/json
```

## 요청

```json
{
  "schema_version": "1.0",
  "input": {
    "text": "Masakit ang ulo ko at nahihilo ako simula kaninang umaga.",
    "language_hint": null
  },
  "work_context": {
    "worked_today": true,
    "work_type": "outdoor_farm_work",
    "pesticide_exposure": "unknown",
    "injury_or_fall": "unknown"
  },
  "weather_context": {
    "observed_at": "2026-08-22T14:00:00+09:00",
    "temperature_celsius": 34.2,
    "humidity_percent": 71,
    "heat_warning": true
  },
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
  ],
  "allowed_question_ids": [
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
  ]
}
```

### 요청 필드 규칙

- `schema_version`은 현재 `1.0`입니다.
- `input.text`는 공백이 아닌 문자열이어야 합니다.
- `input.language_hint`는 ISO 639-1 언어 코드 또는 `null`입니다.
- `work_context`와 `weather_context`는 수집하지 못한 경우 각각 `null`일 수 있습니다.
- 확인되지 않은 노출 여부는 추측하지 않고 `unknown`을 사용합니다.
- iOS가 전달한 ID는 서버가 보유한 허용 목록과 다시 대조합니다.

## 응답

```json
{
  "schema_version": "1.0",
  "detected_language": {
    "code": "tl",
    "name": "Tagalog"
  },
  "symptoms": [
    {
      "name_ko": "두통",
      "body_part_ko": "머리",
      "onset_text_ko": "오늘 아침",
      "severity": null
    },
    {
      "name_ko": "어지러움",
      "body_part_ko": null,
      "onset_text_ko": "오늘 아침",
      "severity": null
    }
  ],
  "selected_card_id": "card_headache",
  "selected_question_ids": [
    "q_severity",
    "q_heat_exposure",
    "q_water_intake"
  ],
  "safety_flags": [],
  "clarification_note_ko": null
}
```

### 응답 필드 규칙

- `symptoms`는 최소 1개, 최대 5개입니다.
- 사용자가 직접 말하지 않은 정보는 추측하지 않고 `null`로 반환합니다.
- `severity`는 사용자가 말한 경우에만 0부터 10까지의 정수로 반환합니다.
- `selected_card_id`는 허용된 카드 ID 중 정확히 하나입니다.
- 대응하는 카드가 없으면 `card_default`를 반환합니다.
- `selected_question_ids`는 허용 목록에서 중복 없이 2개 이상 4개 이하입니다.
- 질문은 이미 확인된 내용보다 아직 확인되지 않은 중요 정보를 우선합니다.
- AI는 새로운 카드 ID나 질문 ID를 만들 수 없습니다.
- `clarification_note_ko`는 번역 또는 의미가 불확실할 때만 사용합니다.

## 카드 선택 규칙

1. 입력과 명확하게 대응하는 카드가 있으면 해당 카드를 선택합니다.
2. 증상이 여러 개이면 주된 증상을 가장 잘 표현하는 카드 하나를 선택합니다.
3. 어느 카드에도 명확히 해당하지 않으면 `card_default`를 선택합니다.
4. 서버는 허용되지 않은 ID를 받으면 응답을 실패 처리하거나 `card_default`로 대체합니다.

## 후속 질문 선택 규칙

1. 반드시 `follow_up_questions.json`에 존재하는 ID만 선택합니다.
2. 질문은 2개 이상 4개 이하를 선택합니다.
3. 안전 확인이 필요하면 안전 관련 질문을 우선합니다.
4. 작업 및 날씨 맥락과 관련된 질문을 우선할 수 있습니다.
5. 사용자가 원문에서 이미 명확히 답한 질문은 다시 선택하지 않습니다.

## 안전 제한

AI는 다음 작업을 수행하지 않습니다.

- 질병 또는 부상 진단
- 질병 가능성이나 확률 제시
- 약품, 복용량 또는 치료 추천
- 의료기관 방문 여부를 임의로 결정
- 사용자가 말하지 않은 병력이나 증상 추측

허용되는 `safety_flags` 값은 다음과 같습니다.

```text
breathing_difficulty
loss_of_consciousness
severe_chest_symptom
stroke_like_symptom
severe_bleeding
possible_severe_allergic_reaction
```

`safety_flags`는 진단 결과가 아닙니다. 앱은 각 flag에 대응하는 사전 검토된 고정 안내 문구를 표시해야 합니다. AI가 응급 안내 문장을 자유롭게 생성하도록 하지 않습니다.

## 서버 검증

Azure Functions는 AI 응답을 iOS에 전달하기 전에 다음을 확인합니다.

- Structured Outputs JSON Schema 통과 여부
- 스키마 버전
- 증상 개수
- severity 범위
- 카드 ID 존재 여부
- 질문 ID 존재 여부
- 질문 개수와 중복
- safety flag 허용 여부

Structured Outputs 검증에 실패하면 부분 응답을 사용하지 않고 명시적인 API 오류를 반환합니다.

## 선택적 의료진 요약

증상 분석 API가 안정화된 뒤 별도 API로 구현합니다.

```http
POST /api/v1/medical-summary
```

요약 API는 구조화된 증상, 후속 질문 답변, 작업 환경, 날씨 정보를 입력받아 의료진용 한국어 문진 정보를 생성합니다. 진단 및 치료 추천은 포함하지 않습니다.
