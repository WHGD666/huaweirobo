# Phase 1 审计结论

## 已确认

- A1Z 当前官方页面要求 Python 3.12、LeRobot 0.6.1 和官方 A1Z/r2c 链路。
- A1Z `gripper` 分支和 `a1z-teleop` 的可用 commit 已固定，bootstrap 不跟随未知的未来 HEAD。
- P4 只承担临时 Linux 执行和小规模验证；系统 Python 3.10 不被替换。
- 安装脚本不执行任何 CAN 或真实机器人操作，外部 checkout 不进入 Git。

## 需要后续人工确认

1. `r2c_sdk` 只能从 CloudRobo 控制台下载，当前没有可安全固化的公开 URL、版本和 SHA。
2. Huawei 当前 A1Z 页面给出的 `gripper_sign` 为 `+1`，而 `a1z-teleop` 机器人插件默认值审计为 `-1`。这是第三方插件与官方配置的实质差异，不在 Phase 1 擅自修改；进入真机前必须结合实际夹爪方向做单独验证并在项目配置中显式记录。
3. 参考仓库的 `test_teleop.py --dry-run` 仍会连接设备，`scan_can_ids.py` 会发送 CAN 帧；两者都不进入无硬件验证路径。
4. Star-Arm-102 是参考资料，不是本阶段的自动安装依赖。

## 本阶段验收口径

远程节点重建后，`bootstrap.sh` 能完成无硬件的软件安装；`verify_env.sh` 能输出 Python、LeRobot、ffmpeg、A1Z 和插件状态，并把缺失的 r2c 包明确标为 `MANUAL STEP REQUIRED`。任何硬件缺失只应是 WARN，不应促使脚本尝试连接或扫描设备。
