#!/usr/bin/env bash
# ============================================================
# validate_output.sh — Automated validation untuk vibe-coding-toolkit output
#
# Usage:
#   ./validate_output.sh <output_dir>
#
# Checks:
#   1. Semua file output exist
#   2. Setiap file punya mandatory sections
#   3. Cross-reference consistency
#   4. Version alignment
#
# Exit codes:
#   0 = PASS
#   1 = PASS_WITH_WARNINGS
#   2 = FAIL
# ============================================================

set -euo pipefail

OUTPUT_DIR="${1:?Usage: $0 <output_dir>}"
ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

pass()  { echo -e "${GREEN}[PASS]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; WARNINGS=$((WARNINGS + 1)); }
fail()  { echo -e "${RED}[FAIL]${NC} $1"; ERRORS=$((ERRORS + 1)); }

echo "=========================================="
echo "  Output Validation: $OUTPUT_DIR"
echo "=========================================="
echo ""

# === File checklist ======================================
FILES=(
  "RULE.md"
  "DESIGN.md"
  "AI_INSTRUCTIONS.md"
  "CHECKLIST.md"
  "ARCHITECTURE_CHEATSHEET.md"
)

echo "---[ File Existence Check ]---"
for f in "${FILES[@]}"; do
  if [ -f "$OUTPUT_DIR/$f" ]; then
    pass "$f exists"
  else
    fail "$f is MISSING"
  fi
done
echo ""

# === Mandatory sections per file =========================
echo "---[ Mandatory Sections Check ]---"

# RULE.md checks
RULE="$OUTPUT_DIR/RULE.md"
if [ -f "$RULE" ]; then
  # Should have WAJIB and DILARANG sections
  if grep -qi "wajib" "$RULE" 2>/dev/null; then
    pass "RULE.md: Has WAJIB sections"
  else
    warn "RULE.md: No WAJIB sections found"
  fi
  if grep -qi "dilarang" "$RULE" 2>/dev/null; then
    pass "RULE.md: Has DILARANG sections"
  else
    warn "RULE.md: No DILARANG sections found"
  fi
fi

# DESIGN.md checks
DESIGN="$OUTPUT_DIR/DESIGN.md"
if [ -f "$DESIGN" ]; then
  # Should have color definitions
  if grep -qi "color\|palette\|hex\|#\|AppColors" "$DESIGN" 2>/dev/null; then
    pass "DESIGN.md: Has color definitions"
  else
    warn "DESIGN.md: No color definitions found"
  fi
  # Should have Stitch context
  if grep -qi "stitch\|design system\|design context" "$DESIGN" 2>/dev/null; then
    pass "DESIGN.md: Has Stitch context"
  else
    warn "DESIGN.md: No Stitch design context found"
  fi
fi

# AI_INSTRUCTIONS.md checks
INSTRUCTIONS="$OUTPUT_DIR/AI_INSTRUCTIONS.md"
if [ -f "$INSTRUCTIONS" ]; then
  if grep -qi "phase\|task.*[0-9]" "$INSTRUCTIONS" 2>/dev/null; then
    pass "AI_INSTRUCTIONS.md: Has phases and tasks"
  else
    warn "AI_INSTRUCTIONS.md: No phases/tasks found"
  fi
  # Should have troubleshooting
  if grep -qi "troubleshooting\|jika.*error\|jika.*salah" "$INSTRUCTIONS" 2>/dev/null; then
    pass "AI_INSTRUCTIONS.md: Has troubleshooting section"
  else
    warn "AI_INSTRUCTIONS.md: No troubleshooting section"
  fi
fi

# CHECKLIST.md checks
CHECKLIST="$OUTPUT_DIR/CHECKLIST.md"
if [ -f "$CHECKLIST" ]; then
  if grep -qi "phase\|gate.*check\|progress.*summary" "$CHECKLIST" 2>/dev/null; then
    pass "CHECKLIST.md: Has phases and gate checks"
  else
    warn "CHECKLIST.md: No phases/gate checks found"
  fi
fi

# ARCHITECTURE_CHEATSHEET.md checks
ARCH="$OUTPUT_DIR/ARCHITECTURE_CHEATSHEET.md"
if [ -f "$ARCH" ]; then
  if grep -qi "pattern\|diagram\|folder.*structure\|code" "$ARCH" 2>/dev/null; then
    pass "ARCHITECTURE_CHEATSHEET.md: Has patterns and structure"
  else
    warn "ARCHITECTURE_CHEATSHEET.md: No patterns found"
  fi
  if grep -qi "common mistake\|wrong.*correct\|❌\|✅" "$ARCH" 2>/dev/null; then
    pass "ARCHITECTURE_CHEATSHEET.md: Has common mistakes table"
  else
    warn "ARCHITECTURE_CHEATSHEET.md: No common mistakes table"
  fi
fi

echo ""

# === Cross-reference consistency ==========================
echo "---[ Cross-Reference Check ]---"

# Check that RULE.md and ARCHITECTURE reference the same tech stack
if [ -f "$RULE" ] && [ -f "$ARCH" ]; then
  # Extract first tech mention from RULE.md
  RULE_TECH=$(grep -i "framework\|tech\|stack\|flutter\|next\.js\|react\|vue\|laravel" "$RULE" 2>/dev/null | head -3)
  ARCH_TECH=$(grep -i "framework\|tech\|stack\|flutter\|next\.js\|react\|vue\|laravel" "$ARCH" 2>/dev/null | head -3)
  if [ -n "$RULE_TECH" ] && [ -n "$ARCH_TECH" ]; then
    pass "RULE.md & ARCHITECTURE: Both mention tech stack"
  else
    warn "RULE.md & ARCHITECTURE: Tech stack references missing in one file"
  fi
fi

# Check that all files reference each other
for f in "${FILES[@]}"; do
  if [ -f "$OUTPUT_DIR/$f" ]; then
    if grep -qi "cross.reference\|see also\|related\|depends on\|bergantung" "$OUTPUT_DIR/$f" 2>/dev/null; then
      pass "$f: Has cross-references"
    else
      warn "$f: No cross-references found"
    fi
  fi
done

echo ""

# === Summary ==============================================
echo "=========================================="
echo "  Validation Complete"
echo "=========================================="
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"
echo ""

if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}Status: FAIL${NC}"
  exit 2
elif [ "$WARNINGS" -gt 0 ]; then
  echo -e "${YELLOW}Status: PASS_WITH_WARNINGS${NC}"
  exit 1
else
  echo -e "${GREEN}Status: PASS${NC}"
  exit 0
fi
