# Phase 1 环境方案

## 目标架构

本地 Windows 只负责编辑、审查 diff、Git 提交推送和 SSH；不配置完整运行环境。远程免费 P4 是可随时释放的临时 Linux 节点，代码以 Git 为准，重要数据和模型放在 OBS/CloudRobo。正式训练使用 CloudRobo Ascend 910B，不在 P4 上进行大型 VLA 训练。

P4 的系统 Python 3.10 保持不动。A1Z 官方运行链使用 Miniforge 创建独立的 `lerobot061` 环境，Python 3.12、LeRobot 0.6.1 和 ffmpeg。这样不会修改系统 Python，也符合 A1Z 官方页面的当前要求。

## 安装入口

`scripts/bootstrap.sh` 是唯一的软件安装入口。它会：

1. 检查 Ubuntu、内核、磁盘和基础命令；
2. 安装或复用 Miniforge；
3. 创建/检查 `lerobot061`（Python 3.12）；
4. 安装 ffmpeg 和 `lerobot==0.6.1`；
5. 按固定 commit 检出 A1Z `gripper` 分支和 `a1z-teleop`；
6. 调用参考仓库自带的 `setup.sh` 安装 A1Z 与插件；
7. 若用户提供 `R2C_SDK_PATH`，安装官方 CloudRobo r2c SDK；否则报告人工步骤。

外部仓库默认放在 `$HOME/juesai.external`，也可通过 `JUESAI_EXTERNAL_ROOT` 指定。它们不会复制进本仓库。

```bash
export JUESAI_EXTERNAL_ROOT="$HOME/juesai.external"
bash scripts/bootstrap.sh
bash scripts/verify_env.sh --report "$JUESAI_EXTERNAL_ROOT/environment-report.txt"
```

如果 `verify_env.sh` 报告 Torch CUDA 驱动不兼容，先依据华为官方 A1Z 页面提供的旧驱动示例使用官方 cu118 index，再重跑安装：

```bash
export TORCH_INDEX_URL="https://download.pytorch.org/whl/cu118"
bash scripts/bootstrap.sh
bash scripts/verify_env.sh
```

不根据显卡型号自行猜测 CUDA/Torch 组合；只有出现实际驱动兼容性证据时才使用这个官方覆盖项。

若已有环境或外部 checkout 被手动修改，脚本不会强行覆盖，而是停止并要求人工处理。脚本使用固定版本和 SHA256；不要通过修改脚本来绕过来源审计。

## r2c SDK 人工步骤

华为官方文档要求从 CloudRobo 控制台的“运行管理 > 机器人 > R2C SDK 软件包”下载并解压 SDK。下载完成后，在远程服务器上设置解压目录：

```bash
export R2C_SDK_PATH="/path/to/r2c_sdk_python"
bash scripts/bootstrap.sh
bash scripts/verify_env.sh
```

脚本不会使用未经官方确认的 r2c Git 地址、版本或下载链接。

## 当前不自动执行的操作

以下操作需要真实设备或用户明确选择，全部排除在 P4 软件验证之外：CAN 初始化、CAN 扫描/探测、A1Z 连接、舵机零点标定、相机检查、遥操作、数据采集、模型下载和训练。尤其不要因为脚本名带有 `dry-run` 就默认它不接触硬件；参考仓库的 `test_teleop.py --dry-run` 仍会调用设备连接入口。

## 服务器重建原则

服务器最长约 24 小时，释放后环境不保留。每次重建都应从 Git 拉取 `juesai`，执行 bootstrap，再执行 verify。不要把 checkpoint、大型数据集、凭据或机器特定配置提交到 Git；环境报告默认写到仓库外。
