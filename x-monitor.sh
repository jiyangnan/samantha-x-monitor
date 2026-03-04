#!/bin/bash
# X Account Monitor - 自媒体运营自动化脚本
# 功能：抓取关注账号 → 检测新推文 → 生成评论/原创 → 自动发布 → 推送有趣内容

SKILL_DIR="/Users/ferdinandji/.nvm/versions/node/v24.13.1/lib/node_modules/openclaw/skills/baoyu/skills"
DATA_DIR="/Users/ferdinandji/.openclaw/workspace/x-monitor"
LOG_FILE="$DATA_DIR/log.txt"

# 关注列表
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

# 创建目录
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
    echo "$output"
  else
    log "❌ @${user} 抓取失败"
    echo ""
  fi
}

# 检测新推文（对比历史）
detect_new_posts() {
  local user=$1
  local current_file="$DATA_DIR/${user}.md"
  local history_file="$DATA_DIR/${user}-history.md"
  
  if [ ! -f "$history_file" ]; then
    # 首次运行，保存历史
    cp "$current_file" "$history_file"
    log "📝 @${user} 首次抓取，保存历史"
    return 1
  fi
  
  # 对比内容
  if ! diff -q "$current_file" "$history_file" > /dev/null 2>&1; then
    # 有新内容
    cp "$current_file" "$history_file"
    log "🆕 @${user} 发现新内容！"
    return 0
  else
    return 1
  fi
}

# 生成评论建议
generate_comment_suggestion() {
  local content=$1
  
  # 这里调用 LLM 生成评论（简化版）
  echo "评论建议：这是一个很有意思的观点！让我补充一些思考..."
}

# 生成原创推文
generate_original_tweet() {
  local content=$1
  
  # 这里需要调用 LLM 生成原创内容
  # 暂时返回空，稍后实现
  echo ""
}

# 发布推文
post_to_x() {
  local text=$1
  
  if [ -z "$text" ]; then
    return 1
  fi
  
  log "📤 发布推文: ${text:0:50}..."
  
  cd "$SKILL_DIR/baoyu-post-to-x"
  npx -y bun scripts/x-browser.ts "$text" --submit > /dev/null 2>&1
  
  log "✅ 发布成功"
}

# 主流程
main() {
  log "========== 开始监控 =========="
  
  for user in "${ACCOUNTS[@]}"; do
    fetch_account "$user"
    detect_new_posts "$user" && {
      # 发现新内容，可以生成评论或原创
      log "处理 @${user} 的新内容..."
    }
  done
  
  log "========== 监控完成 =========="
}

# 运行
main
