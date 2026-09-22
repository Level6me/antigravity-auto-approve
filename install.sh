#!/usr/bin/env bash
# ==============================================================================
# Antigravity CLI Auto-Approve Installer
# ⚡️ 一键自动配置 Google Antigravity CLI (agy) 终端命令全局放行
# GitHub: https://github.com/Level6me/antigravity-auto-approve
# ==============================================================================

set -e

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${CYAN}${BOLD}"
echo "=================================================================="
echo "   🚀 Antigravity CLI (agy) 终端命令免审批一键配置工具"
echo "=================================================================="
echo -e "${NC}"

SETTINGS_DIR="$HOME/.gemini/antigravity-cli"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

# 1. 确保配置目录存在
if [ ! -d "$SETTINGS_DIR" ]; then
    echo -e "${BLUE}📁 创建 Antigravity CLI 配置目录: ${SETTINGS_DIR}${NC}"
    mkdir -p "$SETTINGS_DIR"
fi

# 2. 检查 Python 3 环境
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ 未检测到 Python 3，请先安装 Python 3 后再运行本脚本。${NC}"
    exit 1
fi

# 3. 执行安全的 JSON 注入
python3 - << 'EOF'
import os
import sys
import json
import shutil

path = os.path.expanduser('~/.gemini/antigravity-cli/settings.json')
data = {}

if os.path.exists(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        # 备份损坏的文件
        backup_path = path + ".bak"
        shutil.copyfile(path, backup_path)
        print(f"⚠️ 现有的 settings.json 解析异常，已为您备份至 {backup_path}")
        data = {}

# 确保结构存在
if 'permissions' not in data or not isinstance(data['permissions'], dict):
    data['permissions'] = {}

if 'allow' not in data['permissions'] or not isinstance(data['permissions']['allow'], list):
    data['permissions']['allow'] = []

allow_list = data['permissions']['allow']

# 检查 command(*) 是否已经存在
if 'command(*)' not in allow_list:
    allow_list.insert(0, 'command(*)')
    action_status = "ADDED"
else:
    # 确保排在首位以优先匹配
    if allow_list[0] != 'command(*)':
        allow_list.remove('command(*)')
        allow_list.insert(0, 'command(*)')
    action_status = "EXISTED"

# 回写配置
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

if action_status == "ADDED":
    print("✨ 已成功将全局命令放行规则 'command(*)' 写入配置文件！")
else:
    print("ℹ️ 全局放行规则 'command(*)' 已处于生效状态，无需重复添加。")

EOF

echo -e "${GREEN}${BOLD}"
echo "=================================================================="
echo "✅ 配置完成！Antigravity CLI 已开启终端命令全自动放行。"
echo "=================================================================="
echo -e "${NC}"
echo -e "${YELLOW}💡 提示：${NC}"
echo -e "   1. 从现在起，Agent 在终端执行任何命令均会自动静默放行；"
echo -e "   2. 彻底告别 ${BOLD}'Run this command?'${NC} 及选择题弹窗；"
echo -e "   3. 若当前终端已有正在运行的 agy 会话，按 ${CYAN}Ctrl+D${NC} 重新启动会话即可生效。"
echo ""
