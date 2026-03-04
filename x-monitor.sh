#!/bin/bash
# X Account Monitor - 自媒体运营自动化脚本 v3.1
# 功能：抓取 25 个 X 账号内容，AI 分析和发布由 LLM 处理

SKILL_DIR="/Users/ferdinandji/.nvm/versions/node/v24.13.1/lib/node_modules/openclaw/skills/baoyu/skills"
DATA_DIR="/Users/ferdinandji/.openclaw/workspace/x-monitor"
LOG_FILE="$DATA_DIR/log.txt"

# 25 个关注账号（必须全部抓取，不许偷懒）
ACCOUNTS=(
  "Aries_warrior_f"
  "edwordkaru"
  "lexi_labs"
  "blackanger"
  "minchoi"
  "berryxia"
  "sama"
  "xiaojietongxue"
  "yaohui12138"
  "GoSailGlobal"
  "howie_serious"
  "bozhou_ai"
  "lxfater"
  "yanhua1010"
  "oran_ge"
  "ZeroZ_JQ"
  "vista8"
  "bggg_ai"
  "Tz_2022"
  "cellinlab"
  "xiaohu"
  "songguoxiansen"
  "op7418"
  "dotey"
  "canghe"
)

mkdir -p "$DATA_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 抓取账号最新推文
fetch_account() {
  local user=$1
  local output="$DATA_DIR/${user}.md"
  
  log "抓取 @${user}..."
  
  cd "$SKILL_DIR/baoyu-url-to-markdown"
  npx -y bun scripts/main.ts "https://x.com/${user}" -o "$output" --timeout 60000 > /dev/null 2>&1
  
  if [ -f "$output" ]; then
    log "✅ @${user} 抓取成功"
    return 0
  else
    log "❌ @${user} 抓取失败"
    return 1
  fi
}

# 检测新推文并记录
detect_and_save_new() {
  local user=$1
  local current_file="$DATA_DIR/${user}.md"
  local history_file="$DATA_DIR/${user}-history.md"
  local new_file="$DATA_DIR/new-queue.txt"
  
  if [ ! -f "$history_file" ]; then
    # 首次抓取，保存历史
    cp "$current_file" "$history_file"
    log "📝 @${user} 首次抓取，保存历史"
    return 1
  fi
  
  # 对比内容
  if ! diff -q "$current_file" "$history_file" > /dev/null 2>&1; then
    # 有新内容
    cp "$current_file" "$history_file"
    log "🆕 @${user} 发现新内容！"
    
    # 记录到新内容队列
    echo "$user" >> "$new_file"
    return 0
  fi
  
  return 1
}

# 清空新内容队列
clear_queue() {
  local new_file="$DATA_DIR/new-queue.txt"
  > "$new_file"
}

# 主流程：必须抓取全部 25 个账号
main() {
  log "========== 开始抓取（必须全部 25 个）=========="
  
  clear_queue
  
  local count=0
  for user in "${ACCOUNTS[@]}"; do
    fetch_account "$user"
    detect_and_save_new "$user"
    ((count++))
  done
  
  log "========== 抓取完成: $count/25 =========="
  
  # 输出新内容列表
  local new_file="$DATA_DIR/new-queue.txt"
  if [ -s "$new_file" ]; then
    log "📋 发现新内容的账号："
    cat "$new_file" | while read user; do
      log "  - @${user}"
    done
  else
    log "📋 没有发现新内容"
  fi
}

main
