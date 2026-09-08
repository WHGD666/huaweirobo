#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
ENV_NAME="${JUESAI_ENV_NAME:-lerobot061}"
MINIFORGE_DIR="${MINIFORGE_DIR:-$HOME/miniforge3}"
EXTERNAL_ROOT="${JUESAI_EXTERNAL_ROOT:-$HOME/juesai.external}"
A1Z_COMMIT="e931ecd0e25ad35df251097ba42921b3d2fa7224"
TELEOP_COMMIT="c3275a32951a52f4a7d9e7d9976eb687652526ba"
FAILURES=0
WARNINGS=0

pass() { printf '[PASS] %s\n' "$*"; }
warn() { WARNINGS=$((WARNINGS + 1)); printf '[WARN] %s\n' "$*"; }
fail() { FAILURES=$((FAILURES + 1)); printf '[FAIL] %s\n' "$*"; }
manual() { WARNINGS=$((WARNINGS + 1)); printf '[MANUAL STEP REQUIRED] %s\n' "$*"; }

if [[ "${1:-}" == --report ]]; then
  [[ -n "${2:-}" ]] || { printf -- '--report 需要路径\n' >&2; exit 2; }
  mkdir -p "$(dirname -- "$2")"
  exec > >(tee "$2") 2>&1
  shift 2
fi
[[ "$#" -eq 0 ]] || { printf '用法: bash scripts/verify_env.sh [--report PATH]\n' >&2; exit 2; }

printf '=== juesai Phase 1 environment verification ===\n'
printf 'time: %s\n' "$(date -Is)"
printf 'project: %s\n' "$PROJECT_DIR"

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == ubuntu ]] && pass "OS Ubuntu ${VERSION_ID}" || fail "OS is not Ubuntu: ${ID:-unknown}"
  [[ "${VERSION_ID:-}" == 22.04 || "${VERSION_ID:-}" == 24.04 ]] && pass "Ubuntu version supported: ${VERSION_ID}" || fail "unsupported Ubuntu version: ${VERSION_ID:-unknown}"
else
  fail 'cannot read /etc/os-release'
fi

pass "kernel: $(uname -r)"
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader && pass 'nvidia-smi query succeeded' || warn 'nvidia-smi exists but query failed'
else
  warn 'nvidia-smi unavailable; GPU status is not verified'
fi

if command -v conda >/dev/null 2>&1; then
  CONDA_BIN="$(command -v conda)"
elif [[ -x "$MINIFORGE_DIR/bin/conda" ]]; then
  CONDA_BIN="$MINIFORGE_DIR/bin/conda"
else
  fail 'conda/Miniforge not found'
  CONDA_BIN=''
fi

ENV_READY=0
if [[ -n "$CONDA_BIN" ]]; then
  CONDA_BASE="$($CONDA_BIN info --base 2>/dev/null || true)"
  if [[ -n "$CONDA_BASE" && -f "$CONDA_BASE/etc/profile.d/conda.sh" ]]; then
    # shellcheck disable=SC1090
    source "$CONDA_BASE/etc/profile.d/conda.sh"
  fi
  if conda env list | awk '{print $1}' | grep -Fxq "$ENV_NAME"; then
    pass "conda env exists: $ENV_NAME"
    py_version="$(conda run --no-capture-output -n "$ENV_NAME" python --version 2>&1 || true)"
    [[ "$py_version" == Python\ 3.12.* ]] && pass "environment Python: $py_version" || fail "environment Python is not 3.12: $py_version"
    ENV_READY=1
  else
    fail "conda env missing: $ENV_NAME"
  fi
fi

run_env() { conda run --no-capture-output -n "$ENV_NAME" "$@"; }
if (( ENV_READY == 1 )); then
  lerobot_version="$(run_env python -c 'import importlib.metadata as m; print(m.version("lerobot"))' 2>&1 || true)"
  [[ "$lerobot_version" == 0.6.1 ]] && pass "LeRobot version: $lerobot_version" || fail "LeRobot version mismatch: $lerobot_version"
  run_env ffmpeg -version >/dev/null 2>&1 && pass 'ffmpeg available in environment' || fail 'ffmpeg unavailable in environment'
  for module in lerobot a1z fashionstar_uart_sdk; do
    if run_env python -c "import $module" >/dev/null 2>&1; then pass "Python import: $module"; else warn "Python import unavailable: $module"; fi
  done
  if run_env python -c 'import r2c_sdk' >/dev/null 2>&1; then
    pass 'Python import: r2c_sdk'
  else
    manual 'r2c_sdk 未安装；从 CloudRobo 控制台获取官方包，设置 R2C_SDK_PATH 后重新运行 bootstrap.sh。'
  fi
fi

check_repo() {
  local label="$1" dir="$2" expected="$3"
  if [[ ! -d "$dir/.git" ]]; then warn "$label checkout missing: $dir"; return; fi
  local actual
  actual="$(git -C "$dir" rev-parse HEAD 2>/dev/null || true)"
  [[ "$actual" == "$expected" ]] && pass "$label commit: $actual" || fail "$label commit mismatch: $actual (expected $expected)"
}
check_repo 'GALAXEA-A1Z' "$EXTERNAL_ROOT/GALAXEA-A1Z" "$A1Z_COMMIT"
check_repo 'a1z-teleop' "$EXTERNAL_ROOT/a1z-teleop" "$TELEOP_COMMIT"

if (( ENV_READY == 1 )) && [[ -f "$EXTERNAL_ROOT/a1z-teleop/scripts/verify_install.py" ]]; then
  if run_env python "$EXTERNAL_ROOT/a1z-teleop/scripts/verify_install.py"; then
    pass 'a1z-teleop official software verification script'
  else
    fail 'a1z-teleop official software verification script failed'
  fi
else
  warn 'a1z-teleop verify_install.py unavailable; software plugin registration not checked'
fi

warn 'hardware checks intentionally skipped: no CAN init, scan, robot connect, calibration, camera, teleop or data collection was executed'
printf '=== result: %d failure(s), %d warning(s) ===\n' "$FAILURES" "$WARNINGS"
(( FAILURES == 0 ))
