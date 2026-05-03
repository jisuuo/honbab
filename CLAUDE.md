# CLAUDE.md

> AI 에이전트(Claude 등) 작업 지침. 작업 시작 전 반드시 읽는다.
> 마지막 업데이트: 2026-04

---

## 1. 프로젝트 한 줄 요약

혼자 밥 먹는 사용자가 식당에 체크인하면, 같은 식당의 다른 혼밥러를 발견할 수 있는 모바일 서비스. 백엔드 API + React Native 앱.

---

## 2. Repo 구조

```
honbab/
├── backend/        Spring Boot API 서버 (Java 17, Gradle)
├── frontend/       React Native 앱 (TypeScript)
├── ARCHITECTURE.md 백엔드 코드 구조·규칙 (백엔드 작업 전 필독)
├── README.md       프로젝트 개요
└── CLAUDE.md       이 파일
```

모바일 작업은 `frontend/`에서, 백엔드 작업은 `backend/`에서 한다. 루트에는 문서·공용 설정만 둔다.

---

## 3. 작업 시작 전 필수 확인

| 작업 종류 | 먼저 읽을 문서 |
|---|---|
| 백엔드 코드 작성/수정 | **`ARCHITECTURE.md` 전체** (특히 §1.2 룩업 테이블, §2 RULES, §11 체크리스트) |
| 새 백엔드 슬라이스 추가 | `ARCHITECTURE.md` §3 (슬라이스 책임 정의), §8 (확장 가이드) |
| 백엔드 트랜잭션·DB 작업 | `ARCHITECTURE.md` RULE-6 |
| 프론트엔드 작업 | `frontend/README.md` (현재는 RN 기본 템플릿. 컨벤션 확립 후 보강 예정) |
| Notion 백로그 작성 | `backlog-writing-guide.md` |

---

## 4. Backend

### 4.1 현재 상태 (중요)

- **패키지**: `com.honbab.*` (ARCHITECTURE.md 기준과 일치). 메인 클래스는 `com.honbab.HonbabApplication`.
- 의존성 현황(`build.gradle`): `spring-boot-starter-web`, `validation`, `lombok`, `devtools`만 있음.
- **아직 없는 것**: JPA, Spring Security, Flyway, JWT, Supabase 연동, DB 드라이버. 이 의존성이 필요한 코드를 짜기 전에 사용자에게 추가 의향 확인.
- 슬라이스 코드(`auth/`, `restaurant/`, `session/`, `user/`)는 아직 없음. 첫 슬라이스를 만들 때 ARCHITECTURE.md §4 템플릿을 따른다.

### 4.2 명령어

```bash
cd backend
./gradlew bootRun           # 로컬 서버 실행
./gradlew test              # 전체 테스트
./gradlew test --tests "ClassName.methodName"   # 단일 테스트
./gradlew build             # 빌드 (테스트 포함)
./gradlew build -x test     # 테스트 제외 빌드
./gradlew clean             # 빌드 산출물 정리
```

### 4.3 코드 컨벤션

- **언어**: Java 17. record, switch expression, text block 적극 사용 가능.
- **Lombok**: 사용 OK. 단 엔티티에 `@Setter` 금지 (ARCHITECTURE.md AP-7).
  - 권장 조합: `@Getter`, `@RequiredArgsConstructor`, `@NoArgsConstructor(access = AccessLevel.PROTECTED)`
- **DTO**: 입력은 일반 클래스(검증 어노테이션 부착), 응답·Read DTO는 `record` 우선.
- **Optional**: 리포지토리 반환은 `Optional<T>` 그대로 두고, Service 레이어에서 `orElseThrow(BusinessException::new)`로 푼다. 컨트롤러까지 `Optional`을 끌고 가지 말 것.
- **null 반환 금지**: 컬렉션은 빈 컬렉션, 단일 객체는 `Optional` 또는 명시적 예외.
- **예외**: 도메인 예외는 `shared/exception/BusinessException` 상속. `RuntimeException` 직접 throw 금지.
- **로깅**: `@Slf4j` (Lombok). `System.out.println` 금지.

### 4.4 백엔드 작업 시 필수 체크리스트

ARCHITECTURE.md §11과 동일하지만 여기서도 반복:

1. 어느 슬라이스인가? (`auth | restaurant | session | user`)
2. 어느 레이어인가? (`api | application | domain | infra`)
3. 다른 슬라이스 데이터가 필요하면 그쪽 `application/Service`만 import (RULE-2)
4. 슬라이스 경계 넘는 데이터는 record DTO로 변환 (RULE-3)
5. 새 Service 메서드의 트랜잭션 경계 확인 (RULE-6)
6. `shared/`에 추가하려면 사용처 2곳 이상 확인 (RULE-5)
7. ARCHITECTURE.md §5의 anti-pattern을 만들지 않았는지 재확인

---

## 5. Frontend

### 5.1 현재 상태

- React Native 0.85.2 + React 19.2 + TypeScript 5.8 (CLI 부트스트랩 직후 상태).
- 컴포넌트 구조, 상태 관리(zustand/jotai/redux 등), 네트워킹(fetch/axios/RTK Query 등) 등 **컨벤션 미확정**.
- 새 컨벤션을 도입할 때는 사용자와 합의 후 이 문서 §5에 추가할 것.

### 5.2 명령어

```bash
cd frontend
npm install                 # 의존성 설치
npm start                   # Metro 번들러
npm run ios                 # iOS 시뮬레이터 실행
npm run android             # Android 에뮬레이터 실행
npm test                    # Jest 테스트
npm run lint                # ESLint
```

### 5.3 코드 컨벤션 (잠정)

- TypeScript strict 모드 가정. `any` 사용 시 주석으로 사유 명시.
- 컴포넌트는 함수형 + Hooks. 클래스 컴포넌트 금지.
- 그 외 컨벤션은 추후 합의.

---

## 6. 전역 금기사항 (모든 작업)

- **`main` 브랜치 직접 푸시 금지.** 항상 feature 브랜치 → PR.
- **DB 스키마 변경은 Flyway 마이그레이션으로만.** (도입 후) 엔티티만 바꾸고 마이그레이션 파일을 안 만들면 운영 환경 깨짐.
- **시크릿(API 키, JWT secret, DB 비밀번호) 코드/Git에 커밋 금지.** 환경변수 또는 Supabase secret manager.
- **모바일 작업은 `frontend/`에서만.** 루트에 RN 파일을 다시 만들지 않는다.
- **`node_modules/`, `build/`, `.gradle/` 안의 파일은 절대 직접 수정하지 않는다.**
- **사용자 확인 없이 의존성 추가 금지.** `build.gradle`이나 `package.json` 수정 시 먼저 사용자에게 확인.

---

## 7. 자주 헷갈리는 결정 (지침)

### 새 의존성을 추가하고 싶을 때
JPA, Security, Flyway 등 ARCHITECTURE.md가 가정하는 의존성도 아직 build.gradle에 없다. 코드 짜기 전에 사용자에게 "이 의존성을 추가하고 진행할까요?" 확인.

### `shared/`에 둘지 슬라이스 안에 둘지 (RULE-5)
- 사용처 1곳 → 슬라이스 안
- 사용처 2곳 → 후보 (옮기지 않음)
- 사용처 3곳 → `shared/`로 승격
- 애매하면 슬라이스 안에 두기 (보수적으로)

### 엔티티 vs Record DTO 반환
- 같은 슬라이스 내부 → 엔티티 OK
- 슬라이스 외부(다른 슬라이스, HTTP 응답) → 반드시 record DTO

### 테스트 작성 시
- 단위 테스트: `application/` 레이어 위주. Repository는 mock 또는 `@DataJpaTest`.
- 통합 테스트: `@SpringBootTest`는 비싸므로 핵심 시나리오만.
- 테스트 파일 위치는 production 코드와 동일한 패키지(`src/test/java/com/honbab/{slice}/...`).

---

## 8. 응답 스타일 (사용자 선호)

- 한국어로 응답.
- 작업 결과는 간결하게. 결과물 링크가 핵심이고 설명은 부수적.
- 큰 변경 전에는 계획을 먼저 보여주고 동의를 받는다.
- "~할게요" 같은 부드러운 어조 OK. 과한 격식 불필요.
- 불확실한 부분은 추측하지 말고 명시적으로 질문한다.

---

## 9. 문서 업데이트 규칙

- 새 컨벤션을 정하거나 기존 컨벤션을 바꿨다면 이 문서를 함께 업데이트한다.
- ARCHITECTURE.md의 RULE 번호를 바꿀 때는 이 문서의 참조도 같이 수정.
- 큰 변경은 맨 위 "마지막 업데이트" 날짜를 갱신.
