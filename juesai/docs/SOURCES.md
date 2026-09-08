# Phase 1 来源清单

以下来源用于本阶段的环境和代码审计。日期以本次审计为准（2026-09-08）。

## 华为云官方文档

- [A1Z 当前官方 SDK 页面](https://support.huaweicloud.com/sdkreference-cloudrobo/zh-cn_topic_0000002713194086.html)：当前规范，页面更新时间 2026-09-04；要求 Ubuntu 22.04/24.04、Python 3.12、LeRobot 0.6.1，并说明 A1Z、a1z-teleop 与 r2c SDK 的安装方式。
- [用户提供的 A1Z 页面旧地址](https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0042.html)：本次访问已返回 404，已用上面的当前官方页面替代，不猜测旧页面内容。
- [连接机器人](https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0003.html)：CloudRobo 控制台建机器人、下载凭据和连接流程。
- [配置软件环境](https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0002.html)：CloudRobo SDK 包从控制台获取；其中旧的通用 LeRobot 0.5.1 说明不作为 A1Z 当前版本依据。

## 代码与发行包

- [GALAXEA-A1Z](https://github.com/userguide-galaxea/GALAXEA-A1Z/tree/gripper)，`gripper` 分支固定 commit：`e931ecd0e25ad35df251097ba42921b3d2fa7224`。
- [a1z-teleop](https://github.com/suhanwu/a1z-teleop)，`main` 分支固定 commit：`c3275a32951a52f4a7d9e7d9976eb687652526ba`。Huawei 页面里的 teleop 地址是占位符，因此本项目使用用户明确提供的仓库地址。
- [Star-Arm-102](https://github.com/servodevelop/Star-Arm-102)，审计 commit：`0896306e40891c3ee4c97228e85dd708d61326de`。仅作参考，不作为 bootstrap 的自动依赖。
- [LeRobot 0.6.1 PyPI](https://pypi.org/project/lerobot/0.6.1/)：要求 Python `>=3.12`；本审计记录 wheel SHA256：`1894516040c65f80a45bd9741f8174aae90ed5d93da0627ab4f1a85fd8d75e90`。
- [Miniforge 官方 releases](https://github.com/conda-forge/miniforge/releases)：本脚本固定 Linux x86_64 版本 `26.5.3-0`，安装器 SHA256：`14db468222ad564658656f769506056209b6dc375f5e7dfd31eb5ebbf08fa529`。

## 重要边界

第三方仓库的本地副本、r2c SDK 压缩包、数据集、checkpoint 和凭据不是本仓库来源，也不应提交。r2c SDK 没有被猜测为 GitHub 依赖，必须以 CloudRobo 控制台提供的官方包为准。
