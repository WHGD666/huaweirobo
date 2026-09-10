# PHASE2 LOCAL VERIFY REPORT

_2026-09-11 · 上位机环境验证(软件阶段, 无真机)_

## Environment

- OS: Ubuntu 22.04.5 LTS (jammy), kernel 6.8.0-138-generic (VMware VM)
- Python: 3.12.14 @ /home/car/miniforge3/envs/lerobot061/bin/python
- Conda env: lerobot061 (base = miniforge3, conda 26.5.3)
- LeRobot: 0.6.1
- R2C SDK: hw-r2c-sdk 0.1.90
- a1z (installed pkg, informational): 0.0.1
- Torch: 2.11.0+cu130 (torch.version.cuda=13.0; cuda_available=False — VM 无 GPU, 正常)

## Git

- huaweirobo branch: codex/a1z-official-env
- huaweirobo HEAD (after merge): 641d26c (merge: migrate GALAXEA-A1Z SDK to safety port fixed commit)
  - 已包含 72bbbbd feat: migrate GALAXEA-A1Z SDK to safety port fixed commit
- juesai/huanjing 保持未动(三方合并单新提交合入), 工作树 clean
- GALAXEA-A1Z commit: **e931ecd** (branch: gripper) — **非目标 366e523**
  - 目标固定: 366e523ab4e4331efd2337f302ce48e559e89194 (feat/cross-platform-g1z-fixes)

> 注: 迁移文档/脚本已更新为固定 366e523; 但本机 SDK 仍停留在旧基线 gripper/e931ec(按Phase3规范, 不做 checkout/自动迁移, 等待现场部署时由 install_a1z_official.sh 安装到 366e523)。

## Tests

| 项目 | 结果 |
|------|------|
| git merge | PASS (clean, HEAD 641d26c) |
| SDK commit check | MISMATCH (SDK 当前 e931624 目标 366e523, 预计现场迁移前保持) |
| python import | PASS (3.12.14) |
| lerobot import (0.6.1) | PASS |
| a1z import (installed 0.0.1) | PASS |
| r2c import (0.1.70) | PASS |
| verify_env.sh | 部分PASS (唯一 FAIL = A1Z commit mismatch, 预期) |

## Hardware

- No hardware test executed.
- Reason: No A1Z robot available before onsite deployment.

## Notes

- 软件环境得到一次性合并后全部通过(A1Z SDK commit 除外)。
- 现场部署真机时, 需执行迁移后的 install_a1z_official.sh 将 SDK 固定到 366e523, 再跑 verify_env.sh 应全绿。