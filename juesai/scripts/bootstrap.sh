#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
ENV_NAME="${JUESAI_ENV_NAME:-lerobot061}"
MINIFORGE_DIR="${MINIFORGE_DIR:-$HOME/miniforge3}"
EXTERNAL_ROOT="${JUESAI_EXTERNAL_ROOT:-$HOME/juesai.external}"
MINIFORGE_VERSION="26.5.3-0"
MINIFORGE_URL="${MINIFORGE_URL:-https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-x86_64.sh}"
MINIFORGE_SHA256="${MINIFORGE_SHA256:-14db468222ad564658656f769506056209b6dc375f5e7dfd31eb5ebbf08fa529}"
A1Z_URL="https://github.com/userguide-galaxea/GALAXEA-A1Z.git"
A1Z_BRANCH="gripper"
A1Z_COMMIT="e931ecd0e25ad35df251097ba42921b3d2fa7224"
TELEOP_URL="https://github.com/suhanwu/a1z-teleop.git"
TELEOP_BRANCH="main"
TELEOP_COMMIT="c3275a32951a52f4a7d9e7d9976eb687652526ba"
MANUAL_STEP_REQUIRED=0

log() { printf '[bootstrap] %s\n' "$*"; }
manual() { MANUAL_STEP_REQUIRED=1; printf '[MANUAL STEP REQUIRED] %s\n' "$*"; }
die() { printf '[FAIL] %s\n' "$*" >&2; exit 1; }

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "缺少基础命令: $1"
}

check_host() {
  [[ -r /etc/os-release ]] || die '无法读取 /etc/os-release'
  # shellcheck disable=SC1091
  source /etc/os-release
  case "${ID:-}" in
    ubuntu) ;;
    *) die "仅支持 Ubuntu，当前为 ${ID:-unknown}" ;;
  esac
  case "${VERSION_ID:-}" in
    22.04|24.04) ;;
    *) die "A1Z 官方页面支持 Ubuntu 22.04/24.04，当前为 ${VERSION_ID:-unknown}" ;;
  esac
  local kernel_release kernel_version kernel_major kernel_minor
  kernel_release="$(uname -r)"
  kernel_version="${kernel_release%%-*}"
  IFS=. read -r kernel_major kernel_minor _ <<< "$kernel_version"
  kernel_major="${kernel_major:-0}"
  kernel_minor="${kernel_minor:-0}"
  log "host: Ubuntu ${VERSION_ID}, kernel ${kernel_release}, system Python $(python3 --version 2>&1 || true)"
  if (( kernel_major < 6 || (kernel_major == 6 && kernel_minor < 8) )); then
    log 'WARN: kernel is below the official 6.8 SocketCAN baseline; software bootstrap may continue, but real A1Z CAN use requires kernel confirmation/upgrades'
  fi
  if [[ "$kernel_release" != *-azure* && "$kernel_release" != *-generic* ]]; then
    log "WARN: 当前内核后缀不是常见 Ubuntu generic/azure，真机 SocketCAN 需另行确认"
  fi
  local free_kb free_gb
  free_kb="$(df -Pk "$HOME" | awk 'NR==2 {print $4}')"
  free_gb=$((free_kb / 1024 / 1024))
  log "disk free under HOME: ${free_gb} GiB"
  (( free_gb >= 5 )) || die 'HOME 可用磁盘少于 5 GiB，停止安装以避免半成品环境'
  if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader || log 'WARN: nvidia-smi 查询失败，将由后续验证报告'
  else
    log 'WARN: 未发现 nvidia-smi；本阶段不根据猜测选择 CUDA/Torch 版本'
  fi
}

ensure_miniforge() {
  if [[ -x "$MINIFORGE_DIR/bin/conda" ]]; then
    log "reuse Miniforge: $MINIFORGE_DIR"
    return
  fi
  mkdir -p "$EXTERNAL_ROOT/downloads"
  local installer="$EXTERNAL_ROOT/downloads/Miniforge3-${MINIFORGE_VERSION}-Linux-x86_64.sh"
  if [[ ! -f "$installer" ]]; then
    log "download Miniforge ${MINIFORGE_VERSION}"
    if command -v curl >/dev/null 2>&1; then
      curl -fL --retry 3 --output "$installer" "$MINIFORGE_URL"
    else
      wget -O "$installer" "$MINIFORGE_URL"
    fi
  fi
  printf '%s  %s\n' "$MINIFORGE_SHA256" "$installer" | sha256sum -c - || die 'Miniforge SHA256 校验失败'
  [[ ! -e "$MINIFORGE_DIR" ]] || die "Miniforge 目标已存在但不可用: $MINIFORGE_DIR"
  bash "$installer" -b -p "$MINIFORGE_DIR"
}

prepare_repo() {
  local url="$1" branch="$2" commit="$3" dest="$4"
  if [[ -e "$dest" && ! -d "$dest/.git" ]]; then
    die "外部目标存在但不是 Git 仓库: $dest"
  fi
  if [[ -d "$dest/.git" ]]; then
    [[ -z "$(git -C "$dest" status --porcelain)" ]] || die "外部仓库有未提交修改，未覆盖: $dest"
    git -C "$dest" fetch --quiet origin "$branch"
  else
    mkdir -p "$(dirname -- "$dest")"
    git clone --quiet --branch "$branch" "$url" "$dest"
  fi
  git -C "$dest" checkout --quiet --detach "$commit"
  [[ "$(git -C "$dest" rev-parse HEAD)" == "$commit" ]] || die "外部仓库 commit 校验失败: $dest"
  log "source ready: $dest @ $commit"
}

main() {
  cd "$PROJECT_DIR"
  for cmd in git sha256sum tar awk sed df uname python3; do require_command "$cmd"; done
  require_command bash
  command -v curl >/dev/null 2>&1 || require_command wget
  check_host
  mkdir -p "$EXTERNAL_ROOT"
  ensure_miniforge

  # shellcheck disable=SC1091
  source "$MINIFORGE_DIR/etc/profile.d/conda.sh"
  if conda env list | awk '{print $1}' | grep -Fxq "$ENV_NAME"; then
    local py_version
    py_version="$(conda run --no-capture-output -n "$ENV_NAME" python --version 2>&1)"
    [[ "$py_version" == Python\ 3.12.* ]] || die "$ENV_NAME 已存在但不是 Python 3.12: $py_version"
    log "reuse conda env $ENV_NAME ($py_version)"
  else
    conda create -y -n "$ENV_NAME" python=3.12
  fi
  conda install -y -n "$ENV_NAME" -c conda-forge ffmpeg
  conda activate "$ENV_NAME"
  python -m pip install --upgrade "lerobot==0.6.1"

  local a1z_dir="$EXTERNAL_ROOT/GALAXEA-A1Z"
  local teleop_dir="$EXTERNAL_ROOT/a1z-teleop"
  prepare_repo "$A1Z_URL" "$A1Z_BRANCH" "$A1Z_COMMIT" "$a1z_dir"
  prepare_repo "$TELEOP_URL" "$TELEOP_BRANCH" "$TELEOP_COMMIT" "$teleop_dir"
  log 'invoke a1z-teleop official setup.sh (software packages only)'
  A1Z_SDK="$a1z_dir" bash "$teleop_dir/setup.sh"

  if [[ -n "${R2C_SDK_PATH:-}" ]]; then
    [[ -d "$R2C_SDK_PATH" ]] || die "R2C_SDK_PATH 不是目录: $R2C_SDK_PATH"
    [[ -f "$R2C_SDK_PATH/pyproject.toml" || -f "$R2C_SDK_PATH/setup.py" ]] || die 'R2C_SDK_PATH 缺少 pyproject.toml/setup.py'
    python -m pip install -e "$R2C_SDK_PATH"
    log "r2c SDK installed from user-provided official package: $R2C_SDK_PATH"
  else
    manual '请从 CloudRobo 控制台下载官方 r2c_sdk 包并解压，然后设置 R2C_SDK_PATH 后重新运行 bootstrap.sh。脚本不猜测下载 URL。'
  fi

  log 'software bootstrap finished'
  (( MANUAL_STEP_REQUIRED == 0 )) || log 'bootstrap completed with manual steps pending'
}

main "$@"
