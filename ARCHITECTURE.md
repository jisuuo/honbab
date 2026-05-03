# HONBAP Backend Architecture Guide

> 백엔드 코드 작성·리뷰 기준 문서. AI 에이전트와 개발자가 모두 참조한다.
> 적용 범위: `backend/src/main/java/com/honbap/**`
> 구조: Vertical Slice + Layered (Package by Feature, Layered inside)
> 마지막 업데이트: 2026-04

---

## 0. TL;DR (30초 요약)

- 코드는 **슬라이스(기능)** → **레이어(역할)** 순으로 분류한다: `com.honbap.{slice}.{api|application|domain|infra}`.
- 의존성 방향: `api → application → domain ← infra`. **`domain`은 누구에게도 의존하지 않는다.**
- 슬라이스 외부에 노출 가능한 건 **`application/`의 Service와 Read DTO(record)**뿐. 엔티티·리포지토리는 슬라이스 안에 가둔다.
- `shared/`는 횡단 관심사(보안·예외·BaseEntity 등)만. 도메인 로직 금지. **Rule of Three** (3번째 사용처에서 승격).

---

## 1. QUICK REFERENCE

### 1.1 새 파일 만들기 전 결정 트리

1. 어느 슬라이스에 속하는가? → `auth | restaurant | session | user` (없으면 새 슬라이스)
2. 어느 레이어인가? → `api | application | domain | infra`
3. 2개 이상 슬라이스가 쓰는 횡단 코드인가? → `shared/` 후보 (단, 3번째 사용처가 생길 때 옮김)

### 1.2 파일 위치 룩업 테이블

| 만들려는 것 | 위치 | 예시 |
|---|---|---|
| REST 컨트롤러 | `{slice}/api/` | `SessionController.java` |
| 요청/응답 DTO | `{slice}/api/dto/` | `CheckInRequest.java`, `SessionResponse.java` |
| 유스케이스 Service | `{slice}/application/` | `SessionService.java` |
| 슬라이스 간 공유 Read DTO (record) | `{slice}/application/` | `RestaurantInfo.java` |
| 도메인 검증/정책 객체 | `{slice}/application/` | `GpsValidator.java` |
| 스케줄러 | `{slice}/application/` | `AutoExpireScheduler.java` |
| JPA 엔티티 | `{slice}/domain/` | `Session.java` |
| JPA 리포지토리 | `{slice}/infra/` | `SessionRepository.java` |
| 외부 API 클라이언트 | `{slice}/infra/` | `KakaoLocalApiClient.java`, `FcmClient.java` |
| 전역 Spring Security 설정 | `shared/security/` | `SecurityConfig.java` |
| JWT 인증 필터 (검증) | `shared/security/` | `JwtAuthenticationFilter.java` |
| JWT 발급 (auth 책임) | `auth/application/` | `JwtProvider.java` |
| 전역 예외 핸들러 | `shared/exception/` | `GlobalExceptionHandler.java` |
| 모든 엔티티 base 클래스 | `shared/domain/` | `BaseEntity.java` |
| 공통 응답 wrapper | `shared/web/` | `ApiResponse.java` |
| Flyway 마이그레이션 | `src/main/resources/db/migration/` | `V1__init.sql` |

---

## 2. RULES (위반 시 코드 리뷰 차단)

### RULE-1 — 의존성은 항상 도메인을 향한다

```
api  →  application  →  domain  ←  infra
```

- `domain/`은 어떤 외부 패키지에도 의존하지 않는다 (Spring·JPA 어노테이션은 예외).
- `infra/`는 `domain/`만 의존한다. `application/`이나 `api/`를 import 금지.
- `application/`은 `domain/`과 같은 슬라이스의 `infra/` interface, 그리고 다른 슬라이스의 `application/`만 의존.

### RULE-2 — 슬라이스 외부 노출은 `application/`만

다른 슬라이스에서 import 가능 여부:

| import 대상 | 가능 여부 |
|---|---|
| `{otherSlice}.application.{Name}Service` | ✅ |
| `{otherSlice}.application.{Name}Info` (Read DTO) | ✅ |
| `{otherSlice}.domain.*` (엔티티) | ❌ |
| `{otherSlice}.infra.*` (Repository, Client) | ❌ |
| `{otherSlice}.api.*` (Controller, HTTP DTO) | ❌ |

### RULE-3 — 슬라이스 경계 넘는 데이터는 immutable Read DTO

엔티티(`@Entity`)는 슬라이스를 넘지 않는다. record로 변환해서 내보낸다.

```java
// ✅ OK
public RestaurantInfo findById(UUID id) {
    Restaurant r = repo.findById(id).orElseThrow();
    return RestaurantInfo.from(r);
}

// ❌ 금지
public Restaurant findById(UUID id) { ... }
```

이유: dirty checking으로 인한 의도치 않은 UPDATE, lazy loading N+1 발생, 엔티티 필드 변경의 컴파일 에러 전파 방지.

### RULE-4 — `api/` vs `infra/`는 방향으로 구분

| 데이터 흐름 | 폴더 | 예시 |
|---|---|---|
| 외부 → 내 도메인 (inbound) | `api/` | `@RestController`, GraphQL Resolver |
| 내 도메인 → 외부 (outbound) | `infra/` | JPA Repository, REST Client, FCM, Kafka Producer |

`infra/`는 "DB 폴더"가 아니라 **"외부 기술과 만나는 모든 outbound 지점"**.

### RULE-5 — `shared/`는 Rule of Three

- 1개 슬라이스만 사용 → 그 슬라이스 안에 둔다.
- 2개 슬라이스가 사용 → 후보. 아직 옮기지 않는다.
- 3번째 사용처가 생기는 PR에서 `shared/`로 승격한다.
- `shared/`에 도메인 로직(비즈니스 규칙)을 절대 두지 않는다.

### RULE-6 — `@Transactional`은 유스케이스 진입점에 한 번만

- 컨트롤러가 처음 호출하는 `application/` 메서드에 한 번만 붙인다.
- 호출당하는 다른 슬라이스 Service는 기본 propagation(`REQUIRED`)으로 두고 추가 어노테이션 금지.
- 클래스 레벨에는 `@Transactional(readOnly = true)`를 기본으로 두고, 쓰기 메서드만 `@Transactional`로 override한다.

### RULE-7 — 슬라이스 간 양방향 의존 금지

`session → restaurant` 의존이 있으면 `restaurant → session` 의존 금지. 필요해지는 순간 도메인 이벤트로 분리한다 (현재 단계에서는 도입 보류).

---

## 3. SLICE 책임 정의

각 슬라이스의 책임 경계. 새 코드를 어디에 둘지 모를 때 이 정의로 판단한다.

### `auth/`
- **책임**: 카카오 OAuth 검증, JWT 발급, 리프레시 토큰 관리
- **엔티티**: `RefreshToken`
- **외부 의존**: 카카오 인증 서버
- **공개 API**: `AuthService` (login / refresh / logout)
- **안 다룸**: JWT 검증 필터(=`shared/security/`), 사용자 프로필(=`user/`)

### `restaurant/`
- **책임**: 식당 CRUD, 카카오 로컬 API 프록시, 위치 검색
- **엔티티**: `Restaurant`
- **외부 의존**: 카카오 로컬 API
- **공개 API**: `RestaurantService.findById(UUID) → RestaurantInfo`
- **안 다룸**: 식당 평점·투표 (Phase 2의 `vote/`)

### `session/`
- **책임**: 혼밥 체크인/체크아웃, GPS 검증(반경 200m), 자동 만료(2시간), 110분 알림
- **엔티티**: `Session`
- **외부 의존**: FCM
- **공개 API**: `SessionService` (checkIn / checkOut / findActive / findHistory)
- **다른 슬라이스 의존**: `restaurant`(위치 검증), `user`(체크인 주체)

### `user/`
- **책임**: 사용자 프로필, 통계 집계
- **엔티티**: `User` (Supabase Auth와 1:1 매핑)
- **공개 API**: `UserService.findById(UUID) → UserInfo`, `UserStatsService`

### `shared/`
- **책임**: 모든 슬라이스가 공유하는 횡단 관심사만
- **현재 멤버**: `BaseEntity`, `SecurityConfig`, `JwtAuthenticationFilter`, `GlobalExceptionHandler`, `BusinessException`, `ApiResponse`
- **금지**: 도메인 로직, 유스케이스, 특정 슬라이스에만 쓰이는 util

---

## 4. CODE TEMPLATES

복사해서 시작하는 표준 골격.

### 4.1 컨트롤러

```java
package com.honbap.{slice}.api;

@RestController
@RequestMapping("/api/{slice-plural}")
@RequiredArgsConstructor
public class {Name}Controller {
    private final {Name}Service service;

    @PostMapping
    public ApiResponse<{Name}Response> create(
            @Valid @RequestBody {Name}Request req,
            @AuthenticationPrincipal UUID userId) {
        return ApiResponse.ok(service.create(userId, req));
    }
}
```

### 4.2 Service (유스케이스)

```java
package com.honbap.{slice}.application;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)  // 클래스 기본
public class {Name}Service {
    private final {Name}Repository repository;
    private final OtherSliceService otherService;  // 다른 슬라이스 Service만 주입

    @Transactional  // 쓰기 메서드만 명시
    public {Name}Response create(UUID userId, {Name}Request req) {
        // 1. 다른 슬라이스 의존 호출 (Read DTO로 받음)
        // 2. 도메인 객체 생성
        // 3. 저장
        // 4. Response DTO 변환 후 반환
    }
}
```

### 4.3 Cross-slice Read DTO

```java
package com.honbap.{slice}.application;

public record {Name}Info(UUID id, String name /* 노출할 필드만 */) {
    public static {Name}Info from({Name} entity) {
        return new {Name}Info(entity.getId(), entity.getName());
    }
}
```

### 4.4 엔티티

```java
package com.honbap.{slice}.domain;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class {Name} extends BaseEntity {
    @Id @GeneratedValue
    private UUID id;

    // setter 금지. 상태 변경은 의도적인 도메인 메서드로만 노출.
    // 정적 팩토리 메서드로 생성: public static {Name} create(...)
}
```

### 4.5 Repository

```java
package com.honbap.{slice}.infra;

public interface {Name}Repository extends JpaRepository<{Name}, UUID> {
    // 쿼리 메서드. 반환 타입은 엔티티 OK (같은 슬라이스 내부이므로).
}
```

---

## 5. ANTI-PATTERNS (절대 금지)

```java
// ❌ AP-1: 다른 슬라이스의 Repository 직접 호출 (RULE-2 위반)
class SessionService {
    private final RestaurantRepository restaurantRepo;  // 금지
}
// → RestaurantService를 주입받고 findById() 호출

// ❌ AP-2: 다른 슬라이스에 엔티티 반환 (RULE-3 위반)
class RestaurantService {
    public Restaurant findById(UUID id) { ... }  // 금지
}
// → RestaurantInfo (record) 반환

// ❌ AP-3: 컨트롤러에서 Repository 직접 호출 (RULE-1 위반)
class SessionController {
    private final SessionRepository repo;  // 금지
}
// → 항상 Service 경유

// ❌ AP-4: 도메인이 인프라를 import (RULE-1 위반)
// session/domain/Session.java
import com.honbap.session.infra.SessionRepository;  // 금지

// ❌ AP-5: 슬라이스 간 양방향 의존 (RULE-7 위반)
// session → user 호출이 있으면 user → session 호출 금지

// ❌ AP-6: shared/에 도메인 로직 두기 (RULE-5 위반)
// shared/는 횡단 관심사만. 비즈니스 규칙은 슬라이스 안에.

// ❌ AP-7: 엔티티에 setter (RULE-3 보강)
@Entity
class Session {
    @Setter private Status status;  // 금지
}
// → public void cancel() 같은 의도적 메서드로 노출
```

---

## 6. 폴더 구조 (현재)

```
backend/src/main/java/com/honbap/
├── auth/
│   ├── api/         AuthController, dto/{LoginRequest, TokenResponse, RefreshRequest}
│   ├── application/ AuthService, JwtProvider
│   ├── domain/      RefreshToken
│   └── infra/       RefreshTokenRepository, KakaoTokenVerifier
├── restaurant/
│   ├── api/         RestaurantController, dto/{NearbyRestaurantQuery, RestaurantResponse, CreateRestaurantRequest}
│   ├── application/ RestaurantService, RestaurantInfo
│   ├── domain/      Restaurant
│   └── infra/       RestaurantRepository, KakaoLocalApiClient
├── session/
│   ├── api/         SessionController, dto/{CheckInRequest, SessionResponse, SessionHistoryResponse}
│   ├── application/ SessionService, GpsValidator, AutoExpireScheduler
│   ├── domain/      Session
│   └── infra/       SessionRepository, FcmClient
├── user/
│   ├── api/         UserController, dto/{UserProfileResponse, UpdateProfileRequest, UserStatsResponse}
│   ├── application/ UserService, UserStatsService, UserInfo
│   ├── domain/      User
│   └── infra/       UserRepository
└── shared/
    ├── domain/      BaseEntity
    ├── security/    SecurityConfig, JwtAuthenticationFilter
    ├── exception/   GlobalExceptionHandler, BusinessException
    ├── web/         ApiResponse
    └── config/      (Beans, properties 매핑)
```

---

## 7. 기술 스택 매핑

| 기술 | 위치 |
|---|---|
| `@RestController` | `{slice}/api/` |
| `@Valid` 검증 | `{slice}/api/dto/` |
| `@Service` | `{slice}/application/` |
| `@Scheduled` | 사용처 슬라이스의 `application/` |
| Spring Data JPA, Hibernate | `{slice}/infra/` |
| Flyway 마이그레이션 | `src/main/resources/db/migration/` |
| Spring Security 전역 필터 | `shared/security/` |
| JJWT 발급 | `auth/application/JwtProvider` |
| RestTemplate / WebClient | 사용처 슬라이스의 `infra/` |
| `@RestControllerAdvice` 전역 예외 | `shared/exception/` |

---

## 8. 확장 가이드

새 기능은 **새 슬라이스로 추가**한다. 기존 슬라이스를 수정하지 않는 것이 원칙. 다른 슬라이스 데이터가 필요하면 그 슬라이스의 Service 호출 (RULE-2).

### Phase 2 후보 슬라이스
- `vote/` — 식당 혼밥 친화도 투표
- `streak/` — 연속 혼밥 일수, 뱃지
- `history/` — `session/`에 흡수 가능 (먼저 검토)

### Phase 3 후보 슬라이스
- `score/` — Honbap Score 계산
- `heatmap/` — 시간대 혼밥 빈도 집계
- `owner/` — B2B 사장님 대시보드

트래픽이 늘면 `session/` 또는 `score/`를 별도 마이크로서비스로 분리 가능 (현 구조의 가장 큰 보상).

---

## 9. 명명 규칙

- 슬라이스 이름: 단수형 (`session`, not `sessions`)
- 패키지명: 소문자 (`com.honbap.session.application`)
- 레이어 폴더: `api | application | domain | infra` 4종으로 통일
- DTO 위치
  - HTTP 요청·응답: `{slice}/api/dto/`
  - 슬라이스 간 Read DTO: `{slice}/application/{Name}Info.java` (record)
- 클래스 suffix
  - 컨트롤러: `*Controller`
  - 서비스: `*Service`
  - 리포지토리: `*Repository`
  - 외부 클라이언트: `*Client` 또는 `*Verifier`
  - 스케줄러: `*Scheduler`
  - Read DTO: `*Info`
  - 요청 DTO: `*Request`, 응답 DTO: `*Response`

---

## 10. 알려진 트레이드오프 / 재검토 시점

1. **`shared/` 비대화 위험** — RULE-5(Rule of Three)로 방지. PR 리뷰 시 `shared/` 신규 추가는 사용처 2곳 이상 명시 필수.
2. **Read DTO 변환 보일러플레이트** — record + 정적 팩토리(`from()`)로 완화. MapStruct 등 자동 변환 라이브러리는 도입하지 않음 (명시성 우선).
3. **슬라이스 자율성 vs 일관성** — 도메인 로직이 극단적으로 단순한 슬라이스는 `application`/`domain` 통합 허용. 단, `infra`와 `api`는 항상 분리.
4. **트랜잭션 경계** — RULE-6 위반 시 nested transaction 문제 발생. 새 Service 메서드 작성 시 호출 그래프 확인 필수.
5. **양방향 의존이 필요해질 때** — 단방향으로 풀 수 없으면 도메인 이벤트(Spring `ApplicationEventPublisher`) 도입을 검토. 현재는 보류.

---

## 11. AI 에이전트 작업 시 체크리스트

코드 생성/수정 전에 확인할 것:

- [ ] 어느 슬라이스에 속하는 작업인가? (1.1 결정 트리)
- [ ] 새 파일이라면 § 1.2 룩업 테이블에서 위치 확인
- [ ] 다른 슬라이스 데이터가 필요하면 RULE-2를 따라 Service만 주입
- [ ] 슬라이스 간 데이터 전달은 RULE-3에 따라 Read DTO 사용
- [ ] 새 Service 메서드는 § 4.2 템플릿 따르기 + RULE-6 트랜잭션 확인
- [ ] § 5의 anti-pattern을 만들지 않았는지 재확인
- [ ] `shared/`에 추가하려 한다면 사용처가 2곳 이상인지 확인 (RULE-5)
