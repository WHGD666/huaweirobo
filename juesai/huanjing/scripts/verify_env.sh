#!/usr/bin/env bash
set -euo pipefail

# Read-only verification for the A1Z software environment. No hardware,
# network, package manager, or source checkout operation is performed here.

readonly ENV_NAME="${JUESAI_ENV_NAME:-lerobot061}"
readonly MINIFORGE_DIR="${MINIFORGE_DIR:-$HOME/miniforge3}"
readonly WORKSPACE="${A1Z_WORKSPACE:-$HOME/a1z-workspace}"
readonly MIN_KERNEL="6.8.0-124"

failures=0
manual_steps=0

pass() { printf '[PASS] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
fail() { failures=$((failures + 1)); printf '[FAIL] %s\n' "$*"; }
skip() { printf '[SKIP] %s\n' "$*"; }
manual() { manual_steps=$((manual_steps + 1)); printf '[MANUAL STEP REQUIRED] %s\n' "$*"; }

version_ge() {
  [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" == "$1" ]]
}

run_env() {
  conda run --no-capture-output -n "$ENV_NAME" "$@"
}

check_os() {
  if [[ ! -r /etc/os-release ]]; then
    fail '无法读取 /etc/os-release'
    return
  fi
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == ubuntu ]] && pass "Ubuntu ${VERSION_ID}" || fail "OS is not Ubuntu: ${ID:-unknown}"
  case "${VERSION_ID:-}" in
    22.04|24.04) pass "Ubuntu version supported: ${VERSION_ID}" ;;
    *) fail "unsupported Ubuntu version: ${VERSION_ID:-unknown}" ;;
  esac
}

check_kernel() {
  local current
  current="$(uname -r)"
  if version_ge "$MIN_KERNEL" "$current"; then
    pass "kernel $current meets >= $MIN_KERNEL"
  else
    fail "kernel $current is below >= $MIN_KERNEL"
  fi
}

find_conda() {
  if [[ -x "$MINIFORGE_DIR/bin/conda" ]]; then
    printf '%s\n' "$MINIFORGE_DIR/bin/conda"
  elif command -v conda >/dev/null 2>&1; then
    command -v conda
  else
    printf '%s\n' ''
  fi
}

check_conda_and_environment() {
  local conda_bin="$1"
  if [[ -z "$conda_bin" ]]; then
    fail 'Miniforge/conda not found'
    return 1
  fi
  pass "conda executable: $conda_bin"
  local base
  base="$($conda_bin info --base 2>/dev/null || true)"
  [[ -n "$base" ]] && pass "conda base: $base" || fail 'conda info --base failed'
  if [[ -z "$base" || ! -f "$base/etc/profile.d/conda.sh" ]]; then
    fail 'conda shell integration not found'
    return 1
  fi
  # shellcheck disable=SC1090
  source "$base/etc/profile.d/conda.sh"
  if conda env list | awk '{print $1}' | grep -Fxq "$ENV_NAME"; then
    pass "conda environment exists: $ENV_NAME"
  else
    fail "conda environment missing: $ENV_NAME"
    return 1
  fi
  local python_version
  python_version="$(run_env python --version 2>&1 || true)"
  [[ "$python_version" == Python\ 3.12.* ]] && pass "environment Python: $python_version" || fail "environment Python is not 3.12: $python_version"
  return 0
}

check_python_packages() {
  local lerobot_version
  lerobot_version="$(run_env python -c 'import importlib.metadata as m; print(m.version("lerobot"))' 2>&1 || true)"
  [[ "$lerobot_version" == 0.6.1 ]] && pass "LeRobot version: $lerobot_version" || fail "LeRobot version mismatch: $lerobot_version"
  if run_env ffmpeg -version >/dev/null 2>&1; then pass 'ffmpeg available'; else fail 'ffmpeg unavailable'; fi
  if run_env python -c 'import lerobot' >/dev/null 2>&1; then pass 'import lerobot'; else fail 'import lerobot failed'; fi
  if run_env python -c 'import a1z' >/dev/null 2>&1; then pass 'import a1z'; else fail 'import a1z failed'; fi
}

check_git_repo() {
  local label="$1" directory="$2" expected_branch="$3"
  if [[ ! -d "$directory/.git" ]]; then
    fail "$label checkout missing: $directory"
    return 1
  fi
  local branch sha
  branch="$(git -C "$directory" branch --show-current)"
  sha="$(git -C "$directory" rev-parse HEAD)"
  [[ "$branch" == "$expected_branch" ]] && pass "$label branch: $branch" || fail "$label branch '$branch', expected '$expected_branch'"
  [[ "$sha" =~ ^[0-9a-f]{40}$ ]] && pass "$label commit SHA: $sha" || fail "$label commit SHA is invalid: $sha"
  return 0
}

check_plugin_registration() {
  local result
  result="$(run_env python -c '
from lerobot.utils.import_utils import register_third_party_plugins
from lerobot.teleoperators.config import TeleoperatorConfig
from lerobot.robots.config import RobotConfig
import lerobot_teleoperator_stararm102
import lerobot_robot_galaxea_a1z
register_third_party_plugins()
assert "stararm102_leader" in TeleoperatorConfig.get_known_choices()
assert "galaxea_a1z_follower" in RobotConfig.get_known_choices()
print("stararm102_leader, galaxea_a1z_follower")
' 2>&1 || true)"
  if [[ "$result" == *stararm102_leader* && "$result" == *galaxea_a1z_follower* ]]; then
    pass "plugin registration: $result"
  else
    fail "plugin registration failed: $result"
  fi
  local official_verify official_status=0
  if [[ -f "$WORKSPACE/a1z-teleop/scripts/verify_install.py" ]]; then
    official_verify="$(cd "$WORKSPACE/a1z-teleop" && run_env python scripts/verify_install.py 2>&1)" || official_status=$?
    if (( official_status == 0 )); then
      pass 'a1z-teleop official verify_install.py passed'
    else
      fail "a1z-teleop official verify_install.py failed: $official_verify"
    fi
  else
    fail 'a1z-teleop verify_install.py missing'
  fi
}

check_r2c() {
  local report
  report="$(run_env python -c 'import r2c_sdk; from r2c_sdk import ClientConfig, SyncRobotClient; print("version=" + getattr(r2c_sdk, "__version__", "unknown")); print("r2c_sdk_api_ok")' 2>&1 || true)"
  if [[ "$report" == *No\ module\ named* ]]; then
    manual 'r2c_sdk 未安装或不可导入；从 CloudRobo 控制台下载最新官方包并通过 R2C_SDK_PATH 安装'
  elif [[ "$report" == *r2c_sdk_api_ok* ]]; then
    pass "r2c_sdk import/version/API: $report"
  else
    fail "r2c_sdk API verification failed: $report"
  fi
}

check_torch() {
  local report
  report="$(run_env python -c 'import torch; print(torch.__version__); print(torch.version.cuda)' 2>&1 || true)"
  if [[ -n "$report" && "$report" != *No\ module\ named* ]]; then
    pass "Torch import/version/CUDA build: $report"
    if run_env python -c 'import torch; raise SystemExit(0 if torch.cuda.is_available() else 1)' >/dev/null 2>&1; then
      pass 'Torch CUDA runtime available'
    else
      skip 'GPU/CUDA runtime unavailable in VMware VM; no Torch/CUDA change is attempted'
    fi
  else
    fail "Torch import failed: $report"
  fi
}

main() {
  printf '=== juesai A1Z read-only environment verification ===\n'
  printf 'time: %s\n' "$(date -Is)"
  check_os
  check_kernel
  local conda_bin
  conda_bin="$(find_conda)"
  if check_conda_and_environment "$conda_bin"; then
    check_python_packages
    check_plugin_registration
    check_r2c
    check_torch
  else
    skip 'Python packages, plugins, r2c_sdk and Torch checks skipped because lerobot061 is unavailable'
  fi

  check_git_repo 'GALAXEA-A1Z' "$WORKSPACE/GALAXEA-A1Z" gripper || true
  check_git_repo 'a1z-teleop' "$WORKSPACE/a1z-teleop" main || true
  skip 'CAN/SocketCAN/gs_usb checks skipped: no hardware command is executed'
  skip 'A1Z/gripper checks skipped: no robot connection or motion is executed'
  skip 'Star-Arm checks skipped: no UART or real hardware command is executed'
  skip 'Camera checks skipped: no camera enumeration is executed'
  printf '=== result: %d failure(s), %d manual step(s) ===\n' "$failures" "$manual_steps"
  (( failures == 0 ))
}

main "$@"
