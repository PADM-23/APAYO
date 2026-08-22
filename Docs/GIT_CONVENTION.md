# APAYO Git 컨벤션

## 기본 원칙

- `main`은 항상 실행 가능한 상태로 유지합니다.
- `main`에 직접 push하지 않고 Pull Request로 병합합니다.
- 한 브랜치와 Pull Request에는 하나의 목적만 담습니다.
- 병합은 기본적으로 **Squash and merge**를 사용합니다.
- 병합 후 작업 브랜치는 삭제합니다.

## 브랜치 이름

형식은 `<type>/<issue-number>-<short-description>`입니다. 이슈가 없다면 번호를 생략할 수 있습니다.

```text
feature/12-multilingual-symptom-input
fix/23-interview-answer-persistence
refactor/medical-summary-mapper
docs/public-data-sources
```

사용 가능한 타입은 다음과 같습니다.

- `feature`: 사용자 기능
- `fix`: 버그 수정
- `refactor`: 동작을 바꾸지 않는 구조 개선
- `test`: 테스트
- `docs`: 문서
- `chore`: 설정과 도구
- `hotfix`: 배포된 버전의 긴급 수정

브랜치 이름은 영어 소문자와 kebab-case를 사용합니다.

## 커밋 메시지

[Conventional Commits](https://www.conventionalcommits.org/) 형식을 사용합니다.

```text
<type>(<scope>): <subject>
```

### 커밋 타입

- `feat`: 기능 추가
- `fix`: 버그 수정
- `refactor`: 동작 변경 없는 구조 개선
- `test`: 테스트 추가 또는 수정
- `docs`: 문서 변경
- `style`: 포맷 등 동작과 무관한 변경
- `chore`: 설정, 도구, 의존성 관리
- `build`: 빌드 시스템 변경
- `ci`: CI 변경
- `perf`: 성능 개선
- `revert`: 이전 커밋 되돌리기

### 권장 scope

`app`, `symptom`, `interview`, `work-context`, `weather`, `summary`, `facility`, `network`, `location`, `localization`, `persistence`

### 예시

```text
feat(symptom): add Vietnamese symptom input validation
feat(weather): connect KMA weather repository
fix(summary): preserve unknown allergy field
test(interview): add pesticide exposure branch cases
docs(data): document KMA API fields and license
chore(project): add pull request template
```

제목은 영어 명령형으로 작성하고 마침표를 붙이지 않습니다. `update`, `change`, `작업`처럼 변경 의도가 드러나지 않는 표현은 피합니다.

호환성이 깨지는 변경에는 타입 뒤에 `!`를 붙이고 본문에 `BREAKING CHANGE:`를 작성합니다.

## Pull Request

PR 제목도 커밋 메시지 형식을 따릅니다.

```text
feat(interview): implement agricultural work questionnaire
```

저장소의 PR 템플릿에 따라 변경 내용과 확인 방법을 간단히 기록합니다. 공공데이터·AI를 변경한 경우에만 출처와 기준 시점 또는 AI의 역할을 참고 항목에 추가합니다.

최소 한 명의 승인을 받고 CI가 통과한 뒤 병합합니다. 리뷰 의견이 해결되지 않은 상태에서는 병합하지 않습니다.

## Issue

작업 전에 기능 또는 버그 이슈를 생성합니다. 이슈 제목은 템플릿의 `[Feature]`, `[Bug]` 접두사를 유지하고, 본문은 완료 여부를 판단할 수 있을 정도로만 간결하게 작성합니다.

## 버전 태그

Semantic Versioning 형식인 `v<major>.<minor>.<patch>`를 사용합니다.

```text
v0.1.0  내부 프로토타입
v0.9.0  해커톤 데모 후보
v1.0.0  제출 버전
v1.0.1  제출 버그 수정
```
