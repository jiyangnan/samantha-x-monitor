#!/bin/bash
# X Account Monitor - 自媒体运营自动化脚本
# 调用 twikit 抓取账号推文

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 使用相对于脚本的路径
DATA_DIR="${SCRIPT_DIR}/../x-monitor"
VENV_DIR="$DATA_DIR/.venv"
LOG_FILE="$DATA_DIR/log.txt"

# 激活虚拟环境
ACTIVATE="$VENV_DIR/bin/activate"
if [ -f "$ACTIVATE" ]; then
    source "$ACTIVATE"
else
    echo "虚拟环境不存在，请先创建"
    exit 1
fi

# 运行 twikit 抓取
cd "$DATA_DIR"
python3 x-twikit.py 3

echo "========== 抓取完成 =========="
