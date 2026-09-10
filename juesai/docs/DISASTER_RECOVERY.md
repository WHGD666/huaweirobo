# DISASTER RECOVERY — 一键恢复流程

> 目标: 现场电脑/VM 完全损坏时, **4 小时内**从零重建可用上位机环境。
> 原则: 一切以仓库内的脚本为准, 不依赖记忆里的"手工步骤"; 只做软件环境重建, 不碰真机/CAN/机械臂。
> 前提: 只有一台能连网的普通 Ubuntu 机器 或 现场电脑。

## 0. 恢复总流程(从零)

```
安装 Ubuntu 22.04  (约2.5h含下载)
   ↓
安装 Miniforge
   ↓
git clone 仓库   (huaweirobo)
   ↓
运行 bootstrap   (→ 转发到 install_a1z_official.sh)
   ↓
安装环境          (创建 lerobot061, LeRobot, A1Z 到固定 commit)
   ↓
安装 R2C SDK      (需控制台取的官方包, R2C_SDK_PATH)
   ↓
运行 verify_env.sh (全绿为成功)
```

目标 4 小时达成; 若硬盘/网络极差, 至少按此顺序推进, 避免回退。

## 1. 安装 Ubuntu 22.04

- 用 Ubuntu 22.04 ISO, 装到干净的虚拟机(VW/VirtualBox)。
- 检查内核 ≥ 6.8.0(见 `docs/A1Z_ENV_AUDIT.md`; 低于则按官方要求升级)。

## 2. 安装 Miniforge

```bash
# 清华镜像优先, GitHub 回退(install_a1z_official.sh 内部也是这样)
wget https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh -b -p "$HOME/miniforge3"
```

## 3. clone 仓库

```bash
git clone https://github.com/WHGD666/huaweirobo.git
cd huaweirobo
```

## 4. 运行 bootstrap(唯一入口)

```bash
cd juesai
bash scripts/bootstrap.sh
```

> `bootstrap.sh` 会转发到 `scripts/install_a1z_official.sh`, 它负责: 校验 OS/内核 → 建 `lerobot061`(Py3.12) → 装 ffmpeg/LeRobot 0.6.1 → 拉取 GALAXEA-A1Z(固定 commit) + a1z-teleop → 安装 a1z plugin → 记录源码版。

## 5. 安装 R2C SDK(需手工取官方包)

```bash
export R2C_SDK_PATH=/path/to/r2c_sdk_0.1.90/r2c_sdk_python   # 解压自 CloudRobo 控制台下载的包
bash scripts/install_r2c_official.sh
```

> r2c SDK 无法自动下载; 必须从控制台取得 `hw_r2c_sdk-0.1.90.tar.gz`(SHA256 记在 source-revisions.md), 解压后给 `R2C_SDK_PATH`。

## 6. 验证(以绿为目标)

```bash
source ~/miniforge3/etc/profile.d/conda.sh
conda activate lerobot061
bash scripts/verify_env.sh      # 期望 A1Z commit == 目标固定值; 全部 PASS
```

- `verify_env.sh` 整合: OS/kernel/conda/env/Python/LeRobot/import/plugin/R2C/Torch + Git 固定 commit。
- 若某个 FAIL 且为"硬件相关" → 属现场才验证, 记录即可; 若为软件项 → 回到对应步骤重查。

## 7. 现场恢复后的交接

1. 软环境全绿后, 再进真机流程(接证书/R2C/相机/CAN/夹爪), 一步一件、只读起步。
2. 若时间紧张, 优先保住: 软件环境可跑 + 数据/模型可找回 + 启动顺序正确。

## 常见故障(快速分流)

| 症状 | 处理 |
|------|------|
| conda: command not found | `source ~/miniforge3/etc/profile.d/conda.sh` |
| 找不到 lerobot061 | 重跑 `install_a1z_official.sh`(会创建) |
| R2C_SDK_PATH 校验失败 | 确认提供的官方源码目录, 别猜地址 |
| verify 出现设备专项 FAIL | 记录 hardware unavailable-expected, 不修 |
| git pull 冲突 | 有本地未提交改动 → 先 stash/确认, 不覆盖 |

> 本说明面向"现场电脑炸掉后的重建"; 这台 VM 是 backup 环境, 日常不在此 rollout 上面列到的现场步骤。

_生成: 2026-09-11_