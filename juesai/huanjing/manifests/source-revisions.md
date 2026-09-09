# 源码基线记录 (Source Revisions)

> 从本机实际源码仓库读取, 非凭记忆。
> 采集时间: 2026-09-09
> 基线用途: safety-port-202608 迁移前的黄金基线存档

## GALAXEA-A1Z (A1Z 机械臂/夹爪 SDK)
- 本机路径:    ~/a1z-workspace/GALAXEA-A1Z
- 远端 origin: https://github.com/userguide-galaxea/GALAXEA-A1Z.git
- 分支:        gripper    (当前黄金基线)
- commit:      e931ecd0e25ad35df251097ba42921b3d2fa7224
- commit msg:  "fix: teleop deadlock when position exceeds soft joint limits"
- 未来迁移:    release/safety-port-202608 (比赛方指定, 配套文件仍在更新)

## a1z-teleop (主从臂遥操作 / 数据采集)
- 本机路径:    ~/a1z-workspace/a1z-teleop
- 远端 origin: https://github.com/suhanwu/a1z-teleop.git
- 分支:        main
- commit:      c3275a32951a52f4a7d9e7d9976eb687652526ba
- commit msg:  "Add agent docs: CLAUDE.md, CONTEXT.md, issue tracker & triage conventions"

## R2C SDK (官方 CloudRobo 通信/观测-动作闭环)
- Python 包名:  hw-r2c-sdk
- 版本:         0.1.90
- 源码目录:     ~/a1z-workspace/r2c_sdk_0.1.90/r2c_sdk_python   (pip editable: -e)
- 官方安装包:   hw_r2c_sdk-0.1.90.tar.gz  (由 CloudRobo 控制台下载, 不纳入 Git)
- SHA256:       366998a0d9748bdc237d2aa6a98d3a5c28f8747c6963bb4d3e1d1f4c8fa9a6f7  (已核对 PASS)
- 归档存放(本机, 仓库外): ~/Documents/cloudrobo/anzhuang/

## pip-freeze 中 A1Z editable 记录
- -e git+https://github.com/userguide-galaxea/GALAXEA-A1Z.git@e931ecd064#egg=a1z
- -e ~/a1z-workspace/r2c_sdk_0.1.90/r2c_sdk_python  (== hw-r2c-sdk==0.1.90)

## conda 关键包快照 (详见 baseline/conda-list-before-safety-port.txt)
- a1z 0.0.1 (pypi)   lerobot 0.6.1   python 3.12.14