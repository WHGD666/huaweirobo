#!/usr/bin/env bash
set -euo pipefail

# Install only the user-provided official CloudRobo R2C SDK source directory.
# The archive must be downloaded from the CloudRobo console and extracted by
# the user before this script is called. No URL, filename, or SDK version is
# inferred here, and no hardware operation is performed.

readonly ENV_NAME="${JUESAI_ENV_NAME:-lerobot061}"
readonly MINIFORGE_DIR="${MINIFORGE_DIR:-$HOME/miniforge3}"
readonly R2C_SDK_PATH_VALUE="${R2C_SDK_PATH:-}"

log() { printf '[r2c-install] %s\n' "$*"; }
die() { printf '[FAIL] %s\n' "$*" >&2; exit 1; }

if [[ -z "$R2C_SDK_PATH_VALUE" ]]; then
  die '请先从 CloudRobo 控制台“运行管理 > 机器人 > R2C SDK 软件包”下载并解压官方包，然后设置 R2C_SDK_PATH'
fi

[[ -d "$R2C_SDK_PATH_VALUE" ]] || die "R2C_SDK_PATH 不是目录: $R2C_SDK_PATH_VALUE"
[[ -f "$R2C_SDK_PATH_VALUE/pyproject.toml" || -f "$R2C_SDK_PATH_VALUE/setup.py" ]] || \
  die 'R2C_SDK_PATH 缺少 pyproject.toml/setup.py；请传入实际解压后的 r2c_sdk_python 源码目录'

conda_bin=''
if [[ -x "$MINIFORGE_DIR/bin/conda" ]]; then
  conda_bin="$MINIFORGE_DIR/bin/conda"
elif command -v conda >/dev/null 2>&1; then
  conda_bin="$(command -v conda)"
else
  die '未找到 Miniforge/conda；请先完成 A1Z Phase 1 环境安装'
fi

env_names="$($conda_bin env list | awk '{print $1}')"
grep -Fxq "$ENV_NAME" <<<"$env_names" || die "conda 环境不存在: $ENV_NAME"

python_version="$($conda_bin run --no-capture-output -n "$ENV_NAME" python --version 2>&1)"
[[ "$python_version" == Python\ 3.12.* ]] || die "环境不是 Python 3.12: $python_version"

lerobot_version="$($conda_bin run --no-capture-output -n "$ENV_NAME" python -c 'import importlib.metadata as m; print(m.version("lerobot"))' 2>&1)"
[[ "$lerobot_version" == 0.6.1 ]] || die "环境中的 LeRobot 不是 0.6.1: $lerobot_version"

log "using conda environment: $ENV_NAME ($python_version)"
log "using user-provided official SDK directory: $R2C_SDK_PATH_VALUE"
log 'installing with the official editable-install workflow: pip install -e .'
(
  cd "$R2C_SDK_PATH_VALUE"
  "$conda_bin" run --no-capture-output -n "$ENV_NAME" python -m pip install -e .
)

log 'verifying r2c_sdk APIs'
"$conda_bin" run --no-capture-output -n "$ENV_NAME" python -c \
  'import r2c_sdk; from r2c_sdk import ClientConfig, SyncRobotClient; print("r2c_sdk OK"); print("ClientConfig=" + ClientConfig.__name__); print("SyncRobotClient=" + SyncRobotClient.__name__)'

log 'R2C SDK installation and software-only verification finished'
