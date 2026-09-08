# 决赛 A1Z 来源与命令映射

审计日期：2026-09-08。来源优先级严格遵循：A1Z 专用华为文档 > CloudRobo 通用环境文档 > 指定代码仓库。

硬件资源说明补充使用华为 CloudRobo SDK 参考中的“接入机器人/准备硬件设备”要求：CPU 6 核以上（推荐 8 核）、内存 16GB 以上（推荐 32GB）、硬盘 1TB 以上（推荐 NVMe/SSD）、USB 至少 4 个；本机推理时显卡显存要求 8GB 以上。该要求用于正式上位机审计，不改变当前 100GB VMware Phase 1 预演定位。

## 1. 华为 A1Z 专用文档（最高优先级）

- 来源：华为云 CloudRobo SDK 参考，“星海图 A1Z”。
- URL：<https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0042.html>
- 页面更新时间：2026-09-07 GMT+08:00。
- 使用版本：Ubuntu 22.04/24.04、内核 `>=6.8.0-124`、Python 3.12、conda 环境 `lerobot061`、LeRobot 0.6.1、conda-forge ffmpeg、A1Z `gripper` 分支、最新 hw-r2c-sdk。
- 使用命令：Miniforge LatestRelease 下载；`conda create -y -n lerobot061 python=3.12`；`conda install ffmpeg -c conda-forge`；`pip install lerobot==0.6.1`；`A1Z_SDK=... bash setup.sh`；现场 SocketCAN/CAN/标定步骤。
- 对应文件：`A1Z_ENV_AUDIT.md`、`A1Z_DOWNLOAD_CHECKLIST.md`、`A1Z_INSTALL_GUIDE.md`、`scripts/install_a1z_official.sh`、`scripts/verify_env.sh`。

## 2. CloudRobo 通用环境文档（仅作补充）

- 来源：华为云 CloudRobo SDK 参考，“配置软件环境”。
- URL：<https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0002.html>
- 页面更新时间：2026-09-04 GMT+08:00。
- 可用内容：Linux Miniforge 安装、conda-forge ffmpeg、CloudRobo 控制台下载 R2C SDK、解压和 `pip install -e .`。
- 适用范围差异：该页面仍写 LeRobot 0.5.1、环境名 `lerobot`，属于旧的通用流程；A1Z 专用页面写 LeRobot 0.6.1、环境名 `lerobot061`。本项目使用 A1Z 专用页面的 0.6.1，不混用通用页的 0.5.1 命令。
- 对应文件：`A1Z_DOWNLOAD_CHECKLIST.md`、`A1Z_INSTALL_GUIDE.md`、`scripts/install_a1z_official.sh`。

## 3. GALAXEA-A1Z SDK

- 来源：[userguide-galaxea/GALAXEA-A1Z](https://github.com/userguide-galaxea/GALAXEA-A1Z/tree/gripper)。
- 版本依据：分支 `gripper`；运行时通过 `git rev-parse HEAD` 记录实际 SHA，不在本项目擅自固化未由当前官方页面要求的未来 commit。
- 使用命令：`git clone --branch gripper --single-branch ...`；`python -m pip install -e .`；`git branch --show-current`；`git rev-parse HEAD`。
- 对应文件：`A1Z_DOWNLOAD_CHECKLIST.md`、`A1Z_INSTALL_GUIDE.md`、`scripts/install_a1z_official.sh`、`scripts/verify_env.sh`。

## 4. a1z-teleop

- 来源：[suhanwu/a1z-teleop](https://github.com/suhanwu/a1z-teleop)。
- 版本依据：`main` 分支的实际 HEAD；运行时通过 `git rev-parse HEAD` 记录 SHA。
- 关键实现：[setup.sh](https://raw.githubusercontent.com/suhanwu/a1z-teleop/main/setup.sh) 明确使用 `lerobot061`、LeRobot 0.6.x、`A1Z_SDK`、两个 pip 插件，并调用 `scripts/verify_install.py`。[verify_install.py](https://raw.githubusercontent.com/suhanwu/a1z-teleop/main/scripts/verify_install.py) 检查 SDK 导入、ChoiceRegistry 注册和 CLI 配置实例化路径。
- 使用命令：`git clone ...`；`A1Z_SDK=... bash setup.sh`；`python scripts/verify_install.py`；`git rev-parse HEAD`。
- 对应文件：`A1Z_DOWNLOAD_CHECKLIST.md`、`A1Z_INSTALL_GUIDE.md`、`scripts/install_a1z_official.sh`、`scripts/verify_env.sh`。

## 5. Star-Arm-102

- 来源：[servodevelop/Star-Arm-102](https://github.com/servodevelop/Star-Arm-102)。
- 用途：主臂硬件、UART 伺服和遥操作资料参考。
- 安装判断：当前不单独安装。`a1z-teleop` 自带 `plugins/teleoperator-stararm102`，并由其 `setup.sh` 安装该插件和 `fashionstar_uart_sdk`；因此 Star-Arm-102 不作为自动安装依赖。
- 对应文件：`A1Z_DOWNLOAD_CHECKLIST.md`、`A1Z_INSTALL_GUIDE.md`、本文件。

## 6. LeRobot 与 Torch

- LeRobot 来源：A1Z 专用华为文档；版本 `0.6.1`；命令 `python -m pip install lerobot==0.6.1`；验证 `import lerobot` 和版本输出；对应三个 A1Z 文档和两个脚本。
- 通用页的 `0.5.1`：仅记录为适用范围差异，不进入本项目安装脚本。
- Torch：A1Z 专用页面说明随 LeRobot PyPI Linux wheel 安装的 CUDA 12.x 版 Torch；本项目不另外指定 Torch 版本，不设置 `TORCH_INDEX_URL`，不自动改变 CUDA/Driver。
- GPU：VMware 无 GPU 时脚本输出 `SKIP`，不触发任何替换逻辑。

## 7. Miniforge 与 ffmpeg

- Miniforge 来源：A1Z 专用文档的 Linux LatestRelease URL；非交互 `-b -p` 参数来自 [Miniforge 官方说明](https://github.com/conda-forge/miniforge#unix-like-platforms-macos-linux--wsl)。不固定旧发行版 SHA。
- 命令：`wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"`；`bash ... -b -p "$HOME/miniforge3"`。
- ffmpeg 来源：通用 CloudRobo 文档；命令 `conda install -n lerobot061 -c conda-forge ffmpeg`。
- 对应文件：两个 A1Z 文档、两个脚本。

## 8. hw-r2c-sdk

- 来源：CloudRobo 控制台“运行管理 > 机器人 > R2C SDK 软件包”，配合华为官方环境文档。
- 版本：最新官方包；不固定通用文档中的示例版本，不记录猜测 URL。
- 命令：用户下载后执行 `tar -zxvf hw_r2c_sdk-<官方版本>.tar.gz`、进入实际 `r2c_sdk_python` 目录、`python -m pip install -e .`、`import r2c_sdk` 验证。
- 脚本行为：只有显式提供 `R2C_SDK_PATH` 才安装；否则输出 `MANUAL STEP REQUIRED`。
- 对应文件：`A1Z_DOWNLOAD_CHECKLIST.md`、`A1Z_INSTALL_GUIDE.md`、`scripts/install_a1z_official.sh`、`scripts/verify_env.sh`。

## 9. CloudRobo 上位机硬件要求

- 来源：华为云 CloudRobo SDK 参考，“接入机器人”中的准备硬件设备要求。
- URL：<https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0003.html>
- 使用内容：CPU、内存、硬盘、USB 和本机推理 GPU 的最低/推荐规格；对应 `A1Z_ENV_AUDIT.md`。

## 10. 真机步骤来源

- SocketCAN/gs_usb：A1Z SDK README 与 A1Z 专用文档；官方首选命令为 `cd ~/a1z-workspace/a1z-teleop && sudo bash setup_follower_can.sh`，然后使用脚本输出的实际 CAN 接口执行 `ip -d link show`、`scripts/scan_can_ids.py` 和 `candump`。包括 HHS Pro-II VID/PID `a8fa:8598`、`gs_usb`、1 Mbps 配置。
- Camera：A1Z 专用文档；使用 UVC 设备检查，通道名需与训练数据的 `cam_wrist`、`cam_external` 一致。
- Calibration：A1Z 专用文档和 a1z-teleop 流程；首次使用现场交互完成。所有真机命令只写在 `A1Z_DOWNLOAD_CHECKLIST.md` 的现场章节，不进入普通安装脚本。
- 条件性编译补依赖：A1Z 专用文档列出的 `cmake`、`build-essential`、`python3-dev`、`pkg-config` 和 FFmpeg 开发库，仅在编译报错时执行；对应 `A1Z_DOWNLOAD_CHECKLIST.md`、`A1Z_INSTALL_GUIDE.md`。

## 11. 历史 P4 资料

旧 P4 实验中的 `cu118`、`TORCH_INDEX_URL`、Driver 550 和 P4 profile 仅作为历史背景记录，不是本标准环境的来源、版本或默认命令。新安装脚本不读取、不设置这些内容。
