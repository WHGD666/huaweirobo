# 2026 华为云具身智能大赛·真机决赛

本目录是本项目唯一进入 Git 仓库的工程目录。仓库外的
`a1z-teleop-main` 和 `GALAXEA-A1Z-gripper` 仅作为本地参考，不参与提交。

当前阶段是 Phase 1：完成官方资料审计、可重建的软件环境入口、无硬件环境验证和工程记录。标准 A1Z 软件环境以 Ubuntu VM 为预演节点，正式模型训练使用 CloudRobo 的 Ascend 910B。

## Ubuntu VM 软件初始化

将本目录复制到 Ubuntu VM 后，在 `juesai` 目录执行：

```bash
bash scripts/install_a1z_official.sh
bash scripts/verify_env.sh
```

脚本只安装软件依赖和 Python 包，不会初始化 CAN、不连接机器人、不标定、不采集数据，也不会下载数据集或模型。`r2c_sdk` 必须从 CloudRobo 控制台获取；没有官方包路径时脚本会明确报告 `MANUAL STEP REQUIRED`，不会猜测下载地址。

环境和来源审计见：

- [`docs/A1Z_ENV_AUDIT.md`](docs/A1Z_ENV_AUDIT.md)
- [`docs/A1Z_DOWNLOAD_CHECKLIST.md`](docs/A1Z_DOWNLOAD_CHECKLIST.md)
- [`docs/A1Z_INSTALL_GUIDE.md`](docs/A1Z_INSTALL_GUIDE.md)
- [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md)
- [`docs/SOURCES.md`](docs/SOURCES.md)
- [`docs/PHASE1_REVIEW.md`](docs/PHASE1_REVIEW.md)
