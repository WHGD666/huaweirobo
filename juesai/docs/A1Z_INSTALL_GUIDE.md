# 决赛 A1Z 标准安装指南

本指南面向全新 Ubuntu 22.04 VM。所有命令均为未来执行材料；当前本地准备阶段不执行安装、下载或硬件命令。

## A. 现在可执行的软件安装（无硬件）

### Step 0：确认基础条件

目的：确认系统属于华为 A1Z 专页支持范围，并确保安装路径没有个人硬编码。

命令：

```bash
uname -r
uname -m
cat /etc/os-release
command -v bash git wget tar
```

预期结果：Ubuntu 22.04/24.04、x86_64，并能找到所需基础命令。内核应为 `6.8.0-124` 或更新版本。

验证命令：

```bash
bash scripts/verify_env.sh
```

来源：[华为 A1Z 专用文档](https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0042.html)。

### Step 1：安装 Miniforge

目的：提供 conda/mamba，不修改系统 Python。

命令：

```bash
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b -p "$HOME/miniforge3"
source "$HOME/miniforge3/etc/profile.d/conda.sh"
```

预期结果：`$HOME/miniforge3/bin/conda` 存在并可执行。

验证命令：

```bash
"$HOME/miniforge3/bin/conda" --version
```

来源：[华为 A1Z 专用文档](https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0042.html)；非交互参数见 [Miniforge 官方说明](https://github.com/conda-forge/miniforge#unix-like-platforms-macos-linux--wsl)。

### Step 2：创建 `lerobot061`

目的：创建 A1Z 要求的 Python 3.12 隔离环境。

命令：

```bash
conda create -y -n lerobot061 python=3.12
conda activate lerobot061
```

预期结果：环境创建成功，环境名为 `lerobot061`。

验证命令：

```bash
python -V
```

预期输出：`Python 3.12.x`。

来源：[华为 A1Z 专用文档](https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0042.html)。

### Step 3：安装 ffmpeg

目的：提供 LeRobot/TorchCodec 所需的视频解码工具。

命令：

```bash
conda install -y -n lerobot061 -c conda-forge ffmpeg
conda activate lerobot061
```

预期结果：ffmpeg 安装到 `lerobot061` 环境。

验证命令：

```bash
ffmpeg -version
```

来源：[CloudRobo 通用环境文档](https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0002.html)，仅借用其 ffmpeg 安装步骤。

### Step 4：安装 LeRobot 0.6.1

目的：安装与 A1Z 插件 API 匹配的 LeRobot 版本。

命令：

```bash
conda activate lerobot061
python -m pip install lerobot==0.6.1
```

预期结果：pip 完成 `lerobot==0.6.1` 安装。

验证命令：

```bash
python -c "import lerobot; print(lerobot.__version__)"
```

预期输出：`0.6.1`。

来源：[华为 A1Z 专用文档](https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0042.html)。不要使用通用页中针对旧流程的 0.5.1。

### Step 5：获取并安装 A1Z SDK

目的：使用带 G1Z 夹爪支持的官方 `gripper` 分支。

命令：

```bash
mkdir -p "$HOME/a1z-workspace"
cd "$HOME/a1z-workspace"
git clone --branch gripper --single-branch \
  https://github.com/userguide-galaxea/GALAXEA-A1Z.git \
  GALAXEA-A1Z
cd GALAXEA-A1Z
python -m pip install -e .
```

预期结果：A1Z SDK editable install 完成，源码分支为 `gripper`。

验证命令：

```bash
git branch --show-current
git rev-parse HEAD
python -c "from a1z.robots.get_robot import get_a1z_robot; print(get_a1z_robot.__name__)"
```

来源：[GALAXEA-A1Z gripper 分支](https://github.com/userguide-galaxea/GALAXEA-A1Z/tree/gripper)。

### Step 6：获取 a1z-teleop 并调用官方 setup

目的：安装比赛指定的主臂/从臂 LeRobot 插件及其 SDK 依赖。

命令：

```bash
cd "$HOME/a1z-workspace"
git clone https://github.com/suhanwu/a1z-teleop.git a1z-teleop
cd a1z-teleop
conda activate lerobot061
A1Z_SDK="$HOME/a1z-workspace/GALAXEA-A1Z" bash setup.sh
```

预期结果：官方 `setup.sh` 完成 A1Z SDK、UART SDK 和两个插件的 editable install，并运行其安装校验。

验证命令：

```bash
python scripts/verify_install.py
git rev-parse HEAD
```

来源：[a1z-teleop README](https://github.com/suhanwu/a1z-teleop) 和 [官方 setup.sh](https://raw.githubusercontent.com/suhanwu/a1z-teleop/main/setup.sh)。

### Step 7：获取 hw-r2c-sdk（人工步骤）

目的：安装 CloudRobo 控制台为当前项目提供的最新 R2C SDK。

命令：先在 CloudRobo 控制台“运行管理 > 机器人 > R2C SDK 软件包”下载，再由用户将解压目录显式传入：

```bash
export R2C_SDK_PATH="/用户明确指定的/r2c_sdk_python"
python -m pip install -e "$R2C_SDK_PATH"
```

预期结果：用户指定目录被 editable install；版本以官方包实际内容为准。

验证命令：

```bash
python -c "import r2c_sdk; print(getattr(r2c_sdk, '__version__', 'unknown'))"
```

来源：[华为 CloudRobo 通用环境文档](https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0002.html) 与 [A1Z 专用文档](https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0042.html)。状态：`MANUAL STEP REQUIRED`。不猜测包名、版本或下载 URL。

## B. 必须到现场有硬件后再执行

以下内容不属于普通软件安装流程。必须完成硬件接线、供电、急停和工作区安全检查后，按 [A1Z_DOWNLOAD_CHECKLIST.md](A1Z_DOWNLOAD_CHECKLIST.md) 的现场章节执行：

- `gs_usb`/SocketCAN 加载与 `can0` 初始化；
- A1Z CAN 扫描和通信验证；
- Star-Arm-102 UART/udev 配置及主从联动；
- UVC Camera 设备识别与通道映射；
- A1Z/夹爪标定；
- 遥操作、数据采集和 CloudRobo 真实连接。

本地 VM 无 GPU 时，不需要为预演环境安装或替换 CUDA/Torch；GPU 状态由验证脚本输出 `SKIP`。
