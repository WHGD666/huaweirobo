# Phase 1 迁移说明

上一版 Phase 1 曾以远程 Tesla P4 为临时 Linux 节点，并包含针对旧驱动的兼容性实验。该方案已经冻结为历史记录，不再作为决赛 A1Z 标准环境。

当前标准入口和验收口径见：

- [A1Z_ENV_AUDIT.md](A1Z_ENV_AUDIT.md)
- [A1Z_DOWNLOAD_CHECKLIST.md](A1Z_DOWNLOAD_CHECKLIST.md)
- [A1Z_INSTALL_GUIDE.md](A1Z_INSTALL_GUIDE.md)
- [SOURCES.md](SOURCES.md)

当前入口只面向 Ubuntu VM 的软件安装，目标为 Python 3.12、`lerobot061`、LeRobot 0.6.1、ffmpeg、A1Z 固定候选 commit `366e523ab4e4331efd2337f302ce48e559e89194` 和 a1z-teleop 插件。旧 `gripper` / `e931ecd0e25ad35df251097ba42921b3d2fa7224` 作为已验证基线保留记录。它不修改 CUDA/Torch/Driver/Kernel，不连接远程服务器，不执行任何真机命令。

`scripts/bootstrap.sh` 仅作为兼容转发入口，实际执行 `scripts/install_a1z_official.sh`；新流程不再包含 P4、cu118 或 `TORCH_INDEX_URL` 自动分支。
