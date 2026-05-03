# HONBAP

> 혼자 밥 먹는 사람들을 위한 식당 체크인 서비스 (MVP 개발 중)

---

## Repo Layout

```
honbab/
├── backend/      Spring Boot 3.5 / Java 17 / Gradle (API 서버)
├── frontend/     React Native 0.72 / TypeScript (모바일 앱)
└── docs/         (예정) 추가 문서
```

루트의 `App.tsx`, `package.json`, `ios/`, `android/` 등은 React Native 초기 부트스트랩 잔재예요. 정식 모바일 코드는 `frontend/`에 있어요.

---

## 기술 스택

**Backend** — Spring Boot 3.5.14, Java 17, Gradle. JPA·Security·Flyway·Supabase Auth는 도입 예정.

**Frontend** — React Native 0.72, TypeScript 4.8.

**Infra (예정)** — Supabase (Postgres + Auth), 카카오 로컬 API, FCM.

---

## 빠른 시작

### Backend
```bash
cd backend
./gradlew bootRun       # 로컬 서버 실행
./gradlew test          # 테스트
./gradlew build         # 빌드
```

### Frontend
```bash
cd frontend
npm install
npm start               # Metro 번들러
npm run ios             # iOS 시뮬레이터
npm run android         # Android 에뮬레이터
```

---

## 문서

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** — 백엔드 코드 구조와 작성 규칙. 백엔드 코드를 만지기 전에 반드시 읽기.
- **[CLAUDE.md](./CLAUDE.md)** — AI 에이전트(Claude 등) 작업용 가이드. 명령어, 컨벤션, 금기사항 모음.
- **[backlog-writing-guide.md](./backlog-writing-guide.md)** — Notion 백로그 작성 규칙.
- **[notion-schema-spec.md](./notion-schema-spec.md)** — Notion DB 스키마 명세.

---

## 진행 상태

- [x] 백엔드 Spring Boot 스캐폴딩
- [x] 프론트엔드 React Native 스캐폴딩
- [x] 백엔드 아키텍처 설계 (ARCHITECTURE.md)
- [ ] 백엔드 패키지명 정리 (`jisu.backend` → `com.honbap`)
- [ ] 루트 RN 잔재 정리 (`frontend/`만 남기기)
- [ ] auth 슬라이스 구현 (카카오 OAuth + JWT)
- [ ] restaurant / session / user 슬라이스 구현
- [ ] Supabase 연동, Flyway 마이그레이션 도입
