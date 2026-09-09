# 环境入口说明

本文件保留为旧 Phase 1 文档入口。当前标准以以下文件为准：

- [A1Z_ENV_AUDIT.md](A1Z_ENV_AUDIT.md)：官方要求、目标 VM 和历史实验边界；
- [A1Z_DOWNLOAD_CHECKLIST.md](A1Z_DOWNLOAD_CHECKLIST.md)：来源、版本、下载和现场依赖清单；
- [A1Z_INSTALL_GUIDE.md](A1Z_INSTALL_GUIDE.md)：Ubuntu 22.04 安装顺序；
- [SOURCES.md](SOURCES.md)：逐项来源和命令映射。

唯一推荐的软件安装入口为：

```bash
bash scripts/install_a1z_official.sh
bash scripts/verify_env.sh
```

旧的远程 P4、cu118、`TORCH_INDEX_URL`、Driver 550 兼容方案属于历史实验，不再是 A1Z 默认环境依据。当前标准脚本不会读取、设置或自动推断这些内容；VMware 无 GPU 时仅输出 `SKIP`。

真机相关步骤（SocketCAN、CAN、相机、标定、Star-Arm 和遥操作）不属于普通安装流程，必须按 `A1Z_DOWNLOAD_CHECKLIST.md` 的现场章节执行。
