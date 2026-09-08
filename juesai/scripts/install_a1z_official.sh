#!/usr/bin/env bash
set -euo pipefail

# Future Ubuntu VM installer. This file is intentionally not executed on the
# local Windows host. Commands and versions are documented in docs/SOURCES.md.

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
readonly ENV_NAME="${JUESAI_ENV_NAME:-lerobot061}"
readonly MINIFORGE_DIR="${MINIFORGE_DIR:-$HOME/miniforge3}"
readonly WORKSPACE="${A1Z_WORKSPACE:-$HOME/a1z-workspace}"
readonly DOWNLOAD_DIR="${A1Z_DOWNLOAD_DIR:-$WORKSPACE/downloads}"
readonly MINIFORGE_INSTALLER="Miniforge3-$(uname)-$(uname -m).sh"
readonly MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/$MINIFORGE_INSTALLER"
readonly A1Z_URL="https://github.com/userguide-galaxea/GALAXEA-A1Z.git"
readonly A1Z_BRANCH="gripper"
readonly TELEOP_URL="https://github.com/suhanwu/a1z-teleop.git"
readonly TELEOP_BRANCH="main"

manual_step_required=0

log() { printf '[a1z-install] %s\n' "$*"; }
manual() { manual_step_required=1; printf '[MANUAL STEP REQUIRED] %s\n' "$*"; }
die() { printf '[FAIL] %s\n' "$*" >&2; exit 1; }

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "缺少基础命令: $1；请按官方文档准备后重试"
}

version_ge() {
  [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" == "$1" ]]
}

check_host() {
  [[ -r /etc/os-release ]] || die '无法读取 /etc/os-release'
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == ubuntu ]] || die "仅支持 Ubuntu，当前为 ${ID:-unknown}"
  case "${VERSION_ID:-}" in
    22.04|24.04) ;;
    *) die "A1Z 官方文档支持 Ubuntu 22.04/24.04，当前为 ${VERSION_ID:-unknown}" ;;
  esac

  local kernel_release
  kernel_release="$(uname -r)"
  version_ge '6.8.0-124' "$kernel_release" || die "内核 $kernel_release 低于官方要求 6.8.0-124；脚本不升级内核"
  log "host accepted: Ubuntu ${VERSION_ID}, kernel ${kernel_release}, arch $(uname -m)"
}

install_miniforge() {
  if [[ -x "$MINIFORGE_DIR/bin/conda" ]]; then
    log "reuse Miniforge: $MINIFORGE_DIR"
    return
  fi
  [[ ! -e "$MINIFORGE_DIR" ]] || die "Miniforge 目标存在但不可用: $MINIFORGE_DIR"
  mkdir -p "$DOWNLOAD_DIR"
  local installer="$DOWNLOAD_DIR/$MINIFORGE_INSTALLER"
  log "download official Miniforge installer: $MINIFORGE_URL"
  wget -O "$installer" "$MINIFORGE_URL"
  log "install Miniforge to $MINIFORGE_DIR"
  bash "$installer" -b -p "$MINIFORGE_DIR"
}

ensure_environment() {
  # shellcheck disable=SC1090
  source "$MINIFORGE_DIR/etc/profile.d/conda.sh"
  if conda env list | awk '{print $1}' | grep -Fxq "$ENV_NAME"; then
    local python_version
    python_version="$(conda run --no-capture-output -n "$ENV_NAME" python --version 2>&1)"
    [[ "$python_version" == Python\ 3.12.* ]] || die "$ENV_NAME 已存在但不是 Python 3.12: $python_version"
    log "reuse conda environment: $ENV_NAME ($python_version)"
  else
    conda create -y -n "$ENV_NAME" python=3.12
  fi
  conda install -y -n "$ENV_NAME" -c conda-forge ffmpeg
  conda activate "$ENV_NAME"
  local installed_lerobot
  installed_lerobot="$(python -c 'import importlib.metadata as m; print(m.version("lerobot"))' 2>/dev/null || true)"
  if [[ -n "$installed_lerobot" && "$installed_lerobot" != 0.6.1 ]]; then
    die "当前环境已有 LeRobot $installed_lerobot；脚本不自动替换或降级，请人工处理后重试"
  fi
  [[ -n "$installed_lerobot" ]] || python -m pip install lerobot==0.6.1
}

prepare_repo() {
  local url="$1" branch="$2" destination="$3"
  if [[ -e "$destination" ]]; then
    [[ -d "$destination/.git" ]] || die "外部目标不是 Git 仓库: $destination"
    local actual_branch actual_url
    actual_url="$(git -C "$destination" remote get-url origin)"
    [[ "$actual_url" == "$url" ]] || die "$destination origin 不匹配: $actual_url"
    actual_branch="$(git -C "$destination" branch --show-current)"
    [[ "$actual_branch" == "$branch" ]] || die "$destination 当前分支为 '$actual_branch'，期望 '$branch'；脚本不自动切换"
    [[ -z "$(git -C "$destination" status --porcelain)" ]] || die "$destination 有未提交修改；脚本不覆盖外部 checkout"
  else
    mkdir -p "$(dirname -- "$destination")"
    git clone --branch "$branch" --single-branch "$url" "$destination"
  fi
  log "source ready: $destination"
  git -C "$destination" remote get-url origin
  git -C "$destination" branch --show-current
  git -C "$destination" rev-parse HEAD
}

record_revisions() {
  local report="$WORKSPACE/source-revisions.txt"
  {
    printf 'recorded_at=%s\n' "$(date -Is)"
    printf '[GALAXEA-A1Z]\n'
    git -C "$WORKSPACE/GALAXEA-A1Z" remote get-url origin
    git -C "$WORKSPACE/GALAXEA-A1Z" branch --show-current
    git -C "$WORKSPACE/GALAXEA-A1Z" rev-parse HEAD
    printf '[a1z-teleop]\n'
    git -C "$WORKSPACE/a1z-teleop" remote get-url origin
    git -C "$WORKSPACE/a1z-teleop" branch --show-current
    git -C "$WORKSPACE/a1z-teleop" rev-parse HEAD
  } > "$report"
  log "source revisions recorded outside Git: $report"
}

install_r2c_if_provided() {
  if [[ -z "${R2C_SDK_PATH:-}" ]]; then
    manual '请从 CloudRobo 控制台“运行管理 > 机器人 > R2C SDK 软件包”下载最新官方包，解压后设置 R2C_SDK_PATH；脚本不猜测下载地址'
    return
  fi
  [[ -d "$R2C_SDK_PATH" ]] || die "R2C_SDK_PATH 不是目录: $R2C_SDK_PATH"
  [[ -f "$R2C_SDK_PATH/pyproject.toml" || -f "$R2C_SDK_PATH/setup.py" ]] || die 'R2C_SDK_PATH 缺少 pyproject.toml/setup.py；请提供实际官方源码目录'
  conda activate "$ENV_NAME"
  python -m pip install -e "$R2C_SDK_PATH"
}

main() {
  cd "$PROJECT_DIR"
  for command_name in awk bash date git grep head sort uname wget; do
    require_command "$command_name"
  done
  check_host
  install_miniforge
  ensure_environment
  mkdir -p "$WORKSPACE"
  prepare_repo "$A1Z_URL" "$A1Z_BRANCH" "$WORKSPACE/GALAXEA-A1Z"
  prepare_repo "$TELEOP_URL" "$TELEOP_BRANCH" "$WORKSPACE/a1z-teleop"
  conda activate "$ENV_NAME"
  A1Z_SDK="$WORKSPACE/GALAXEA-A1Z" bash "$WORKSPACE/a1z-teleop/setup.sh"
  record_revisions
  install_r2c_if_provided
  log 'software-only installation sequence finished'
  log 'run scripts/verify_env.sh for read-only verification'
  (( manual_step_required == 0 )) || log 'manual R2C SDK step remains pending'
}

main "$@"
