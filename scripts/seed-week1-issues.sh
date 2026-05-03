#!/usr/bin/env bash
# Week 1 백로그 5개를 GitHub Issues로 등록
# 사전조건: bash scripts/seed-labels.sh 먼저 실행 (라벨 존재해야 함)
#          gh auth login 완료
# 사용법:   bash scripts/seed-week1-issues.sh

set -euo pipefail

REPO="${REPO:-jisuuo/honbab}"

# Notion BL 페이지 링크 (마스터 컨텍스트는 노션, 깃허브는 트래커)
NOTION_BL00="https://www.notion.so/354c72e186db81c1a7cffae2b8eca0c7"
NOTION_BL01="https://www.notion.so/354c72e186db810bb0f2e80e293bb9b1"
NOTION_BL02="https://www.notion.so/354c72e186db816e9165e50e96466eb6"
NOTION_BL03="https://www.notion.so/354c72e186db812382fbc3e58c5c1846"
NOTION_BL04="https://www.notion.so/354c72e186db81a7a104f1322afbf4a0"
NOTION_BL05="https://www.notion.so/354c72e186db81e49677e89224d290be"

echo "=== Week 1 백로그 → GitHub Issues 등록 ==="
echo ""

# ── BL-00 ────────────────────────────────────────────
gh issue create --repo "$REPO" \
  --title "BL-00 프로젝트 구조 + README + ADR-0" \
  --label "area: docs,type: chore,mvp: week1,size: S" \
  --body "## 📅 Day 0 · 워밍업 · 30~60m

## 🔗 자세한 내용 (노션 마스터)
$NOTION_BL00

## 🎯 목표
레포를 처음 본 사람도 README 1분이면 이해할 수 있고, HONBAP 첫 아키텍처 결정이 ADR-0 으로 박혀있다.

## 🛠️ 작업
- [ ] 폴더 구조: backend/ + mobile/ 결정 (모노레포)
- [ ] 현재 RN 파일들 mobile/ 로 이동 (git mv)
- [ ] README.md 작성 (한 줄 설명, 기술 스택, 로컬 실행, 도구)
- [ ] ARCHITECTURE.md 작성 (시스템 컨텍스트 그림 — 텍스트 OK)
- [ ] ADR-0 작성: '모노레포 채택 (backend / mobile)'

## ✅ 완료 기준
- [ ] 레포 루트에 README.md + ARCHITECTURE.md 존재
- [ ] mobile/ 안에서 yarn ios / yarn android 동작 (이동 후 검증)
- [ ] 노션 ADR DB 에 ADR-0 페이지 1개
- [ ] 커밋: docs(bl-00): 프로젝트 구조 + README + ADR-0

## 📚 학습 (Claude 와 페어)
- Q1. 모노레포 vs 폴리레포, 1인 개발자에 모노레포가 유리한 이유
- Q2. 좋은 README 의 조건"

# ── BL-01 ────────────────────────────────────────────
gh issue create --repo "$REPO" \
  --title "BL-01 Supabase 셋업 + Postgres/RLS 학습" \
  --label "area: infra,type: feature,mvp: week1,size: S" \
  --body "## 📅 Day 1 · 5/3 (일) · 1.5h

## 🔗 자세한 내용 (노션 마스터)
$NOTION_BL01

## 🎯 목표
HONBAP DB 가 클라우드에 살아있고, \"Supabase 가 뭐고 RLS 가 왜 중요한지\"를 한 단락으로 설명할 수 있다.

## 🛠️ 작업
- [ ] supabase.com 가입 + 새 프로젝트 (리전 ap-northeast-2 Seoul)
- [ ] DB 비밀번호 저장 (1Password 등)
- [ ] Connection string 메모
- [ ] 로컬 psql 로 접속 → \\dt 실행

## ✅ 완료 기준
- [ ] 대시보드 ACTIVE
- [ ] \\dt 정상 응답
- [ ] 학습노트 1개: \"Supabase 아키텍처 + RLS 기초\"

## 📚 학습 (Claude 와 페어)
- Q1. Supabase vs Firebase, Postgres 그대로 노출하는 게 왜 중요한가
- Q2. RLS 가 모바일 앱에서 왜 중요한가"

# ── BL-02 ────────────────────────────────────────────
gh issue create --repo "$REPO" \
  --title "BL-02 카카오 디벨로퍼 등록 + OAuth2 Flow 학습" \
  --label "area: infra,type: feature,mvp: week1,size: S" \
  --body "## 📅 Day 2 · 5/4 (월) · 1.5h

## 🔗 자세한 내용 (노션 마스터)
$NOTION_BL02

## 🎯 목표
카카오 동의 화면을 직접 띄울 수 있고, OAuth2 Authorization Code Flow 를 종이에 그릴 수 있다.

## 🛠️ 작업
- [ ] developers.kakao.com 새 앱 + 키 4종 메모
- [ ] 카카오 로그인 활성화
- [ ] Redirect URI: http://localhost:8080/auth/kakao/callback
- [ ] 동의 항목: 닉네임 / 프로필 이미지
- [ ] 브라우저에서 인가 URL 직접 쳐서 동의 화면 확인

## ✅ 완료 기준
- [ ] 카카오 동의 화면이 떨어짐
- [ ] 학습노트 1개: \"OAuth2 Authorization Code Flow\" + 다이어그램

## 📚 학습 (Claude 와 페어)
- Q1. 왜 OAuth2 가 단순 username/password 보다 안전한가
- Q2. Authorization Code 와 Access Token 의 차이, 왜 두 단계인가
- Q3. Refresh Token 은 왜 따로 있는가"

# ── BL-03 ────────────────────────────────────────────
gh issue create --repo "$REPO" \
  --title "BL-03 Spring Boot 부트스트랩 + DI/Auto-config 학습" \
  --label "area: backend,type: feature,mvp: week1,size: M" \
  --body "## 📅 Day 3 · 5/6 (수) · 1.5~2h

## 🔗 자세한 내용 (노션 마스터)
$NOTION_BL03

## 🎯 목표
빈 Spring Boot 프로젝트가 localhost:8080 에서 떠지고, \"DI 컨테이너\" 와 \"Auto-Configuration\" 을 본인 말로 설명할 수 있다.

## 🛠️ 작업
- [ ] start.spring.io: Java 21 / Gradle / Spring Boot 3.x
- [ ] 의존성: Spring Web + Lombok (지금은 최소만)
- [ ] 패키지 구조: config / auth / user / restaurant / session / common
- [ ] ./gradlew bootRun → \"Started HonbabApplication\" 확인
- [ ] localhost:8080 → 화이트라벨 에러 페이지

## ✅ 완료 기준
- [ ] bootRun 으로 8080 서버 뜸
- [ ] 학습노트 1개: \"Spring Boot 의 마법 — Auto-Configuration 과 DI\"

## 📚 학습 (Claude 와 페어)
- Q1. DI 컨테이너가 대체 뭐고 왜 필요한가
- Q2. @SpringBootApplication 하나가 무슨 일을 하는가
- Q3. Auto-Configuration 이 어떻게 'classpath 보고 알아서' 되는가"

# ── BL-04 ────────────────────────────────────────────
gh issue create --repo "$REPO" \
  --title "BL-04 Spring → Supabase 연결 + JDBC/JPA 학습" \
  --label "area: backend,type: feature,mvp: week1,size: M" \
  --body "## 📅 Day 4 · 5/7 (목) · 2h

## 🔗 자세한 내용 (노션 마스터)
$NOTION_BL04

## 🎯 목표
Spring 서버가 Supabase 에 붙고 SELECT 1 이 통과한다. ORM 의 추상화 레벨을 한 단락으로 설명할 수 있다.

## 🛠️ 작업
- [ ] build.gradle 에 spring-boot-starter-data-jpa, postgresql 추가
- [ ] application.yml: Supabase 연결 (env 로 분리)
- [ ] .env / .gitignore 확인
- [ ] DbCheckRunner: ApplicationRunner + JdbcTemplate.SELECT 1
- [ ] bootRun → 콘솔에 \"DB ping: OK\"

## ✅ 완료 기준
- [ ] 콘솔에 DB ping 성공
- [ ] .env 가 git 에 안 올라감 (status 로 확인)
- [ ] 학습노트 1개: \"ORM 추상화 — JDBC, JPA, Hibernate, Spring Data\"

## 📚 학습 (Claude 와 페어)
- Q1. JDBC 직접 vs JPA — 근본적 차이
- Q2. Hibernate 와 JPA 의 관계, Spring Data JPA 의 추가 기여
- Q3. 4계층 추상화 그림으로 그리기"

# ── BL-05 ────────────────────────────────────────────
gh issue create --repo "$REPO" \
  --title "BL-05 /health 엔드포인트 + Spring MVC + 첫 ADR" \
  --label "area: backend,type: feature,mvp: week1,size: S" \
  --body "## 📅 Day 5 · 5/8 (금) · 1.5h

## 🔗 자세한 내용 (노션 마스터)
$NOTION_BL05

## 🎯 목표
/health 엔드포인트가 200 OK 응답하고, HTTP 요청이 Spring 안에서 흐르는 경로를 종이에 그릴 수 있다. ADR-1 이 노션에 존재.

## 🛠️ 작업
- [ ] HealthController (@RestController)
- [ ] GET /health → { status: \"UP\", db: \"OK\" }
- [ ] 내부에서 JdbcTemplate.SELECT 1 — 예외 시 \"DOWN\"
- [ ] curl localhost:8080/health → 200
- [ ] DB 의도적 끊고 \"DOWN\" 응답 확인

## ✅ 완료 기준
- [ ] /health 200 + JSON
- [ ] DB 끊김 시 'db: DOWN'
- [ ] 학습노트 1개: \"Spring MVC 요청 처리 흐름\"
- [ ] **ADR-1 작성**: \"Spring Boot 3 + Java 21 채택\"
- [ ] Week 1 회고 — 작업일지에 한 페이지

## 📚 학습 (Claude 와 페어)
- Q1. @RestController 가 붙으면 Spring 이 추가로 해주는 일
- Q2. DispatcherServlet 의 역할, 라우팅 메커니즘
- Q3. Filter / Interceptor / ControllerAdvice 수행 순서"

echo ""
echo "─────────────────────────────"
echo "✅ Week 1 백로그 6개 등록 완료 (BL-00 ~ BL-05)"
echo ""
echo "확인:"
echo "  - 이슈 목록:  https://github.com/$REPO/issues"
echo "  - 칸반 보드:  https://github.com/users/jisuuo/projects/3"
echo ""
echo "Auto-add 워크플로우가 켜져있으면 5개 모두 Backlog 컬럼에 자동 추가됩니다."
