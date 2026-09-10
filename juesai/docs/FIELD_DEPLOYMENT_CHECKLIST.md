# FIELD DEPLOYMENT CHECKLIST — A1Z 决赛现场资料与流程清单

> 用途: 比赛现场出发前核对"带什么 + 到了按什么顺序做"。本 VM 是**赛后备用环境**,不是日常开发机;清单目标是把现场从开机到出数据的顺序固定下来。
> 参考: 环境基线/版本见 README.md 与 manifests/source-revisions.md; 本机仓库为 backup。

## 一、现场前(出发核对)

### 软件
- [ ] Ubuntu 22.04 VM 镜像/快照(自带一台即可)
- [ ] VMware(Workstation/Player 安装包)
- [ ] Miniforge 安装包(`Miniforge3-Linux-x86_64.sh`, 及清华镜像/GitHub 回退源)
- [ ] huaweirobo 仓库(本地克隆, 最新提交已提交/拉下)
- [ ] 环境脚本 (`juesai/scripts/{bootstrap,install_a1z_official,install_r2c_official,verify_env}.sh`)
- [ ] SDK 版本记录(`manifests/source-revisions.md` / 本文档 Git 区; A1Z 目标 commit 366e523)

### 数据
- [ ] 数据集备份(官方 REAL/SIM, 现场自采可上传 OBS 或注册空间资产)
- [ ] 模型权重(训练产物/部署用模型)
- [ ] 配置文件(`r2c.json`、相机键名/对齐字段、gripper_sign 约定)

### 硬件
- [ ] 笔记本(上位机) + 电源
- [ ] 移动硬盘(数据与 CMV 快照备份)
- [ ] USB Hub
- [ ] 网线 / 无线路由(或用 局域网/热点)
- [ ] 转接头(USB-C/USB-A、HDMI 等, 按现场设备)

## 二、到现场(执行顺序)

1. 开电脑, 确认电量/电源
2. 启动 VM(确认快照/磁盘正常)
3. `git pull --ff-only`(拉到最新, 仅此支线; 有未提交改动先 stash/确认)
4. `conda activate lerobot061`(`source ~/miniforge3/etc/profile.d/conda.sh` 若未激活)
5. `bash juesai/scripts/verify_env.sh`(软件环境自检, 只读)
6. 安装最终 SDK(现场部署时才执行; 把 A2Z 固定到目标 commit — 见"部署提示")
7. 下载/连接机器人(CloudRobo 控制台取凭证 bundle + R2C SDK 包)
8. 测试 R2C(仅软件 import + dry-run; 首次闭环前必须 dry_run)
9. 部署模型(在 VM 装好模型服务 + r2c.json, 线上闭环)

### 部署提示(现场, 非本 backup 环境日常)
- 在正式部署机把 GALAXEA-A1Z 固定到 `feat/cross-platform-g1z-fixes@366e523…`, 用仓库安装脚本 `install_a1z_official.sh`, 不要用动态 branch/micro.
- 先做 `verify_env.sh` 全绿, 再连人连机; R2C 首次闭环先 `dry_run`。
- 禁止: 现场无授权的运动/CAN/电机/机器人/相机动作(本节仅为对照清单, 具体命令属真机阶段)。

> 本 VM 现有状态为赛后备用环境: 软件层已验证, 硬件链路(USB-CANFD, Star/UART, 双相机 passthrough)未测, 现场按本清单与真机流程执行。

_生成: 2026-09-11_