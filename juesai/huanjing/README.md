# A1Z 上位机环境封装

本目录是「华为 CloudRobo / GALAXEA A1Z 决赛上位机环境」的可复现归档。
作用：自己忘装置时看这里能恢复；换一台 Ubuntu 22.04 电脑能按文档重装；比赛现场可快速查询启动/验证命令。

---

## 1. 用途

本 Ubuntu 机器是**上位机环境**, 位于数据链路中的桥梁位置:

```
外围硬件                本机(Ubuntu 上位机)          云端(CloudRobo)
A1Z 机械臂/夹爪   →      LeRobot / R2C        →      云端训练 / 推理
Star Arm 遥操作    →      (观测上行 / R2C action)  →      R2C action ↓
双相机             →                            →      A1Z 执行
```

- **本机角色** = 上位机 + 数据采集桥梁 + R2C 通信节点。
- **训练 / 推理主要在 CloudRobo 云端** (Ascend 昇腾环境)。
- 不要把本机当训练服务器; VMware 内无 GPU/CUDA runtime 是正常状态, 不要尝试修复。

---

## 2. 当前黄金基线 (safety-port-202608 迁移前)

| 组件 | 版本 / 值 |
|------|-----------|
| OS | Ubuntu 22.04 (22.04.5 LTS, kernel 6.8.0-138-generic) |
| 运行环境 | VMware 虚拟机 |
| Miniforge | ~/miniforge3 (conda 26.5.3) |
| Conda env | `lerobot061` |
| Python | 3.12.14 |
| LeRobot | 0.6.1 |
| R2C SDK | hw-r2c-sdk 0.1.90 |
| GALAXEA-A1Z | branch = `gripper` (黄金基线) |
| a1z-teleop | branch = `main` |

> ⚠️ 这是 **safety-port-202608 迁移前的稳定黄金基线**。
> 比赛方已通知未来将使用 `release/safety-port-202608`, 但配套文件仍在更新,
> **绝对不要现在切换 branch / 升级 A1Z / 重装环境**。详见本文档第 6 节。

> 📌 **Python 版本说明**
> - 上表 Python = **3.12.14** 是本机**黄金基线实测**。
> - 恢复脚本实际用的是 `conda create ... python=3.12` → 约束为 **Python 3.12.x**, 并不严格 pin 到 3.12.14。
> - 因此换机器重建后, patch 版本(3.12.14/3.12.15/…)可能不同, **这属正常**。
> - 切勿因为脚本创建的是 3.12.x 而擅自升级/降级当前已验证环境。

---

## 3. Conda 使用

```bash
# 若新终端能识别 conda:
conda activate lerobot061

# 若出现 "conda: command not found":
source ~/miniforge3/etc/profile.d/conda.sh
conda activate lerobot061
```

Conda 初始化(一次性):
```bash
~/miniforge3/bin/conda init bash     # 之后重新打开 terminal
conda config --set auto_activate_base false   # 关闭自动进入 base
```

> `Key auto_activate_base is an alias of auto_activate` 只是提示, **不是错误**。

---

## 4. 快速环境检查

```bash
python --version
which python
```
预期:
```
Python 3.12.14
/home/car/miniforge3/envs/lerobot061/bin/python
```

导入检查:
```bash
python - <<'PY'
import lerobot
import a1z
from r2c_sdk import ClientConfig, SyncRobotClient

print("lerobot import: PASS")
print("a1z import: PASS")
print("r2c_sdk import: PASS")
print("ClientConfig:", ClientConfig)
print("SyncRobotClient:", SyncRobotClient)
PY
```
预期 3 个 import 均 PASS。

---

## 5. 完整 verify(只读)

仓库提供只读校验脚本(不走硬件、不改源、不联网安装):
```bash
source ~/miniforge3/etc/profile.d/conda.sh
conda activate lerobot061
bash scripts/verify_env.sh
```
> 本基线已实际运行验证, 达到:**0 failure(s), 0 manual step(s)**(2026-09-09)。
> 注意: 这是"软件环境"验证; 真机硬件(CAN/相机/夹爪/StarArm) 本脚本按设计 SKIP, 需现场有硬件后再验证。

---

## 6. A1Z SDK

- **当前基线**: `gripper`(已安装, 命令等价于 GALAXEA-A1Z 的 gripper 分支)
- **未来比赛方指定**: `release/safety-port-202608`
- **当前迁移状态**: 等待比赛方官网 / 配套 a1z-teleop / Linux 配置更新后再迁。

> ⚠️ 警告:
> **不要** 现在自动 `checkout safety-port-202608`。
> **不要** `pip reinstall` 重装 A1Z / LeRobot。
> **不要**升级环境。

---

## 7. R2C SDK

- 版本: `hw-r2c-sdk 0.1.90`
- 源码目录(本机): `~/a1z-workspace/r2c_sdk_0.1.90/r2c_sdk_python`
- 官方安装包: `hw_r2c_sdk-0.1.90.tar.gz`(由 CloudRobo 控制台下载,**不纳入 Git**)
- SHA256: `366998a0d9748bdc237d2aa6a98d3a5c28f8747c6963bb4d3e1d1f4c8fa9a6f7` *(详见 manifests/source-revisions.md; 本机已核对 PASS)*

安装方式(需要官方包, user 提供路径):
```bash
export R2C_SDK_PATH=~/a1z-workspace/r2c_sdk_0.1.90/r2c_sdk_python
bash scripts/install_r2c_official.sh
```
验证:
```bash
python -c 'import r2c_sdk; from r2c_sdk import ClientConfig, SyncRobotClient; print("OK")'
```

> 🔒 敏感: CloudRobo console 下载的凭证包(cert config, 含证书/私钥/口令)
> `cert_config_Robot-<DEVICE>_<TIMESTAMP>.zip`
> **只保存在本地安全位置, 绝不进入 Git**, 也绝不把私钥/密码写进任何 md/txt/shell。
> 本仓库用 `cert_config_Robot-<DEVICE>_<TIMESTAMP>.zip` 这种占位名称记录, 不写真实设备 ID。

---

## 8. 环境恢复步骤(新机器)

> 命令优先引用本目录现有 `scripts/*` 与 `docs/`,不要凭空重写。

1. 安装 Ubuntu 22.04
2. 检查 kernel ≥ 官方要求(`docs/A1Z_ENV_AUDIT.md` / `docs/A1Z_INSTALL_GUIDE.md`)
3. 安装 Miniforge → `scripts/install_a1z_official.sh`(会创建 env `lerobot061`: 脚本约束 Python **3.12.x**, 本机实测为 3.12.14; 并装 LeRobot 0.6.1)
4. 安装 GALAXEA-A1Z(由 install_a1z_official.sh 拉取 gripper 分支)
5. 安装 a1z-teleop 插件(由 install_a1z_official.sh 拉取 main)
6. 安装 R2C SDK → `scripts/install_r2c_official.sh`(需先手动获得官方包)
7. 全量 verify → `bash scripts/verify_env.sh`
8. 真机现场再配置 CAN / Camera / StarArm(见第 9 节, 不到场不执行)

> 具体每步命令与来源请务必看:
> - 脚本: `install_a1z_official.sh` / `install_r2c_official.sh` / `verify_env.sh`
> - 文档: `docs/*.md`

---

## 9. 现场启动速查(极简)

打开终端:
```bash
source ~/miniforge3/etc/profile.d/conda.sh
conda activate lerobot061
```
检查:
```bash
python --version
which python
bash scripts/verify_env.sh
```
之后现场真机步骤只列(未授权不执行):
`USB → CAN → Camera → StarArm → Calibrate → Record → Upload CloudRobo → R2C dry-run → Real closed loop`

> ⚠️ 不在此写未经官方确认的具体 CAN interface 名称(不默认 `can0`); 以现场 `setup_follower_can.sh` 实际输出为准。

---

## 10. VMware 说明

- 当前环境运行于 **VMware Ubuntu 22.04**。
- 软件环境**已验证通过**。
- 现场仍需验证的**硬件链路**:
  - USB-CANFD passthrough
  - Star/UART passthrough
  - 双相机 passthrough
- 准确表述:**软件环境通过; 真实硬件链路待现场设备验证**。不写"VMware 一定支持真机"。

---

## 11. 安全注意事项

A1Z **无机械制动器**, 断电后可能**自由下落**。真机操作:
- 机械臂先移到安全姿态再断电
- 人员离开工作空间
- 初次动作**低速**
- R2C 首次闭环先做 **dry_run**
- 不运行未经验证的大幅动作
- 不在无保护情况下执行回零 / 运动命令(参照 SDK examples 捕获 Ctrl+C, 信号处理内调 `stop()`)

---

## 12. 敏感文件

- **凭证包 / 私钥 / 密码(/token)**: 只保存在本地 (仓库外) 安全位置。
- **绝不**: 复制进本仓库 / `git add` / `commit` / `push`。
- 提交前扫描: `grep -RniE 'password|private[_ -]?key|BEGIN .*PRIVATE KEY|token|secret|cert_config' .`
- 保护规则见目录内 `.gitignore`。

---

*生成日期: 2026-09-09 · 记录方式: 实采 + 从现有仓库脚本引用 · 更多清单:另见 `COMMANDS.md` 与 `FILES.md`*