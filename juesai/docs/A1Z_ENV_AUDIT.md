# 决赛 A1Z 标准软件环境审计

审计范围：只整理可复制到 Ubuntu VM 后执行的软件方案。本文件不代表已经在 VM、远程服务器或真机上执行过安装。

## 1. 官方基线与目标 VM

| 项目 | 华为 A1Z 专用文档要求 | 本项目目标 VM | 结论 |
|---|---|---|---|
| 操作系统 | Ubuntu 22.04/24.04 | Ubuntu 22.04 | 符合 |
| 内核 | `>= 6.8.0-124`，用于 SocketCAN 兼容性 | `6.8.0-138-generic` | 符合 |
| 架构 | Linux x86_64 安装器可用 | x86_64 | 符合 |
| CPU | 未规定固定值 | 8 vCPU | 目标配置 |
| 内存 | 未规定固定值 | 16GB | 目标配置 |
| 磁盘 | 未规定固定值 | 100GB | 目标配置 |
| 虚拟化 | 未规定固定平台 | VMware | 预演节点 |
| Python | 3.12 | 3.12 | 必须创建并验证 |
| Conda 环境 | A1Z 专页使用 `lerobot061` | `lerobot061` | 必须保持一致 |
| LeRobot | 0.6.1 | 0.6.1 | 必须保持一致 |
| ffmpeg | conda-forge 版本 | conda-forge 版本 | 必须安装并验证 |
| A1Z SDK | `GALAXEA-A1Z` 的 `gripper` 分支 | `gripper` 分支 | 必须验证分支和 SHA |
| a1z-teleop | 指定仓库，按其 `setup.sh` 安装插件 | 外部 checkout | 必须验证 SHA 和插件注册 |
| hw-r2c-sdk | CloudRobo 控制台提供的最新官方包 | 用户手动提供路径 | `MANUAL STEP REQUIRED` |
| GPU | 只在实际使用时相关 | VMware 当前不作为强制项 | 无 GPU 只输出 `SKIP` |

官方 A1Z 页面还说明 LeRobot 0.6.1 的 PyPI Linux wheel 会带 CUDA 12.x 版 Torch；页面中的旧驱动/cu118分支是条件性说明。本项目不根据 VM 是否有 GPU 自动更换 Torch、CUDA、驱动或内核。

## 2. 当前本地仓库状态

本地工程根目录为 `juesai/`。外部源代码只在未来 Ubuntu VM 的用户指定外部目录中 checkout，不复制进本仓库。脚本默认使用：

```text
~/miniforge3
~/a1z-workspace/GALAXEA-A1Z
~/a1z-workspace/a1z-teleop
```

这些路径没有个人用户名、Windows 路径或凭证。

## 3. 旧 P4 实验的边界

以下内容属于上一轮远程 Tesla P4 实验，不属于新的 A1Z 标准默认环境：

- P4 profile；
- `cu118`；
- `TORCH_INDEX_URL`；
- NVIDIA Driver 550；
- P4 的 Python 3.10、内核和显卡兼容性判断。

它们不能触发新脚本的任何自动分支。当前标准安装入口不读取这些变量，不安装指定 CUDA wheel，不降级 Torch，不修改 Driver，也不升级 Kernel。

## 4. 未在本阶段执行的内容

本阶段没有进入 VMware、没有 SSH、没有执行 `pip`/`conda`/`apt`/`wget`/`git clone`，没有下载依赖，没有执行 A1Z、CAN、Star-Arm、Camera 或 Calibration 命令。安装脚本和命令仅作为未来在 Ubuntu VM 中执行的工程材料。

## 5. 后续审计口径

在 Ubuntu VM 中执行安装后，应运行 `scripts/verify_env.sh`。该脚本只读取版本、导入和 Git 状态；GPU 与所有真机相关项目在没有设备时标为 `SKIP`，不会因为 GPU 缺失而改动软件版本。
