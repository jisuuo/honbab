# Notion DB 스키마 명세 — Architect Coach System

> Backlog DB와 Coach Prompts DB의 구조와 만드는 순서.

---

## 전체 그림

```
[Backlog DB]
    │
    │  Layer + Tags 매칭
    ▼
[Coach Prompts DB]
    │
    │  Type=Base 1개 + 매칭된 Topic N개
    ▼
[합성된 system prompt]
    │
    ▼
   Claude (CLI: --system-prompt / Cowork: 컨텍스트 주입)
```

---

## DB 1: Backlog (기존 DB 확장)

기존 백로그 DB에 속성을 추가한다. **기존 데이터는 유지**.

| 속성 | 타입 | 필수 | 비고 |
|---|---|---|---|
| Title | Title | ✅ | `[레이어] 동사 + 대상` 형태 |
| ID | Text 또는 Unique ID | ✅ | `BL-001` 형태. CLI 호출 키 |
| Status | Select | ✅ | Todo / Doing / Done |
| **Layer** | **Select** (단일) | ✅ **신규** | Frontend / Backend / Infra |
| **Tags** | **Multi-select** | ⭕ **신규** | 2~4개 |

⚠️ **Layer는 반드시 단일 선택** (Multi-select 아님). "1 백로그 1 레이어" 원칙 강제.

### Notion에서 Unique ID 만드는 방법
Notion DB 설정 → "Unique ID" 속성 추가 → Prefix를 `BL`로 지정 → 자동으로 `BL-1`, `BL-2`, ... 생성됨.

---

## DB 2: Coach Prompts (신규 생성)

| 속성 | 타입 | 비고 |
|---|---|---|
| Title | Title | 예: `Frontend Architecture` |
| **Slug** | Text | 영문 kebab-case, **유니크**. 예: `frontend-architecture` |
| Type | Select | `Base` / `Topic` |
| Layer | Multi-select | Frontend / Backend / Infra |
| Tags | Multi-select | Backlog와 동일 풀 |
| Active | Checkbox | true면 매칭 후보, false면 비활성 |

페이지 **본문**에 실제 코치 prompt md 내용을 작성한다.

### Slug를 따로 두는 이유
- Title은 한국어/공백/이모지 등 가능 → API 매칭 시 깨지기 쉬움
- Slug는 영문 kebab-case로 강제 → 안전한 식별자 역할
- CLI 디버깅 시 `coach --topic frontend-architecture` 같은 직접 호출도 가능

---

## 공유 옵션 풀 (두 DB가 같은 값을 가져야 매칭됨)

⚠️ **Notion은 두 DB의 multi-select 옵션을 자동 동기화하지 않는다.** 두 DB에서 **각각** 같은 이름으로 옵션을 만들어야 매칭이 작동한다. (예: Backlog의 `#api-design` 태그와 Coach Prompts의 `#api-design` 태그가 이름이 정확히 같아야 함)

### Layer 옵션 (단일 선택)
- `Frontend`
- `Backend`
- `Infra`

### Tags 옵션 (시작 시 권장 — 점진적 확장)

**Frontend**
- `#routing`
- `#state-management`
- `#component-design`
- `#styling`
- `#data-fetching`

**Backend**
- `#api-design`
- `#auth`
- `#database`
- `#error-handling`
- `#caching`

**Infra**
- `#ci-cd`
- `#monitoring`
- `#deploy`
- `#secret-management`

태그는 처음부터 다 만들지 말고, 백로그를 작성하면서 필요할 때마다 추가한다 (YAGNI).

---

## Coach Prompts 초기 row (5개로 시작)

DB 생성 후 다음 5개 row를 만들어 둔다. **본문은 비워둬도 OK** — 점진적으로 채운다.

| Title | Slug | Type | Layer | 본문 시작 시기 |
|---|---|---|---|---|
| Architect Coach Base | `architect-coach-base` | Base | (전체) | 즉시 (지금 가진 md 그대로 붙여넣기) |
| Frontend Architecture | `frontend-architecture` | Topic | Frontend | 첫 Frontend 백로그 시작할 때 |
| Backend API Design | `backend-api-design` | Topic | Backend | 첫 Backend 백로그 시작할 때 |
| Database Design | `database-design` | Topic | Backend | DB 관련 백로그 처음 만날 때 |
| Infra Foundation | `infra-foundation` | Topic | Infra | 첫 Infra 백로그 시작할 때 |

---

## 만드는 순서

### 1. Coach Prompts DB 만들기 (Notion)
- 새 데이터베이스 생성 (이름: `Coach Prompts`)
- 위 속성 6개 추가
- 위 표의 5개 row 생성
- `Architect Coach Base` row의 본문에 현재 가진 `architect-coach-prompt.md` 내용 그대로 붙여넣기

### 2. Backlog DB에 속성 추가
- 기존 Backlog DB 편집
- `Layer` (Select), `Tags` (Multi-select) 속성 추가
- `ID`가 없으면 Unique ID 속성 추가 (Prefix: `BL`)

### 3. Tags 옵션을 두 DB에 동일하게 추가
- Backlog와 Coach Prompts **양쪽 모두**에서 같은 태그 이름을 등록
- 처음엔 위 권장 풀 중 자주 쓸 4~6개만

### 4. 기존 백로그 1~2개 채워서 검증
- 기존 백로그 항목에 Layer/Tags 채워보기
- 잘 들어맞으면 OK, 어색하면 태그 풀 조정

### 5. (다음 단계 — 별도 작업) CLI 스크립트 작성
- Notion API 토큰 발급
- `coach BL-XXX` 명령어 셸 스크립트 작성
- Notion API → 백로그 조회 → 매칭 prompt 합성 → claude 실행

---

## 두 환경에서 사용

### Cowork
- Notion MCP가 이미 연결돼 있음
- 새 대화 시작할 때: `오늘 BL-042 작업할게. 매칭되는 Coach Prompts 읽고 시작해줘`
- Claude가 Notion에서 직접 fetch → 컨텍스트로 사용

### CLI (다음 단계에서 만들 것)
- 셸 스크립트가 Notion API로 fetch → 임시 파일 합성
- `claude --system-prompt /tmp/coach-active.md`

---

## 알려진 한계 / 주의

- Notion API 호출은 무료 플랜에서 분당 3 req 제한 → CLI에서 캐싱 필요할 수도
- Layer는 단일이지만 Tags는 멀티 → 매칭이 너무 광범위하면 prompt가 비대해질 수 있음. 그때는 매칭 규칙을 "Layer 일치 AND Tag 1개 이상 일치"로 강화
- Coach Prompts 본문이 너무 길어지면 system prompt 토큰 한도 초과 위험 → 각 Topic md를 1500토큰 이내로 유지 권장
