# COMMANDS.md — A1Z 上位机常用命令速查

> 比赛现场可直接复制。**只含只读/状态/验证命令**; 不放机械臂运动、电机使能、危险回零、未确认的 CAN 初始化参数。

## 1. Conda 启动
```bash
source ~/miniforge3/etc/profile.d/conda.sh
conda activate lerobot061
```

## 2. Python 检查
```bash
python --version
which python
```

## 3. 环境验证(只读, 见 scripts/verify_env.sh)
```bash
bash scripts/verify_env.sh
```
快速导入检查:
```bash
python - <<'PY'
import lerobot, a1z
from r2c_sdk import ClientConfig, SyncRobotClient
print("lerobot PASS | a1z PASS | r2c_sdk PASS")
print("ClientConfig:", ClientConfig)
print("SyncRobotClient:", SyncRobotClient)
PY
```

## 4. 查看 kernel
```bash
uname -r
uname -a
```

## 5. 查看 USB
```bash
lsusb
```

## 6. 查看 USB topology
```bash
lsusb -t
```

## 7. 查看 CAN(只读/状态)
```bash
# 列出网络接口 (只读, 不进行任何使能/初始化操作)
ip -br link
# CAN 状态 (只读查询): 现场交互输入实际接口名, 不默认 can0
read -rp "请输入实际 CAN 接口名: " CAN_IF
ip -details link show "$CAN_IF"
```
> 说明: 只做状态/只读查询, 不执行 enable/bitrate/加载或绑定/任何控制机械臂的命令。
> 实际 CAN interface 名以现场设备识别结果或 `setup_follower_can.sh` 输出为准 (不默认 can0)。

## 8. 查看 Camera
```bash
ls /dev/video* 2>/dev/null || true
v4l2-ctl --list-devices 2>/dev/null || true
```

## 9. 查看磁盘
```bash
df -h
```

## 10. R2C import 检查
```bash
python -c 'import r2c_sdk; from r2c_sdk import ClientConfig, SyncRobotClient; print("r2c_sdk OK")'
```

## 11. Git 更新
```bash
git pull --ff-only
```
> 提交前先 `git status` 确认无敏感文件(证书/私钥)再 commit/push。

## 12. 环境备份(制作新基线)
```bash
# 自动生成带时间戳的 TAG; 显式用 -n lerobot061, 不依赖当前 shell 是否激活该环境
TAG=$(date +%Y%m%d-%H%M%S)
conda list -n lerobot061 --explicit   > "conda-list-${TAG}.txt"
conda run -n lerobot061 python -m pip freeze > "pip-freeze-${TAG}.txt"
```
> 注意: 这是**导出**命令, 生成副本, 不删除也不替换现有环境; 文件名自动带时间戳, 不会覆盖旧文件。