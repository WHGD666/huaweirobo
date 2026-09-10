# 决赛 A1Z 下载与安装清单

本清单只记录未来在 Ubuntu VM 中执行的命令。本阶段不执行任何下载、安装或外部仓库 clone。

## 1. Miniforge

来源：华为 A1Z 专用文档明确提供的清华 Miniforge Linux 安装器；非交互参数依据 Miniforge 官方说明。

```bash
wget "https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-x86_64.sh"
bash Miniforge3-Linux-x86_64.sh
source ~/.bashrc
```

如果清华镜像下载失败，才回退到 Miniforge 官方 GitHub LatestRelease 地址：

```bash
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh
```

自动化脚本默认使用上述清华镜像，并在镜像失败时回退到 GitHub；安装仍采用官方 Miniforge 的非交互形式：

```bash
bash Miniforge3-Linux-x86_64.sh -b -p "$HOME/miniforge3"
source "$HOME/miniforge3/etc/profile.d/conda.sh"
```

预期：`$HOME/miniforge3/bin/conda` 可用。不要在脚本中固定一个未经当前官方页面要求的旧 Miniforge 版本。

## 2. Conda 环境

来源：华为 A1Z 专用文档；清华 conda-forge 镜像配置来自华为 CloudRobo 配置软件环境文档。

```bash
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --set show_channel_urls yes
conda config --remove channels conda-forge || true
conda clean -i
conda config --show channels
```

预期：channels 中包含 `https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/`。移除默认国外 `conda-forge` 是华为文档标注的可选推荐操作。

```bash
conda create -y -n lerobot061 python=3.12
conda activate lerobot061
python -V
```

预期：环境名为 `lerobot061`，Python 为 `3.12.x`。

## 3. ffmpeg

来源：华为 CloudRobo 环境文档的 Linux 安装步骤，通道为 conda-forge。

```bash
conda install -y -n lerobot061 ffmpeg
conda activate lerobot061
ffmpeg -version
```

预期：当前环境中可以找到 `ffmpeg`。

## 4. LeRobot

来源：华为 A1Z 专用文档。

```bash
conda activate lerobot061
pip config set global.index-url https://repo.huaweicloud.com/repository/pypi/simple
pip config set global.trusted-host repo.huaweicloud.com
python -m pip install lerobot==0.6.1
python -c "import lerobot; print(lerobot.__version__)"
```

预期：pip 使用华为云 PyPI 镜像，输出 `0.6.1`。本项目不采用通用 CloudRobo 文档中的 LeRobot 0.5.1，因为它适用于另一套旧环境说明。

## 5. GALAXEA-A1Z SDK

本次安全迁移目标固定为官方候选分支的指定 commit。旧稳定基线为 `gripper` 分支 `e931ecd0e25ad35df251097ba42921b3d2fa7224`；新目标为 `feat/cross-platform-g1z-fixes` 分支 `366e523ab4e4331efd2337f302ce48e559e89194`。

来源：[GALAXEA-A1Z 官方候选分支](https://github.com/userguide-galaxea/GALAXEA-A1Z/tree/feat/cross-platform-g1z-fixes)。

```text
Repository: https://github.com/userguide-galaxea/GALAXEA-A1Z
Branch: feat/cross-platform-g1z-fixes
Commit: 366e523ab4e4331efd2337f302ce48e559e89194
```

```bash
cd "$HOME/a1z-workspace"
git clone --branch feat/cross-platform-g1z-fixes --single-branch \
  https://github.com/userguide-galaxea/GALAXEA-A1Z.git \
  GALAXEA-A1Z
cd GALAXEA-A1Z
git checkout --detach 366e523ab4e4331efd2337f302ce48e559e89194
conda activate lerobot061
python -m pip install -e .
git rev-parse HEAD
git log -1 --format='%H %s'
```

预期：A1Z SDK editable install 完成，`git rev-parse HEAD` 必须严格输出 `366e523ab4e4331efd2337f302ce48e559e89194`。checkout 使用 detached HEAD 是为了保证安装内容固定在目标 commit；不得使用 `latest`、`master` 或动态分支 HEAD。

### 官方条件性故障处理：编译失败时

如果 A1Z SDK 或相关 Python 包在安装/编译阶段报告缺少构建工具或 FFmpeg 开发库，才执行以下官方补依赖命令；正常安装时不默认执行：

```bash
sudo apt-get install \
  cmake \
  build-essential \
  python3-dev \
  pkg-config \
  libavformat-dev \
  libavcodec-dev \
  libavdevice-dev \
  libavutil-dev \
  libswscale-dev \
  libswresample-dev \
  libavfilter-dev
```

来源：华为 A1Z 专用文档的“编译失败补充依赖”说明。该命令只在编译报错时由用户人工执行，不进入默认安装脚本。

## 6. a1z-teleop

来源：[比赛指定仓库 suhanwu/a1z-teleop](https://github.com/suhanwu/a1z-teleop)。仓库 README 和 `setup.sh` 都以 LeRobot 0.6.1、`lerobot061` 为前提。

```bash
cd "$HOME/a1z-workspace"
git clone https://github.com/suhanwu/a1z-teleop.git a1z-teleop
cd a1z-teleop
conda activate lerobot061
A1Z_SDK="$HOME/a1z-workspace/GALAXEA-A1Z" bash setup.sh
python scripts/verify_install.py
git rev-parse HEAD
git log -1 --format='%H %s'
```

`setup.sh` 会安装 A1Z SDK、`fashionstar_uart_sdk`/`pyserial` 以及两个 LeRobot 插件，并调用其安装校验。插件包名分别为 `lerobot_teleoperator_stararm102` 与 `lerobot_robot_galaxea_a1z`，由 LeRobot 0.6.1 的第三方插件发现机制注册。

## 7. Star-Arm-102

来源：[Star-Arm-102 官方仓库](https://github.com/servodevelop/Star-Arm-102)。

用途：作为主臂硬件、UART 伺服和遥操作资料的参考来源。

当前不需要单独 clone 或安装。依据 `a1z-teleop/setup.sh` 的实际实现，主臂插件已经位于 `a1z-teleop/plugins/teleoperator-stararm102`，并由 `setup.sh` 安装；所需 `fashionstar_uart_sdk` 也由该脚本处理。Star-Arm-102 不进入本项目自动安装依赖。

## 8. hw-r2c-sdk

来源：[华为 A1Z 专用文档](https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0042.html) 和 CloudRobo 控制台。

1. 登录 CloudRobo 控制台。
2. 进入“运行管理 > 机器人”。
3. 使用右上角“R2C SDK 软件包”下载最新官方包。
4. 由用户按控制台实际文件名手工解压；不要从 GitHub、PyPI 或猜测的 URL 获取替代包，也不要在项目中固定版本号或压缩包文件名。
5. 确认解压后的实际 SDK 源码目录中存在 `pyproject.toml` 或 `setup.py`。

在现有 `lerobot061` / Python 3.12 环境中运行独立安装脚本：

```bash
export R2C_SDK_PATH="/实际解压后的/r2c_sdk_python"
bash scripts/install_r2c_official.sh
bash scripts/verify_env.sh
```

脚本会检查 `lerobot061`、Python 3.12 和 LeRobot 0.6.1，然后在 SDK 源码目录执行官方方式 `pip install -e .`，最后验证：

```python
from r2c_sdk import ClientConfig, SyncRobotClient
```

当前状态：`MANUAL STEP REQUIRED`。下载、解压和 `R2C_SDK_PATH` 路径必须由用户根据控制台实际内容提供。脚本不猜测下载地址、版本号或文件名，不执行任何 CAN、机器人、相机、UART 或真机动作。

## 9. 真机阶段依赖（只记录，不执行）

以下步骤必须到现场、硬件接线并完成安全检查后执行：

### SocketCAN / gs_usb / CAN

来源：A1Z SDK README 和华为 A1Z 专用文档。

#### 官方首选主路径

A1Z 专章优先使用 `a1z-teleop` 提供的配置脚本。该脚本负责加载 `gs_usb`、绑定 HHS 适配器、寻找实际 CAN 接口并按 1 Mbps 启动；接口名称不保证是 `can0`。

```bash
cd "$HOME/a1z-workspace/a1z-teleop"
sudo bash setup_follower_can.sh
```

读取脚本输出的实际接口名后，再执行：

```bash
ip -d link show <实际CAN接口>
python scripts/scan_can_ids.py <实际CAN接口>
candump <实际CAN接口>
```

#### 故障排查 / 实现说明（不是现场首选路径）

仅在官方主脚本无法使用、且已按现场安全流程确认硬件后，才参考以下底层排查命令；接口仍使用实际名称，不写死 `can0`：

```bash
sudo modprobe gs_usb
sudo sh -c 'echo "a8fa 8598" > /sys/bus/usb/drivers/gs_usb/new_id' 2>/dev/null || true
ip link show type can
sudo ip link set <实际CAN接口> type can bitrate 1000000
sudo ip link set <实际CAN接口> up
```

### Camera

来源：华为 A1Z 专用文档。接入两路 USB/UVC 相机后，再确认设备路径：

```bash
v4l2-ctl --list-devices
```

相机通道名必须与训练数据中的 `observation.images.cam_wrist` 和 `observation.images.cam_external` 对齐。

### Calibration

来源：华为 A1Z 专用文档和 a1z-teleop 的标定流程。确认机械臂供电、急停和工作空间安全后，才允许进入交互标定：

```bash
conda activate lerobot061
lerobot-calibrate \
  --robot.type=galaxea_a1z_follower \
  --robot.can_channel=<实际CAN接口> \
  --robot.id=follower_a1z
```

本阶段不执行上述任何硬件命令。
