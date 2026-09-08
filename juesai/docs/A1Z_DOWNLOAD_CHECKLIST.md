# 决赛 A1Z 下载与安装清单

本清单只记录未来在 Ubuntu VM 中执行的命令。本阶段不执行任何下载、安装或外部仓库 clone。

## 1. Miniforge

来源：华为 A1Z 专用文档引用的 Miniforge 最新 Linux 安装器；安装器命名和非交互参数依据 Miniforge 官方说明。

```bash
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh
source ~/.bashrc
```

自动化脚本使用同一官方 URL，并采用官方 Miniforge 的非交互形式：

```bash
bash Miniforge3-$(uname)-$(uname -m).sh -b -p "$HOME/miniforge3"
source "$HOME/miniforge3/etc/profile.d/conda.sh"
```

预期：`$HOME/miniforge3/bin/conda` 可用。不要在脚本中固定一个未经当前官方页面要求的旧 Miniforge 版本。

## 2. Conda 环境

来源：华为 A1Z 专用文档。

```bash
conda create -y -n lerobot061 python=3.12
conda activate lerobot061
python -V
```

预期：环境名为 `lerobot061`，Python 为 `3.12.x`。

## 3. ffmpeg

来源：华为 CloudRobo 环境文档的 Linux 安装步骤，通道为 conda-forge。

```bash
conda install -y -n lerobot061 -c conda-forge ffmpeg
conda activate lerobot061
ffmpeg -version
```

预期：当前环境中可以找到 `ffmpeg`。

## 4. LeRobot

来源：华为 A1Z 专用文档。

```bash
conda activate lerobot061
python -m pip install lerobot==0.6.1
python -c "import lerobot; print(lerobot.__version__)"
```

预期：输出 `0.6.1`。本项目不采用通用 CloudRobo 文档中的 LeRobot 0.5.1，因为它适用于另一套旧环境说明。

## 5. GALAXEA-A1Z SDK

来源：[GALAXEA-A1Z 官方仓库的 `gripper` 分支](https://github.com/userguide-galaxea/GALAXEA-A1Z/tree/gripper)。

```bash
cd "$HOME/a1z-workspace"
git clone --branch gripper --single-branch \
  https://github.com/userguide-galaxea/GALAXEA-A1Z.git \
  GALAXEA-A1Z
cd GALAXEA-A1Z
conda activate lerobot061
python -m pip install -e .
git branch --show-current
git rev-parse HEAD
git log -1 --format='%H %s'
```

预期：当前分支为 `gripper`；将 `git rev-parse HEAD` 输出记录到 VM 外部的版本记录中。不要在没有来源依据时把未来仓库 HEAD 擅自替换成其他 SHA。

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

来源：华为 CloudRobo 控制台和 A1Z 专用文档。

1. 登录 CloudRobo 控制台。
2. 进入“运行管理 > 机器人”。
3. 使用右上角“R2C SDK 软件包”下载最新官方包。
4. 将压缩包放入工作目录；不要从 GitHub、PyPI 或猜测的 URL 获取替代包。

官方示例命令（文件名和目录以控制台实际下载内容为准）：

```bash
tar -zxvf hw_r2c_sdk-<官方版本>.tar.gz
cd r2c_sdk_python
conda activate lerobot061
python -m pip install -e .
python -c "import r2c_sdk; print(getattr(r2c_sdk, '__version__', 'unknown'))"
```

当前状态：`MANUAL STEP REQUIRED`。本项目不固定示例版本，不猜下载地址。自动脚本只有在用户显式提供 `R2C_SDK_PATH` 时才执行本地 editable install。

## 9. 真机阶段依赖（只记录，不执行）

以下步骤必须到现场、硬件接线并完成安全检查后执行：

### SocketCAN / gs_usb / CAN

来源：A1Z SDK README 和华为 A1Z 专用文档。

```bash
sudo modprobe gs_usb
sudo sh -c 'echo "a8fa 8598" > /sys/bus/usb/drivers/gs_usb/new_id' 2>/dev/null || true
ip link show type can
sudo ip link set can0 type can bitrate 1000000
sudo ip link set can0 up
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
  --robot.can_channel=can0 \
  --robot.id=follower_a1z
```

本阶段不执行上述任何硬件命令。
