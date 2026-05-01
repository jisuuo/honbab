#!/usr/bin/env bash
# HONBAP 레포 라벨 시드 스크립트
# 사용법:   bash scripts/seed-labels.sh
# 사전조건: gh CLI 설치 + gh auth login 완료
#          현재 디렉토리가 honbab 레포 루트
#
# 라벨이 이미 있으면 색/설명만 업데이트(idempotent).

set -euo pipefail

REPO="${REPO:-jisuuo/honbab}"

# === 라벨 정의: name|color(hex no #)|description ===
labels=(
  # ── 영역 (Area) ────────────────────────────────
  "area: backend|1f6feb|Spring/Java/DB"
  "area: frontend|2da44e|React Native/UI"
  "area: infra|d97706|AWS/CI/배포/모니터링"
  "area: docs|8b949e|문서/README/주석"

  # ── 타입 (Type) ────────────────────────────────
  "type: feature|a371f7|새 기능 / 사용자 가치"
  "type: bug|d1242f|동작 이상 / 회귀"
  "type: chore|6e7681|빌드 / 설정 / 잡일"
  "type: refactor|fbca04|동작 변화 없는 구조 개선"
  "type: test|0e8a16|테스트 추가 / 수정"

  # ── 사이즈 (Size) ──────────────────────────────
  "size: S|c2e0c6|반나절 이내"
  "size: M|7fbf7f|1일 내외"
  "size: L|2da44e|2일 이상 — 더 쪼갤 수 있는지 검토"

  # ── 시점 (Sprint) ──────────────────────────────
  "mvp: week1|f9d0c4|MVP 1주차"
  "mvp: week2|f9a8a8|MVP 2주차"
  "phase: 2|fdb462|Phase 2 (안정화)"
  "phase: 3|fbb4ae|Phase 3 (수익화)"

  # ── 상태 / 메타 ────────────────────────────────
  "blocked|d1242f|선행 작업 필요"
  "needs-design|fbca04|설계/ADR 먼저 필요"
  "good first issue|7057ff|작게 시작하기 좋음"
  "discussion|cccccc|토론 / 탐색"
)

echo "=== HONBAP 라벨 시드 → $REPO ==="
echo ""

created=0
updated=0
failed=0

for entry in "${labels[@]}"; do
  IFS='|' read -r name color desc <<< "$entry"
  if gh label create "$name" --color "$color" --description "$desc" --repo "$REPO" >/dev/null 2>&1; then
    echo "✓ 생성  $name"
    ((created++))
  elif gh label edit "$name" --color "$color" --description "$desc" --repo "$REPO" >/dev/null 2>&1; then
    echo "↻ 갱신  $name"
    ((updated++))
  else
    echo "✗ 실패  $name"
    ((failed++))
  fi
done

echo ""
echo "─────────────────────────────"
echo "✅ 생성 $created개  ↻ 갱신 $updated개  ✗ 실패 $failed개"
echo ""
echo "확인: https://github.com/$REPO/labels"
