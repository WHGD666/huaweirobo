# 华为 CloudRobo 真机决赛工作流与上位机合并说明

> **文档用途**
>
> 本文档只服务于本次华为 CloudRobo 具身智能真机决赛，不做 CloudRobo 全平台通用教程。
>
> 它同时也是给 Codex / 后续工程协作者使用的“长提示词”和项目状态说明。目的不是让 Codex 重新设计 CloudRobo 平台流程，而是让它在完成本地 VM / 上位机环境配置后，能够准确理解：
>
> - 当前比赛任务是什么；
> - CloudRobo 平台端已经完成了什么；
> - 上位机端应该负责什么；
> - 两条线最终在哪里合并；
> - 后续模型训练、部署、真机调试和现场数据回流应该怎么推进。
>
> **重要边界**
>
> - **CloudRobo 平台线**：数据资产、数据处理/合并、模型训练、模型资产、模型部署、模型评测、机器人管理、智能体调试等。
> - **上位机线**：A1Z SDK、LeRobot A1Z 插件、r2c_sdk、CAN、相机、标定、Star Arm 遥操作采集、机器人端配置与真机安全。
> - 两条线最终在 **“模型服务 + r2c.json + 机器人在线 + R2C 观测/动作闭环”** 处汇合。
>
> 当前不要求 Codex 代替 CloudRobo 平台做模型训练，也不要求自行搭建训练服务器、推理服务器或数据平台。

---

# 1. 比赛任务背景

本次为华为 CloudRobo 具身智能真机决赛。

核心机器人平台为：

- **星海图 Galaxea A1Z 六轴机械臂**
- **G1Z 夹爪**
- 真实比赛任务：桌面清理 / 物体整理
- 桌面存在若干不同类别、不同几何形态的物体
- 最终目标是让机械臂连续抓取桌面物体，并放入收纳容器 / 胶框
- 比赛强调的不只是单次 Pick & Place，而是多物体、连续操作、视觉泛化和真机稳定性

官方提供：

1. A1Z 仿真场景与自动生成轨迹能力
2. 官方仿真数据集
3. 官方真机实采数据集
4. CloudRobo 模型训练能力
5. CloudRobo 模型部署与云端推理能力
6. R2C SDK 真机接入方案
7. A1Z SDK / LeRobot 插件 / Star Arm 遥操作采集方案
8. 真机现场采集后的数据回流与重训能力

比赛主线不是自行从零搭建一个具身平台，而是在华为提供的 CloudRobo 平台上完成：

```text
数据
→ 模型
→ 部署
→ 真机
→ 数据回流
→ 再训练
```

的完整闭环。

---

# 2. 官方资料优先级

后续所有工作优先以华为官方资料和比赛指定仓库为准，不凭经验自行创造版本和接口。

推荐优先级：

1. **A1Z 专属官方章节**
2. **CloudRobo 用户指南**
3. **CloudRobo 最佳实践**
4. **CloudRobo 快速入门**
5. **CloudRobo SDK 参考**
6. **比赛能力总览 / 决赛说明**
7. 其他机器人官方案例仅作为迁移参考，不直接照抄

当前主要官方文档包括：

- 《具身智能开发平台 CloudRobo 用户指南》
- 《具身智能开发平台 CloudRobo SDK 参考》
- 《具身智能开发平台 CloudRobo 快速入门》
- 《具身智能开发平台 CloudRobo 最佳实践》
- 《具身大赛真机赛 - CloudRobo 平台能力总览》

已知官方在线页面：

- A1Z 支持说明
  https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0042.html
- 接入机器人
  https://support.huaweicloud.com/sdkreference-cloudrobo/cloudrobo_03_0003.html

指定仓库：

- GALAXEA A1Z SDK（必须使用 gripper 分支）
  https://github.com/userguide-galaxea/GALAXEA-A1Z/tree/gripper
- Star Arm 102
  https://github.com/servodevelop/Star-Arm-102
- A1Z Teleop
  https://github.com/suhanwu/a1z-teleop

---

# 3. 对 CloudRobo 在比赛中角色的正确理解

CloudRobo 不是一个单纯的“训练按钮页面”，也不是直接跳过真实机器人接口的黑盒。

它在本次比赛中承担的是云端平台和 AI 生命周期管理：

```text
官方 / 自采数据
    ↓
数据资产
    ↓
数据处理 / 合并
    ↓
模型训练
    ↓
模型资产
    ↓
模型部署
    ↓
云端推理服务
    ↓
R2C
    ↓
真实 A1Z
```

真实机器人部分仍然需要上位机：

```text
A1Z / G1Z / Camera / CAN
        ↕
LeRobot A1Z Plugin
        ↕
A1Z SDK
        ↕
r2c_sdk
        ↕
CloudRobo
```

因此，“平台上大部分操作是点按钮”与“需要配置上位机环境”并不冲突。

正确理解是：

> **CloudRobo 把通用的数据管理、训练、部署、推理基础设施封装成平台；上位机负责连接真实世界。**

---

# 4. 两条开发线路

## 4.1 线路 A：CloudRobo 平台线

由 ChatGPT / 人工操作平台推进，重点负责：

- 具身广场资产确认
- 官方 SIM / REAL 数据使用
- 数据处理
- 数据合并
- 模型选型
- 模型训练
- 训练指标和日志
- 模型版本管理
- 模型部署
- r2c.json 模型特征映射
- 仿真模型评测
- 机器人资产管理
- 智能体调试
- 真机数据回流后重训

---

## 4.2 线路 B：上位机 / VM / 真机线

由 Codex 主要负责，重点包括：

- Ubuntu / Linux 环境
- A1Z SDK
- LeRobot 0.6.1 A1Z 插件
- r2c_sdk
- Star Arm 102
- a1z-teleop
- CAN
- 相机
- 标定
- gripper 方向
- 机器人端配置
- CloudRobo credential bundle
- cloudroboclient
- 真机在线
- dry_run
- 观测上行
- 动作闭环

---

## 4.3 两条线汇合点

只有以下条件同时满足，才算真正实现端到端闭环：

```text
CloudRobo 侧：
模型训练完成
    ↓
模型资产生成
    ↓
模型服务部署完成
    ↓
模型服务“运行中”
    ↓
r2c.json 已正确配置

上位机侧：
A1Z / Camera / CAN 正常
    ↓
r2c_sdk 正常
    ↓
robot config 正确
    ↓
CloudRobo 中机器人“在线”
    ↓
观测上行正常

两者汇合：
智能体调试
    ↓
Prompt
    ↓
云端推理
    ↓
Action Chunk
    ↓
R2C
    ↓
A1Z 真机执行
```

---

# 5. 当前 CloudRobo 端已确认的比赛资产

## 5.1 仿真场景

已在：

`具身广场 → 仿真 → 场景`

中确认：

**星海图 A1Z 清理桌面**

场景中存在多类刚性物体，并可用于仿真、数据生产和后续模型评测。

该仿真场景与初赛附加题中的“自动生成轨迹”能力属于同一类平台能力，但在决赛中的用途不同：

初赛：

```text
自动生成轨迹
→ 轨迹成功
→ 附加分
```

决赛：

```text
自动生成轨迹
→ 新增 SIM 数据
→ 数据资产
→ 合并 / 训练
→ 提高策略泛化
```

因此决赛中不应把自动轨迹生成本身当成最终目标，而应把它视为：

> **仿真数据生产工具**

---

# 6. 官方比赛数据集现状

当前已确认两套官方比赛数据，均为 LeRobot Dataset v3。

---

## 6.1 REAL 数据

数据集：

`COMPETITION_Galaxea_A1Z_Clean_Up_Desktop-REAL-DATASET`

已确认：

- codebase_version: `v3.0`
- robot_type: `galaxea_a1z_follower`
- total_episodes: `165`
- total_frames: `80,826`
- total_tasks: `1`
- fps: `10`
- state: 7 维
- action: 7 维
- 6 个关节 + 1 个 gripper
- external camera: `960 × 540`
- wrist camera: `640 × 480`

任务 Prompt 示例：

```text
pick up all objects on the desk and put them in the storage box on the left
```

主要特征：

```text
observation.state
action
observation.images.cam_external
observation.images.cam_wrist
timestamp
frame_index
episode_index
index
task_index
```

状态和动作均对应：

```text
joint_1
joint_2
joint_3
joint_4
joint_5
joint_6
gripper
```

REAL 一条 episode 是连续多物体整理轨迹，而不是“一条 episode 只抓一个物体”。

---

## 6.2 SIM 数据

数据集：

`COMPETITION_Galaxea_A1Z_Clean_Up_Desktop-SIM-DATASET`

已确认：

- codebase_version: `v3.0`
- robot_type: `null`
- total_episodes: `1008`
- total_frames: `1,977,670`
- total_tasks: `1`
- fps: `10`
- state: 7 维
- action: 7 维
- external camera: `960 × 540`
- wrist camera: `640 × 480`

Prompt 示例：

```text
Pick up all objects on the desktop and place them into the container one by one.
```

主要作用：

- 提供大规模轨迹覆盖
- 提供物体位置随机化
- 提供场景 / 物体组合变化
- 提供额外行为示范

---

# 7. SIM 与 REAL 的已知差异

两套数据整体任务一致，但不是完全相同的采集域。

重要差异：

1. REAL 165 episodes，SIM 1008 episodes
2. REAL 约 8 万帧，SIM 约 198 万帧
3. SIM 的 episode 平均明显更长
4. SIM 是理想仿真运动，REAL 含真实机器人跟随误差
5. SIM 与 REAL 的视觉风格存在明显 Sim2Real Gap
6. 两边 Prompt 语义一致但文案不完全相同
7. SIM `info.json` 的 video shape 元数据曾看到 CHW 表示，而 REAL 为 HWC 表示
8. `robot_type` 元数据不一致
9. REAL 的 state / action 真实执行差异比 SIM 更明显

因此：

> 后续做 SIM + REAL 合并时，优先使用 CloudRobo 官方的 LeRobot 数据合并算子，并先验证 schema / fps / features 是否被平台接受，不应未经验证自行拼接目录。

---

# 8. 官方允许的数据来源

决赛材料明确允许以下四类数据自由选择并用于训练：

1. 官方 SIM
2. 官方 REAL
3. 现场自行采集 REAL
4. 自己在 CloudRobo 仿真中生成的 SIM

其中现场 REAL 如果要用于 CloudRobo 训练，应先：

- 上传至 OBS
- 或注册为空间资产-数据

后续可使用平台数据处理能力完成数据管理与合并。

---

# 9. CloudRobo 数据处理策略

当前官方比赛数据已经是 LeRobot V3，因此第一版 baseline 无需为了“使用功能”而强行做格式转换。

未来需要重点使用的 CloudRobo 数据处理能力：

---

## 9.1 LeRobot 数据集合并

路径：

`数据准备 → 数据处理`

优先选择：

`预置算法 → 数据处理--LeRobot数据合并`

用途：

```text
官方 REAL
+
官方 SIM
+
现场 REAL
+
自生成 SIM
↓
统一 LeRobot V3 数据集
```

使用前应核对：

- fps
- feature names
- state / action shape
- camera keys
- task schema
- video metadata

---

## 9.2 数据评测

CloudRobo 支持对 LeRobot V3 数据进行质量评测。

后续自采真机数据进入训练前，应考虑：

```text
采集
→ 注册 / 上传
→ 数据评测
→ 合并
→ 训练
```

避免把明显失败或低质量轨迹直接混入训练集。

---

# 10. 当前模型策略

## 10.1 主线模型

当前主线固定为：

`LeRobot_PI05-Base v0.0.1`

训练方式：

`模型调优`

调优方式：

`全参数微调`

原因：

1. CloudRobo 官方快速入门直接支持此路径
2. 官方最佳实践中的 DAgger 多轮训练使用 PI0.5 路线
3. 任务需要视觉 + 状态 + Prompt → Action
4. 比赛允许自由选择模型和训练方法
5. PI0.5 具备更强的预训练 VLA 表征能力
6. 当前工作空间可以直接使用该预置基模型

---

## 10.2 ACT 的位置

ACT 并没有被否定。

`LeRobot_ACT` 属于：

`无基模型训练`

它适合：

- 单任务模仿学习
- 低成本 baseline
- 固定任务和固定机器人
- 后续作为 PI0.5 对照组

但当前工作空间在：

`无基模型训练 → 预置算法`

中没有显示可用 ACT 算法，因此暂不自行用“现在配置”重写一套 ACT。

后续若平台开放 ACT，建议作为对照实验，而不是取代当前 PI0.5 主线。

---

# 11. 当前已创建的第一版训练作业

截至 2026-09-08 20:06（GMT+08）左右，已创建：

## 作业名

`A1Z-Cleanup-PI05-REAL`

## 源模型

`LeRobot_PI05-Base | v0.0.1`

## 训练方式

`模型调优`

## 调优方式

`全参数微调`

## 数据

`COMPETITION_Galaxea_A1Z-REAL-DATASET`

## 资源

公共资源池

实例规格：

`1 * SNT9B2 | 24 vCPUs | 192 GiB`

实例数：

`1`

## 超参数

```text
batch_size = 32
steps = 100000
save_freq = 10000
policy.chunk_size = 50
policy.n_action_steps = 50
```

第一版全部采用平台默认值，不做额外优化。

## 训练产物

模型名：

`A1Z-Cleanup-PI05-REAL`

版本：

`v0.0.1`

模型类型：

`操作模型`

Checkpoints 最大保留数：

`10`

Checkpoints 保留天数：

`14`

## 当前状态

创建后已完成：

- 作业调度
- 计算资源分配
- 环境准备

当时状态：

`等待中`

实际最新状态以后以 CloudRobo 控制台为准。

---

# 12. 第一版模型的目标

v0.0.1 不是最终比赛模型。

它的作用是建立：

> **官方 REAL 数据 + PI0.5 全参数微调的真实域 baseline**

目标：

```text
确认数据能被读取
→ 确认 PI0.5 能正常训练
→ 训练指标正常
→ checkpoint 正常
→ 模型资产正常
→ 模型部署正常
→ 后续能进入仿真 / 真机闭环
```

因此：

- 第一版不追求超参最优
- 不立即混入 SIM
- 不立即切 LoRA
- 不同时训练多个模型
- 先跑通官方主链

---

# 13. 第一版训练结束后的 CloudRobo 流程

训练成功以后按以下顺序：

---

## 13.1 查看训练结果

路径：

`模型开发 → 模型训练 → A1Z-Cleanup-PI05-REAL`

关注：

- 训练指标
- loss 变化
- 训练日志
- checkpoint
- 是否正常结束
- 是否生成模型资产

---

## 13.2 进入模型资产

训练产物会进入：

`空间资产 → 模型`

模型：

`A1Z-Cleanup-PI05-REAL v0.0.1`

---

## 13.3 部署模型服务

从模型资产详情或训练作业详情进入模型部署。

创建模型服务时必须提交：

`r2c.json`

模型服务必须达到：

`运行中`

---

# 14. A1Z 的 r2c.json 角色

r2c.json 是“模型世界”和“机器人世界”的映射层。

它不属于 A1Z SDK 的底层 CAN 配置，而属于模型部署侧特征映射。

官方 A1Z 示例核心含义：

```text
机器人上行：
observation.joint_states.position
+
images.color.front
+
images.color.wrist

        ↓ r2c.json

模型输入：
observation.state
observation.images.cam_external
observation.images.cam_wrist
task

        ↓ 模型推理

模型输出：
action

        ↓ r2c.json

机器人动作：
arm_joint1
arm_joint2
arm_joint3
arm_joint4
arm_joint5
arm_joint6
gripper
```

A1Z 模型输入核心：

```text
observation.state shape = [7]
cam_external
cam_wrist
task = PROMPT
```

模型输出：

```text
action shape = [7]
```

官方比赛示例的部署 action chunk_size 为 `100`。

注意：

当前 PI0.5 训练超参：

`policy.chunk_size = 50`

而比赛附录中的 r2c 示例：

`action.chunk_size = 100`

后续部署时必须根据实际训练模型输出与 CloudRobo PI0.5 部署要求核对，不能因为两个数字不同就未经确认强行改训练参数。

---

# 15. 上位机侧必须与训练数据对齐的关键字段

Codex 在完成 VM / 上位机配置时必须特别注意：

---

## 15.1 机器人插件

A1Z 通过：

`hardware.type: lerobot`

以及第三方插件：

`lerobot_robot_galaxea_a1z`

注册名：

`galaxea_a1z_follower`

接入。

---

## 15.2 相机键名必须一致

设备侧：

```text
cam_external
cam_wrist
```

训练数据侧：

```text
observation.images.cam_external
observation.images.cam_wrist
```

R2C 上行通道：

```text
images.color.front
images.color.wrist
```

这三个层次不要混淆。

官方特别强调：

> `cam_external` / `cam_wrist` 必须与训练数据 feature 对齐，否则策略服务无法正确完成模型特征映射。

---

## 15.3 关节和夹爪

A1Z：

```text
joint_1 ... joint_6
gripper
```

CloudRobo 上行：

```text
joint_states.position
```

共 7 个元素。

推荐 action / state 坐标：

`absolute_rad`

夹爪：

```text
0 = 闭合
1 = 张开
```

A1Z 官方当前要求：

`gripper_sign: +1`

不要沿用旧配置中的错误方向。

---

# 16. CloudRobo 真机接入主流程

官方 R2C SDK 把真机接入概括为：

1. 准备硬件
2. 配置软件环境
3. 在 CloudRobo 接入机器人
4. 配置端侧
5. 调试智能体

实际比赛版建议如下。

---

## 16.1 CloudRobo 创建机器人

路径：

`运行管理 → 机器人`

创建 A1Z 机器人实例。

完成后下载平台接入配置 / 凭证 bundle。

机器人最终应在平台显示：

`在线`

---

## 16.2 上位机运行 cloudroboclient

上位机必须有：

- A1Z SDK
- LeRobot 0.6.1
- A1Z 插件
- r2c_sdk
- 正确的 `robot_a1z_lerobot_v2_config.yaml`
- CloudRobo credential bundle

典型思路：

```bash
python -m r2c_sdk.cloudroboclient \
  --bundle /path/to/credential_bundle.zip \
  --robot-config config/robot_a1z_lerobot_v2_config.yaml
```

具体参数以当前官方 SDK 版本为准。

---

## 16.3 首次必须先做 dry_run

官方 A1Z 上线检查要求：

- `runtime.dry_run = true`
- 先验证：
  - 插件注册
  - RobotConfig 解码
  - 观测发布
  - 动作映射打印
- 但不让机械臂真正执行云端动作

通过后再改回：

`dry_run = false`

此步骤不能省。

---

# 17. 平台侧真机验证标准

上位机和 CloudRobo 合并后，不要只看“程序没报错”。

至少确认：

---

## 17.1 机器人在线

CloudRobo：

`运行管理 → 机器人`

状态：

`在线`

---

## 17.2 观测上行

平台侧能收到：

- 7 维关节 / 夹爪状态
- external 图像
- wrist 图像

---

## 17.3 模型服务运行

CloudRobo：

`运行管理 → 模型部署`

目标模型服务：

`运行中`

---

## 17.4 智能体调试

在机器人操作列进入：

`智能体调试`

选择：

- 当前模型服务
- Prompt

启动云端推理。

---

## 17.5 动作闭环

流程：

```text
真实图像 / state
→ R2C
→ CloudRobo
→ PI0.5
→ Action
→ R2C
→ A1Z
```

只有这一步完成，才算整套系统真正跑通。

---

# 18. 模型评测

CloudRobo 模型评测依赖：

1. 已部署并处于“运行中”的模型服务
2. 仿真资产

本次可优先使用：

`星海图 A1Z 清理桌面`

模型评测路径：

`模型开发 → 模型评测`

建议用途：

- v0.0.1 baseline 仿真测试
- REAL-only 与 MIX 对比
- 不同模型版本对比
- 不同数据策略对比

注意：

> 仿真成绩不能替代真机成绩，但可以提前筛掉明显无效模型。

---

# 19. 第二阶段数据策略

第一版 REAL baseline 成功后，再开展 SIM + REAL。

建议不要直接覆盖 v0.0.1。

创建独立实验：

## 实验 A

```text
A1Z-Cleanup-PI05-REAL
v0.0.1
官方 REAL
```

## 实验 B

```text
A1Z-Cleanup-PI05-MIX
v0.0.1
官方 REAL + SIM
```

作用：

- 比较 SIM 是否提升泛化
- 避免 MIX 失败时无法定位原因
- 保持实验可追溯

后续根据仿真 / 真机结果再决定主力路线。

---

# 20. 现场自采数据与再训练

这是比赛后期非常重要的官方路径。

真机出现失败后，不是优先手工修改一堆控制代码，而应考虑：

```text
失败场景
→ Star Arm 人类示范 / 接管
→ 采集成功轨迹
→ LeRobot V3
→ 数据评测
→ 合并
→ 重训
```

官方最佳实践采用 DAgger 思路。

---

# 21. DAgger / 数据回流工作流

典型流程：

```text
模型 v0.0.1
    ↓
真机执行
    ↓
失败 / 不稳定场景
    ↓
人类接管
    ↓
采集成功 episode
    ↓
与原训练数据合并
    ↓
上传 OBS / 注册空间资产
    ↓
CloudRobo 模型训练“重训”
    ↓
修改数据集
    ↓
其他参数尽量保持
    ↓
保存为已有模型新版本
    ↓
v0.0.2
```

后续可继续：

```text
v0.0.2
→ 真机
→ 采集第二轮失败场景
→ v0.0.3
```

因此：

> 当前 v0.0.1 绝不是“训练后就固定死的模型”。

官方设计本身就支持多轮训练和版本迭代。

---

# 22. 版本管理建议

建议比赛期间保持明确版本策略。

## 22.1 不同训练策略

不同数据策略建议不同模型资产：

```text
A1Z-Cleanup-PI05-REAL
A1Z-Cleanup-PI05-MIX
A1Z-Cleanup-PI05-SIM
```

## 22.2 同一策略现场增量

同一模型使用版本号：

```text
v0.0.1 赛前 baseline
v0.0.2 第一轮真机回流
v0.0.3 第二轮真机回流
```

不要所有实验都保存到同一个名字同一个版本里。

---

# 23. Codex 在合并工作流时必须理解的边界

Codex 完成 VM / 上位机环境后：

## 不需要重新做

- PI0.5 训练服务器
- Ascend 训练环境
- CloudRobo 模型调优脚本
- 自建模型服务
- 自建数据管理平台
- 自建模型版本管理
- 自行替代 CloudRobo 的部署系统

## 需要完成

- A1Z SDK
- LeRobot A1Z Plugin
- r2c_sdk
- CAN
- Camera
- 标定
- Star Arm
- a1z-teleop
- robot config
- dry_run
- CloudRobo bundle
- cloudroboclient
- 机器人在线
- 观测上行
- 真机动作闭环
- 现场数据采集

---

# 24. Codex 与 CloudRobo 合并时的验收清单

上位机侧完成后，请逐项对齐以下状态。

## 软件层

- [ ] LeRobot 0.6.1
- [ ] Python 3.12 环境
- [ ] GALAXEA A1Z SDK gripper 分支
- [ ] `lerobot_robot_galaxea_a1z`
- [ ] `galaxea_a1z_follower`
- [ ] r2c_sdk
- [ ] Star Arm 插件
- [ ] a1z-teleop

## A1Z 层

- [ ] CAN 可用
- [ ] ID 1–7 可识别
- [ ] follower 标定完成
- [ ] gripper_sign = +1
- [ ] teleop_input = rad
- [ ] cam_external 正确
- [ ] cam_wrist 正确
- [ ] 相机分辨率与数据 / 模型输入匹配
- [ ] 设备路径稳定

## R2C 层

- [ ] `robot_a1z_lerobot_v2_config.yaml`
- [ ] bundle / 平台凭证
- [ ] dry_run 成功
- [ ] 机器人在线
- [ ] observation.state 上行
- [ ] external image 上行
- [ ] wrist image 上行

## CloudRobo 模型层

- [ ] 模型训练成功
- [ ] 模型资产已生成
- [ ] 模型服务运行中
- [ ] r2c.json 正确
- [ ] Prompt 可输入

## 真机闭环

- [ ] 智能体调试启动
- [ ] 模型收到观测
- [ ] 模型返回 action
- [ ] action 下发
- [ ] A1Z 正常执行
- [ ] gripper 方向正确
- [ ] 无异常大幅动作
- [ ] 可安全停止

---

# 25. 关键安全要求

虽然本文件重点是 CloudRobo 工作流，但最终需要真机，因此必须保留官方 A1Z 安全约束。

至少包括：

1. A1Z 无机械制动器，断电会下坠
2. 断电前先回安全姿态
3. 首次真实动作必须人员离开工作空间
4. 手边准备急停 / 断电措施
5. 关节目标必须考虑限位
6. 不要让未经验证的动作直接大幅执行
7. 首次云端闭环必须先 dry_run
8. gripper_sign 必须确认正确
9. 相机键名与训练数据必须完全一致

安全优先于进度。

---

# 26. 当前 CloudRobo 平台推进路线

从现在开始 CloudRobo 侧按以下顺序推进。

## 阶段 1：REAL baseline

当前正在进行。

```text
官方 REAL
→ LeRobot_PI05-Base
→ 全参数微调
→ A1Z-Cleanup-PI05-REAL v0.0.1
```

## 阶段 2：训练验收

训练完成后检查：

- loss
- 日志
- checkpoint
- 模型资产

## 阶段 3：模型部署

```text
模型资产
→ 模型部署
→ r2c.json
→ 模型服务运行中
```

## 阶段 4：仿真模型评测

```text
A1Z 清理桌面仿真场景
+
模型服务
→ 模型评测
```

## 阶段 5：SIM + REAL

```text
官方 SIM
+
官方 REAL
→ CloudRobo LeRobot 数据合并
→ A1Z-Cleanup-PI05-MIX
```

## 阶段 6：模型对比

比较：

- REAL-only
- MIX
- 后续 ACT（若平台开放）
- 其他 VLA（时间允许时）

## 阶段 7：两条线汇合

```text
模型服务运行中
+
上位机机器人在线
→ 智能体调试
```

## 阶段 8：现场数据回流

```text
真机失败
→ Star Arm 干预 / 示范
→ 新 REAL
→ 合并
→ 重训
→ 新版本
```

---

# 27. 当前不应该做的事情

为了防止项目再次复杂化，当前避免：

- 不因为远程服务器而重新设计训练体系
- 不自己搭模型训练服务器替代 CloudRobo
- 不为了展示技术感而重复实现平台已有功能
- 不未经验证自己写 LeRobot 数据合并脚本
- 不未经官方说明修改 A1Z action / gripper 定义
- 不因为当前 P4 / VM 的 CUDA 情况改变比赛模型路线
- 不一上来同时训练多个大模型
- 不把仿真成功率等同于真机成功率
- 不把“机器人在线”误认为“动作闭环完成”
- 不把“模型训练成功”误认为“比赛模型完成”

---

# 28. 当前最重要的比赛思维

本次比赛不要把问题理解成：

> “我们要从零写一个机械臂 AI 系统。”

正确理解是：

> **在 CloudRobo 提供的具身智能平台上，围绕 A1Z 任务建立高质量的数据、训练、部署、真机反馈闭环。**

真正的竞争力主要来自：

1. 数据选择
2. 真机数据质量
3. SIM / REAL 配比
4. 模型选择
5. 模型微调策略
6. 真机失败数据回流
7. 多轮迭代
8. 稳定的 A1Z / R2C 接口
9. 真机安全和执行稳定性

平台按钮只是封装形式，真正的工程判断仍然在以上这些环节。

---

# 29. 给 Codex 的最终工作指令

当你读到本文件时，说明你已经或正在完成本地 VM / 上位机环境。

你的目标不是重新设计 CloudRobo 工作流。

你需要做的是：

1. 保持本地 A1Z 软件栈与官方 A1Z SDK 文档一致。
2. 让本地采集和云端推理使用同一套 A1Z LeRobot 插件和标定逻辑。
3. 确保：
   - joint_1~joint_6
   - gripper
   - cam_external
   - cam_wrist
   与 CloudRobo 训练数据和 r2c.json 完全对齐。
4. 确保 `gripper_sign = +1`。
5. 确保采集时优先采用官方推荐的 absolute_rad。
6. 安装并验证 r2c_sdk。
7. 完成 `robot_a1z_lerobot_v2_config.yaml`。
8. 等用户从 CloudRobo 下载机器人 credential bundle 后完成云端接入。
9. 第一次连接必须 dry_run。
10. 最终目标不是“本地代码能运行”，而是：
    - CloudRobo 机器人在线
    - 观测上行正常
    - 模型服务正常
    - 智能体调试能下发动作
    - A1Z 安全执行
11. 不要自行替代 CloudRobo 的模型训练、模型部署和模型管理。
12. 如果发现接口字段与本文或官方 A1Z 文档不一致，以**最新 A1Z 官方专属章节**为最高优先级，并明确报告差异，不得静默修改。

---

# 30. 当前项目状态快照

截至本文生成时，当前进度：

## 已完成

- [x] 确认真机赛 A1Z 清理桌面任务
- [x] 阅读官方 CloudRobo 用户指南
- [x] 阅读官方 SDK 参考
- [x] 阅读快速入门
- [x] 阅读最佳实践
- [x] 确认 A1Z 官方 SIM 数据
- [x] 确认 A1Z 官方 REAL 数据
- [x] 基本理解 LeRobot V3 数据结构
- [x] 确认主线模型使用 LeRobot_PI05-Base
- [x] 选择全参数微调
- [x] 创建第一版 REAL baseline
- [x] 输出模型资产命名方案
- [x] 明确后续 DAgger / 数据回流路线

## 进行中

- [ ] `A1Z-Cleanup-PI05-REAL v0.0.1` 模型训练

## 尚未进行

- [ ] 查看最终训练指标
- [ ] 模型资产验收
- [ ] 模型部署
- [ ] r2c.json 实际部署验证
- [ ] 模型仿真评测
- [ ] SIM + REAL 合并训练
- [ ] CloudRobo 创建 A1Z 真机实例
- [ ] 上位机机器人在线
- [ ] R2C 观测上行
- [ ] 智能体调试
- [ ] 真机闭环
- [ ] 现场 REAL 采集
- [ ] DAgger 重训
- [ ] v0.0.2 / v0.0.3

---

# 31. 一句话总架构

```text
CloudRobo：
数据 → 训练 → 模型 → 部署 → 云端推理
                         ↕
                        R2C
                         ↕
上位机：
Camera / A1Z / Gripper / CAN / LeRobot / SDK
                         ↕
                       真机
                         ↓
                    失败数据回流
                         ↓
CloudRobo：
                 合并 → 重训 → 新版本
```

这就是本次决赛的完整主线。

---

# 32. 后续协作原则

后续 ChatGPT 与 Codex 分工继续保持：

## ChatGPT

重点负责：

- CloudRobo 平台使用
- 训练和数据策略
- 模型部署
- 仿真评测
- 数据合并
- 多轮重训
- 比赛策略和实验设计

## Codex

重点负责：

- VM / Ubuntu
- A1Z SDK
- LeRobot 插件
- r2c_sdk
- CAN
- Camera
- Star Arm
- a1z-teleop
- robot config
- 本地代码
- Git
- 上位机运行
- 真机接入

任何跨线修改都必须先确认：

> 这是 CloudRobo 平台侧问题，还是上位机接口问题？

不要重复造轮子，不要让两条线互相覆盖。

---

**本文件不是最终静态说明书。**

随着训练完成、模型部署、上位机在线、真机数据采集等节点推进，应继续更新“当前项目状态快照”和“接口实际值”，使它始终能够作为 Codex / 团队成员快速恢复上下文的统一项目说明。
