# FILES.md — 目录文件来源与用途

> 每一行: 本目录文件 → 来源 → 用途 → 是否原文件副本。

## 顶层
| 文件 | 来源 | 用途 | 副本? |
|------|------|------|-------|
| README.md | 本归档新建 | 环境总说明/黄金基线/恢复步骤/安全 | 新建(非副本) |
| COMMANDS.md | 本归档新建 | 现场常用命令速查(只读) | 新建 |
| FILES.md | 本归档新建 | 本说明文件 | 新建 |
| .gitignore | 本归档新建 | 敏感文件/大文件保护 | 新建 |

## manifests/ (本归档生成的实采信息)
| 文件 | 来源 | 用途 |
|------|------|------|
| manifests/system-info.txt | 实采命令输出 (uname/lsb_release/python/conda/pip/import) | 记录当前机器准确版本 |
| manifests/source-revisions.md | 实采自 ~/a1z-workspace/* (git branch/commit) + R2C 归档元数据 | GALAXEA-A1Z / a1z-teleop / R2C 基线归档 |

## baseline/ (safety-port-202608 迁移前环境快照)
| 文件 | 来源(COPY) | 用途 | 副本? |
|------|------------|------|-------|
| conda-list-before-safety-port.txt | ~/a1z-workspace/baseline/conda-list-before-safety-port.txt | 迁移前 conda 环境快照, grep -E 'password|...' 无敏感 | **原文件副本(COPY, 原件保留)** |
| pip-freeze-before-safety-port.txt | ~/a1z-workspace/baseline/pip-freeze-before-safety-port.txt | 迁移前 pip 冻结清单 | **原文件副本(COPY, 原件保留)** |

## scripts/ (COPY 自 juesai/scripts/) — 均为原脚本副本, 未改动
| 文件 | 来源 | 用途 |
|------|------|------|
| install_a1z_official.sh | juesai/scripts/ | A1Z 软件环境唯一安装入口(Miniforge→lerobot061→LeRobot→拉取 GALAXEA-A1Z gripper 分支 + a1z-teleop main → setup) |
| install_r2c_official.sh | juesai/scripts/ | 仅安装用户提供的官方 R2C SDK 源码目录 (pip install -e) |
| verify_env.sh | juesai/scripts/ | 只读校验环境(OS/kernel/conda/包/插件/R2C/Torch)；不触硬件 |
| bootstrap.sh | juesai/scripts/ | 兼容转发入口, 仅调用 install_a1z_official.sh |

> 路径说明: 以上脚本均用 `$HOME` + 环境变量(`MINIFORGE_DIR/A1Z_WORKSPACE/JUESAI_ENV_NAME`)默认值, 无硬编码绝对路径, 换机可复现。副本未经任何修改。

## docs/ (COPY 来源 juesai/docs/)
| 文件 | 来源 | 用途 |
|------|------|------|
| A1Z_ENV_AUDIT.md | juesai/docs/ | 决赛 A1Z 标准软件环境审计(CPU/内存/OS/磁盘) |
| A1Z_DOWNLOAD_CHECKLIST.md | juesai/docs/ | 下载安装清单(Miniforge/conda/LeRobot/A1Z/teleop/R2C) |
| A1Z_INSTALL_GUIDE.md | juesai/docs/ | 分阶段安装指南(软件安装 + 真机步骤) |
| SOURCES.md | juesai/docs/ | 来源与命令映射(官方文档/仓库优先级) |
| ENVIRONMENT.md | juesai/docs/ | 环境入口说明 |
| PHASE1_REVIEW.md | juesai/docs/ | Phase1 历史说明(旧 P4 方案已冻结) |

## configs/
- 预留目录。**当前不包含**任何配置文件。
  * 部署用的 r2c.json / runtime 配置与 CloudRobo 云端及设备绑定, 属现场部署内容, 且可能含敏感字段, 故不在此归档。
  * 后续确有"非敏感、可复现"的配置再放入, 并更新本文。

---

## 未包含在本归档的内容(有意排除)
| 项 | 原因 |
|----|------|
| CloudRobo 证书包 (cert_config_Robot-*.zip) | **凭证/私钥/口令, 绝不进入 Git** (见 .gitignore / README 安全) |
| *.pem / *.key / *.p12 / *.pfx | 私钥/证书, 绝不进入 Git |
| R2C SDK tar.gz (hw_r2c_sdk-0.1.90.tar.gz) | vendor 源码包, 不纳入 Git; 仅记录 hash |
| conda 环境目录 (~/miniforge3/envs/lerobot061) | 体积巨大, 用 conda-list + pip-freeze 对其复现 |
| GALAXEA-A1Z / a1z-teleop 源码目录 | vendor 源码, 版本用 manifests/source-revisions.md 记录 |
| 大型数据集 / 模型权重 / Docker 镜像 | 体积与版权, 不入 Git |
| .git / cache / __pycache__ | 无意义噪音 |

> 绝对路径仅出现在 baseline/pip-freeze(Copy 自权威快照, 如实保留其本机路径) 与 manifests 说明中, 属真实记录非仓库路径依赖。